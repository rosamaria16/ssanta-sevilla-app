import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/hora_utils.dart';
import '../utils/franja_horaria_utils.dart';

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

  static const _ordenTipos = ['CRUZGUIA', 'PASO', 'PALIO', 'DUELO'];
  static const _nombresTipos = {
    'CRUZGUIA': 'Cruz de Guía',
    'PASO': 'Paso',
    'PALIO': 'Palio',
    'DUELO': 'Duelo',
  };

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

  int _prioridadTipoPaso(String tipo) {
    final indice = _ordenTipos.indexOf(tipo);
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

    //calcular franjas horarias con intervalos de 30 min
    final todosMinutos = listaInfoPasos.map((i) => horaAMinutos(i.hora)).toList();
    final franjaHoraria = FranjaHoraria.calcularFranjas(todosMinutos);
    final franjasHorarias = franjaHoraria.horas;

    final mapaDatos = <String, Map<String, String>>{};
    for (final info in listaInfoPasos) {
      final hora = normalizaHora(info.hora);
      mapaDatos.putIfAbsent(hora, () => {});
      String textoCelda = info.localizacion;
      if (info.difHora != null && info.difHora!.isNotEmpty) {
        textoCelda += '\n(${normalizaHora(info.difHora!)})';
      }
      mapaDatos[hora]![info.tipoPaso] = textoCelda;
    }

    const double rowHeight = 56.0;
    const double headerHeight = 48.0;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCabecera(columnasUnicas, headerHeight),
          Expanded(
            child: ListView.builder(
              itemCount: franjasHorarias.length,
              itemExtent: rowHeight,
              itemBuilder: (context, index) {
                final hora = franjasHorarias[index];
                return Row(
                  children: [
                    _buildCeldaHora(hora, rowHeight),
                    ...columnasUnicas.map((tipo) {
                      return _buildCeldaDato(
                        mapaDatos[hora]?[tipo] ?? '',
                        rowHeight,
                        index.isEven,
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

  Widget _buildCabecera(List<String> columnas, double altura) {
    return Container(
      height: altura,
      color: const Color.fromRGBO(25, 52, 89, 1),
      child: Row(
        children: [
          _buildCeldaCabecera('Hora', flex: 2),
          ...columnas.map((tipo) =>
            _buildCeldaCabecera(_nombresTipos[tipo] ?? tipo, flex: 3),
          ),
        ],
      ),
    );
  }

  Widget _buildCeldaCabecera(String texto, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.white24),
            bottom: BorderSide(color: Colors.white24),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          texto,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCeldaHora(String hora, double altura) {
    return Expanded(
      flex: 2,
      child: Container(
        height: altura,
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCeldaDato(String texto, double altura, bool esPar) {
    return Expanded(
      flex: 3,
      child: Container(
        height: altura,
        decoration: BoxDecoration(
          color: esPar
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
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
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