import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProgramaThirdScreen extends StatefulWidget {
  final int idHermandad;
  final String nombreHermandad;
  const ProgramaThirdScreen({
    super.key,
    required this.idHermandad,
    required this.nombreHermandad,
  });

  @override
  State<ProgramaThirdScreen> createState() => _ProgramaThirdScreenState();
}

class _ProgramaThirdScreenState extends State<ProgramaThirdScreen> {
  List<InfoPaso> listaInfoPasos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarInfoPasos();
  }

  Future<void> _cargarInfoPasos() async {
    try {
      final infoPasos = await InfoPaso.getByHermandad(widget.idHermandad);
      setState(() {
        listaInfoPasos = infoPasos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  int _rawMinutes(String hora) {
    final clean = hora.length >= 5 ? hora.substring(0, 5) : hora;
    final parts = clean.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]); //Calcular minutos totales con respecto a medianoche
  }

  int _findStartOffset(List<int> rawList) {
    if (rawList.isEmpty) return 0;
    final sorted = rawList.toSet().toList()..sort();
    if (sorted.length == 1) return sorted[0];
    int maxGap = sorted[0] + 1440 - sorted.last;
    int startAfterGap = sorted[0];
    for (int i = 1; i < sorted.length; i++) {
      final gap = sorted[i] - sorted[i - 1];
      if (gap > maxGap) {
        maxGap = gap;
        startAfterGap = sorted[i];
      }
    }
    return startAfterGap;
  }

  String _minutesToTimeStr(int totalMinutes) {
    int hours = (totalMinutes ~/ 60) % 24;
    int mins = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  String _normalizaHora(String hora) {
    return hora.length >= 5 ? hora.substring(0, 5) : hora;
  }

  String _displayTipoPaso(String tipo) {
    switch (tipo) {
      case 'CRUZGUIA':
        return 'Cruz de Guía';
      case 'PALIO':
        return 'Palio';
      case 'DUELO':
        return 'Duelo';
      case 'PASO':
        return 'Paso';
      default:
        return tipo;
    }
  }

  int _prioridadTipoPaso(String tipo) {
    const ordenTipos = ['CRUZGUIA', 'PASO', 'PALIO', 'DUELO'];
    final indice = ordenTipos.indexOf(tipo);
    return indice == -1 ? 999 : indice;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(child: Text('Error: $_error')),
      );
    }
    if (listaInfoPasos.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: Text('No hay datos disponibles')),
      );
    }

    final columnasUnicas = listaInfoPasos
        .map((info) => info.tipoPaso)
        .toSet()
        .toList()
      ..sort((a, b) => _prioridadTipoPaso(a).compareTo(_prioridadTipoPaso(b)));

    //Ordenar cronológicamente
    final allRaw = listaInfoPasos.map((i) => _rawMinutes(i.hora)).toList();
    final startOffset = _findStartOffset(allRaw);

    //Huecos de 30 min
    final adjustedSet = allRaw.map((r) => (r - startOffset + 1440) % 1440).toSet();
    final minAdj = adjustedSet.reduce((a, b) => a < b ? a : b);
    final maxAdj = adjustedSet.reduce((a, b) => a > b ? a : b);
    final timeSlots = <String>[];
    for (int t = minAdj; t <= maxAdj; t += 30) {
      timeSlots.add(_minutesToTimeStr((t + startOffset) % 1440));
    }

    //Mapa hora -> tipoPaso -> texto celda
    final dataMap = <String, Map<String, String>>{};
    for (final info in listaInfoPasos) {
      final horaKey = _normalizaHora(info.hora);
      dataMap.putIfAbsent(horaKey, () => {});
      String cellText = info.localizacion;
      if (info.difHora != null && info.difHora!.isNotEmpty) {
        cellText += '\n(${_normalizaHora(info.difHora!)})';
      }
      dataMap[horaKey]![info.tipoPaso] = cellText;
    }

    const double rowHeight = 56.0;
    const double headerHeight = 48.0;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Container(
            height: headerHeight,
            color: const Color.fromRGBO(25, 52, 89, 1),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.white24),
                        bottom: BorderSide(color: Colors.white24),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Hora',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                ...columnasUnicas.map((tipo) => Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.white24),
                        bottom: BorderSide(color: Colors.white24),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _displayTipoPaso(tipo),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: timeSlots.length,
              itemExtent: rowHeight,
              itemBuilder: (context, index) {
                final hora = timeSlots[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: rowHeight,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(25, 52, 89, 0.85),
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade400),
                            bottom: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          hora,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ...columnasUnicas.map((tipo) {
                      final cellText = dataMap[hora]?[tipo] ?? '';
                      return Expanded(
                        flex: 3,
                        child: Container(
                          height: rowHeight,
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? const Color.fromRGBO(240, 240, 245, 1)
                                : Colors.white,
                            border: Border(
                              right: BorderSide(color: Colors.grey.shade300),
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            cellText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(25, 52, 89, 1),
      centerTitle: true,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          widget.nombreHermandad,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}