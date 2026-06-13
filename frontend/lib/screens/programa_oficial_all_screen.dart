import 'package:flutter/material.dart';
import '../services/info_paso_service.dart';
import '../services/hermandad_service.dart';
import '../utils/hora_utils.dart';
import '../utils/franja_horaria_utils.dart';

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

  final ScrollController _controladorScrollFijo = ScrollController();
  final ScrollController _controladorScrollDatos = ScrollController();
  bool _sincronizandoScroll = false;

  static const _ordenTipos = ['CRUZGUIA', 'PASO', 'PALIO', 'DUELO'];

  @override
  void initState() {
    super.initState();
    _controladorScrollFijo.addListener(_alDesplazarFijo);
    _controladorScrollDatos.addListener(_alDesplazarDatos);
    _cargarDatos();
  }

  void _alDesplazarFijo() {
    if (_sincronizandoScroll) return;
    _sincronizandoScroll = true;
    _controladorScrollDatos.jumpTo(_controladorScrollFijo.offset);
    _sincronizandoScroll = false;
  }

  void _alDesplazarDatos() {
    if (_sincronizandoScroll) return;
    _sincronizandoScroll = true;
    _controladorScrollFijo.jumpTo(_controladorScrollDatos.offset);
    _sincronizandoScroll = false;
  }

  @override
  void dispose() {
    _controladorScrollFijo.removeListener(_alDesplazarFijo);
    _controladorScrollDatos.removeListener(_alDesplazarDatos);
    _controladorScrollFijo.dispose();
    _controladorScrollDatos.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    try {
      final resultados = await Future.wait([
        InfoPaso.getByDia(widget.idDia),
        Hermandad.getHermandadesDia(widget.idDia),
      ]);
      setState(() {
        listaInfoPasos = resultados[0] as List<InfoPaso>;
        listaHermandades = resultados[1] as List<Hermandad>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  ///determina el tipo de paso con mayor prioridad para cada hermandad
  Map<int, String> _calcularTipoPrincipal() {
    final tipoPrincipal = <int, String>{};
    for (final info in listaInfoPasos) {
      final actual = tipoPrincipal[info.idHermandad];
      if (actual == null) {
        tipoPrincipal[info.idHermandad] = info.tipoPaso;
      } else {
        final idxActual = _ordenTipos.indexOf(actual);
        final idxNuevo = _ordenTipos.indexOf(info.tipoPaso);
        if (idxNuevo != -1 && (idxActual == -1 || idxNuevo < idxActual)) {
          tipoPrincipal[info.idHermandad] = info.tipoPaso;
        }
      }
    }
    return tipoPrincipal;
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

    final nombresHermandad = {
      for (final h in listaHermandades) h.id: h.nombre,
    };

    //filtro tipo principal
    final tipoPrincipal = _calcularTipoPrincipal();
    final filtrados = listaInfoPasos
        .where((info) => tipoPrincipal[info.idHermandad] == info.tipoPaso)
        .toList();

    //columnas
    final idsConDatos = filtrados.map((info) => info.idHermandad).toSet();
    final idsHermandadesOrdenadas = listaHermandades
        .where((h) => idsConDatos.contains(h.id))
        .map((h) => h.id)
        .toList();

    //franjas horas
    final todosMinutos = filtrados.map((info) => horaAMinutos(info.hora)).toList();
    final inicioMinutos = calcularHoraInicio(todosMinutos);
    final minutosAjustados = filtrados
        .map((info) => (horaAMinutos(info.hora) - inicioMinutos + 1440) % 1440)
        .toSet()
        .toList()
      ..sort();
    final franjaHoraria = FranjaHoraria.calcularFranjasDesdeUnicas(minutosAjustados, inicioMinutos);
    final franjasHorarias = franjaHoraria.horas;

    final mapaDatos = <String, Map<int, String>>{};
    for (final info in filtrados) {
      final hora = normalizaHora(info.hora);
      mapaDatos.putIfAbsent(hora, () => {});
      String textoCelda = info.localizacion;
      if (info.difHora != null && info.difHora!.isNotEmpty) {
        textoCelda += ' (${normalizaHora(info.difHora!)})';
      }
      mapaDatos[hora]![info.idHermandad] = textoCelda;
    }

    const double alturaFila = 56.0;
    const double alturaCabecera = 48.0;
    const double anchoColumnaFija = 70.0;
    const double anchoColumnaDato = 130.0;
    final double anchoTotalDatos = anchoColumnaDato * idsHermandadesOrdenadas.length;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Columna fija (Hora)
          SizedBox(
            width: anchoColumnaFija,
            child: Column(
              children: [
                _buildCeldaCabeceraFija('Hora', alturaCabecera),
                Expanded(
                  child: ListView.builder(
                    controller: _controladorScrollFijo,
                    itemCount: franjasHorarias.length,
                    itemExtent: alturaFila,
                    itemBuilder: (context, index) {
                      return _buildCeldaHora(franjasHorarias[index]);
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
                width: anchoTotalDatos,
                child: Column(
                  children: [
                    // Cabecera con nombres de hermandades
                    SizedBox(
                      height: alturaCabecera,
                      child: Row(
                        children: idsHermandadesOrdenadas.map((hId) {
                          return _buildCeldaCabeceraDato(
                            nombresHermandad[hId] ?? '',
                            anchoColumnaDato,
                          );
                        }).toList(),
                      ),
                    ),
                    // Filas de datos
                    Expanded(
                      child: ListView.builder(
                        controller: _controladorScrollDatos,
                        itemCount: franjasHorarias.length,
                        itemExtent: alturaFila,
                        itemBuilder: (context, index) {
                          final hora = franjasHorarias[index];
                          return Row(
                            children: idsHermandadesOrdenadas.map((hId) {
                              return _buildCeldaDato(
                                mapaDatos[hora]?[hId] ?? '',
                                anchoColumnaDato,
                                alturaFila,
                                index.isEven,
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

  Widget _buildCeldaCabeceraFija(String texto, double altura) {
    return Container(
      height: altura,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(25, 52, 89, 1),
        border: Border(
          right: BorderSide(color: Colors.white24),
          bottom: BorderSide(color: Colors.white24),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        texto,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCeldaCabeceraDato(String texto, double ancho) {
    return Container(
      width: ancho,
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
        texto,
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
  }

  Widget _buildCeldaHora(String hora) {
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
        hora,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCeldaDato(String texto, double ancho, double altura, bool esPar) {
    return Container(
      width: ancho,
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
        style: const TextStyle(fontSize: 11),
        overflow: TextOverflow.ellipsis,
        maxLines: 3,
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
