import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProgramaAllScreen extends StatefulWidget {
  final int idDia;
  final String nombreDia;
  const ProgramaAllScreen({
    super.key,
    required this.idDia,
    required this.nombreDia,
  });

  @override
  State<ProgramaAllScreen> createState() => _ProgramaAllScreenState();
}

class _ProgramaAllScreenState extends State<ProgramaAllScreen> {
  List<InfoPaso> listaInfoPasos = [];
  List<Hermandad> listaHermandades = [];
  bool _isLoading = true;
  String? _error;

  final ScrollController _fixedVerticalController = ScrollController();
  final ScrollController _dataVerticalController = ScrollController();
  bool _isSyncingScroll = false;

  @override
  void initState() {
    super.initState();
    _fixedVerticalController.addListener(_onFixedScroll);
    _dataVerticalController.addListener(_onDataScroll);
    _cargarDatos();
  }

  void _onFixedScroll() {
    if (_isSyncingScroll) return;
    _isSyncingScroll = true;
    _dataVerticalController.jumpTo(_fixedVerticalController.offset);
    _isSyncingScroll = false;
  }

  void _onDataScroll() {
    if (_isSyncingScroll) return;
    _isSyncingScroll = true;
    _fixedVerticalController.jumpTo(_dataVerticalController.offset);
    _isSyncingScroll = false;
  }

  @override
  void dispose() {
    _fixedVerticalController.removeListener(_onFixedScroll);
    _dataVerticalController.removeListener(_onDataScroll);
    _fixedVerticalController.dispose();
    _dataVerticalController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    try {
      final results = await Future.wait([
        InfoPaso.getByDia(widget.idDia),
        Hermandad.getHermandadesDia(widget.idDia),
      ]);
      setState(() {
        listaInfoPasos = results[0] as List<InfoPaso>;
        listaHermandades = results[1] as List<Hermandad>;
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
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
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

  int _adjustedMinutes(String hora, int startOffset) {
    return (_rawMinutes(hora) - startOffset + 1440) % 1440;
  }

  String _minutesToTimeStr(int totalMinutes) {
    int hours = (totalMinutes ~/ 60) % 24;
    int mins = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  String _normalizaHora(String hora) {
    return hora.length >= 5 ? hora.substring(0, 5) : hora;
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

    // Mapa id → nombre hermandad
    final hermandadNombres = <int, String>{};
    for (final h in listaHermandades) {
      hermandadNombres[h.id] = h.nombre;
    }

    // Determinar el tipo principal de cada hermandad (CRUZGUIA si existe, si no el primero según orden)
    const tipoOrder = ['CRUZGUIA', 'PASO', 'PALIO', 'DUELO'];
    final hermandadPrimaryTipo = <int, String>{};
    for (final info in listaInfoPasos) {
      final current = hermandadPrimaryTipo[info.idHermandad];
      if (current == null) {
        hermandadPrimaryTipo[info.idHermandad] = info.tipoPaso;
      } else {
        final currentIdx = tipoOrder.indexOf(current);
        final newIdx = tipoOrder.indexOf(info.tipoPaso);
        if (newIdx != -1 && (currentIdx == -1 || newIdx < currentIdx)) {
          hermandadPrimaryTipo[info.idHermandad] = info.tipoPaso;
        }
      }
    }

    // Filtrar: solo el tipo principal de cada hermandad
    final filtered = listaInfoPasos.where((info) =>
        hermandadPrimaryTipo[info.idHermandad] == info.tipoPaso).toList();

    // Columnas: una por hermandad que tenga datos
    final hermandadIds = <int>{};
    for (final info in filtered) {
      hermandadIds.add(info.idHermandad);
    }

    // Ordenar hermandades según el orden original de la lista
    final orderedHermandadIds = listaHermandades
        .where((h) => hermandadIds.contains(h.id))
        .map((h) => h.id)
        .toList();

    // Solo franjas horarias que tienen datos (sin rellenar huecos vacíos)
    final allRaw = filtered.map((info) => _rawMinutes(info.hora)).toList();
    final startOffset = _findStartOffset(allRaw);
    final horaAdjustedSet = <int>{};
    for (final info in filtered) {
      horaAdjustedSet.add(_adjustedMinutes(info.hora, startOffset));
    }
    final sortedAdjusted = horaAdjustedSet.toList()..sort();
    final timeSlots = sortedAdjusted
        .map((adj) => _minutesToTimeStr((adj + startOffset) % 1440))
        .toList();

    // Mapa hora → idHermandad → texto celda (solo tipo principal)
    final dataMap = <String, Map<int, String>>{};
    for (final info in filtered) {
      final horaKey = _normalizaHora(info.hora);
      dataMap.putIfAbsent(horaKey, () => {});
      String text = info.localizacion;
      if (info.difHora != null && info.difHora!.isNotEmpty) {
        text += ' (${_normalizaHora(info.difHora!)})';
      }
      dataMap[horaKey]![info.idHermandad] = text;
    }

    const double rowHeight = 56.0;
    const double headerHeight = 48.0;
    const double fixedColumnWidth = 70.0;
    const double dataColumnWidth = 130.0;
    final double totalDataWidth = dataColumnWidth * orderedHermandadIds.length;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Columna fija (Hora)
          SizedBox(
            width: fixedColumnWidth,
            child: Column(
              children: [
                Container(
                  height: headerHeight,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(25, 52, 89, 1),
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
                Expanded(
                  child: ListView.builder(
                    controller: _fixedVerticalController,
                    itemCount: timeSlots.length,
                    itemExtent: rowHeight,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(25, 52, 89, 0.85),
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade400),
                            bottom: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          timeSlots[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Columnas de datos (scroll horizontal + vertical)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalDataWidth,
                child: Column(
                  children: [
                    // Cabecera con nombres de hermandades
                    SizedBox(
                      height: headerHeight,
                      child: Row(
                        children: orderedHermandadIds.map((hId) {
                          return Container(
                            width: dataColumnWidth,
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(25, 52, 89, 1),
                              border: Border(
                                right: BorderSide(color: Colors.white24),
                                bottom: BorderSide(color: Colors.white24),
                              ),
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              hermandadNombres[hId] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Filas de datos
                    Expanded(
                      child: ListView.builder(
                        controller: _dataVerticalController,
                        itemCount: timeSlots.length,
                        itemExtent: rowHeight,
                        itemBuilder: (context, index) {
                          final hora = timeSlots[index];
                          return Row(
                            children: orderedHermandadIds.map((hId) {
                              final cellText = dataMap[hora]?[hId] ?? '';
                              return Container(
                                width: dataColumnWidth,
                                height: rowHeight,
                                decoration: BoxDecoration(
                                  color: index.isEven
                                      ? const Color.fromRGBO(240, 240, 245, 1)
                                      : Colors.white,
                                  border: Border(
                                    right: BorderSide(
                                        color: Colors.grey.shade300),
                                    bottom: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                child: Text(
                                  cellText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
          'Todas - ${widget.nombreDia}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
