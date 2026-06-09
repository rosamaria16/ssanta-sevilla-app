import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:frontend/utils/hora_utils.dart';
import 'package:frontend/utils/franja_horaria_utils.dart';
import 'package:frontend/utils/tipopaso_utils.dart';
import '../services/api_service.dart';
import '../services/auth_manager.dart';
import '../services/pdf_itinerario_service.dart';

class ItinerarioSecondScreen extends StatefulWidget {
  final int idDia;
  final String nombreDia;
  const ItinerarioSecondScreen({
    super.key,
    required this.idDia,
    required this.nombreDia,
  });

  @override
  State<ItinerarioSecondScreen> createState() => _ItinerarioSecondScreenState();
}

class _ItinerarioSecondScreenState extends State<ItinerarioSecondScreen> {
  List<InfoPaso> todosInfoPasos = [];
  Map<int, String> hermandadNombres = {};
  int? itinerarioId;
  Map<int, int> savedItems = {}; //{infoPasoId -> itemItinerarioId}
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final resultados = await Future.wait([
        InfoPaso.getByDia(widget.idDia),
        Hermandad.getHermandadesDia(widget.idDia),
      ]);
      todosInfoPasos = resultados[0] as List<InfoPaso>;
      final hermandades = resultados[1] as List<Hermandad>;
      for (final h in hermandades) {
        hermandadNombres[h.id] = h.nombre;
      }

      final userId = AuthManager().currentUser?['id'];
      if (userId != null) {
        final itData = await ItinerarioApi.getOrCreateByUsuario(userId);
        itinerarioId = itData['id'];
        List<dynamic> items = [];
        if (itData['items'] != null && itData['items'] is List<dynamic>) {
          items = itData['items'];
        }        
        for (final item in items) {
          savedItems[item['idInfoPaso']] = item['id']; //guarda el infopaso x como item y
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _buildDisplayTextWithTipo(InfoPaso info) {
    final nombre = hermandadNombres[info.idHermandad] ?? '?';
    final tipo = displayTipoPaso(info.tipoPaso);
    String text = '$nombre ($tipo) - ${info.localizacion}';
    if (info.difHora != null && info.difHora!.isNotEmpty) {
      text += ' (${normalizaHora(info.difHora!)})';
    }
    return text;
  }

    String _buildDisplayText(InfoPaso info) {
    final nombre = hermandadNombres[info.idHermandad] ?? '?';
    String text = '$nombre - ${info.localizacion}';
    if (info.difHora != null && info.difHora!.isNotEmpty) {
      text += ' (${normalizaHora(info.difHora!)})';
    }
    return text;
  }

  Future<void> _onCellTap(String hora, List<InfoPaso> opciones, InfoPaso? seleccionActual) async {
    if (opciones.isEmpty && seleccionActual == null) return;

    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Selección para las $hora',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      if (seleccionActual != null)
                        ListTile(
                          leading: const Icon(Icons.delete_outline, color: Colors.red),
                          title: Text(
                            'Eliminar: ${_buildDisplayTextWithTipo(seleccionActual)}',
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                          onTap: () => Navigator.pop(context, 'remove'),
                        ),
                      if (seleccionActual != null) const Divider(),
                      ...opciones.map((info) {
                        final isSelected = seleccionActual?.id == info.id;
                        return ListTile(
                          leading: isSelected
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.add_circle_outline),
                          title: Text(
                            _buildDisplayText(info),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: (isSelected || info.esCarreraOficial) ? FontWeight.bold : FontWeight.normal,
                              color: info.esCarreraOficial ? const Color.fromRGBO(106, 27, 154, 1) : null,
                            ),
                          ),
                          subtitle: Text(
                            info.esCarreraOficial
                                ? '${displayTipoPaso(info.tipoPaso)} · Carrera Oficial'
                                : displayTipoPaso(info.tipoPaso),
                            style: TextStyle(
                              fontSize: 12,
                              color: info.esCarreraOficial
                                  ? const Color.fromRGBO(142, 68, 173, 1)
                                  : Colors.grey[600],
                              fontWeight: info.esCarreraOficial ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          onTap: isSelected ? null : () => Navigator.pop(context, info),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || itinerarioId == null) return;

    try {
      if (result == 'remove') {
        final itemId = savedItems[seleccionActual!.id];
        if (itemId != null) {
          await ItinerarioApi.removeItem(itinerarioId!, itemId);
          setState(() => savedItems.remove(seleccionActual.id));
        }
      } else if (result is InfoPaso) {
        if (seleccionActual != null) {
          final oldItemId = savedItems[seleccionActual.id];
          if (oldItemId != null) {
            await ItinerarioApi.removeItem(itinerarioId!, oldItemId);
            savedItems.remove(seleccionActual.id);
          }
        }
        final response = await ItinerarioApi.addItem(itinerarioId!, result.id);
        setState(() => savedItems[result.id] = response['id']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
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
    if (todosInfoPasos.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: Text('No hay datos disponibles')),
      );
    }

    //calcular franjas horarias (intervalos de 30 min)
    final todasHorasEnMinutos = todosInfoPasos.map((i) => horaAMinutos(i.hora)).toList();
    final franjaHoraria = FranjaHoraria.calcularFranjas(todasHorasEnMinutos);
    final franjasHoras = franjaHoraria.horas;
    final franjasHorasEnMinutos = franjaHoraria.minutosAjustados;

    //agrupar infopasos por (hermandad, tipoPaso), ordenados cronológicamente
    final porGrupo = <String, List<InfoPaso>>{};
    for (final info in todosInfoPasos) {
      final key = '${info.idHermandad}_${info.tipoPaso}';
      porGrupo.putIfAbsent(key, () => []);
      porGrupo[key]!.add(info);
    }
    for (final list in porGrupo.values) {
      list.sort((a, b) {
        final adjA = franjaHoraria.ajustarHora(horaAMinutos(a.hora));
        final adjB = franjaHoraria.ajustarHora(horaAMinutos(b.hora));
        return adjA.compareTo(adjB);
      });
    }

    //Para cada franja, asignar los infopasos cuya hora coincide
    final opcionesMap = <String, List<InfoPaso>>{};
    for (int i = 0; i < franjasHoras.length; i++) {
      final franjaAdj = franjasHorasEnMinutos[i];
      final activos = <InfoPaso>[];
      for (final entry in porGrupo.entries) {
        final infoList = entry.value;
        for (final info in infoList) {
          final infoAdj = franjaHoraria.ajustarHora(horaAMinutos(info.hora));
          if (infoAdj == franjaAdj) {
            activos.add(info);
          }
        }
      }
      opcionesMap[franjasHoras[i]] = activos;
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
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white24),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Selección',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: franjasHoras.length,
              itemExtent: rowHeight,
              itemBuilder: (context, index) {
                final hora = franjasHoras[index];
                final opciones = opcionesMap[hora] ?? [];

                //busca si el usuario tiene una selección guardada en la franja
                InfoPaso? seleccionado;
                for (final info in opciones) {
                  if (savedItems.containsKey(info.id)) {
                    seleccionado = info;
                    break;
                  }
                }

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
                    Expanded(
                      flex: 5,
                      child: GestureDetector(
                        onTap: () => _onCellTap(hora, opciones, seleccionado),
                        child: Container(
                          height: rowHeight,
                          decoration: BoxDecoration(
                            color: seleccionado != null
                                ? (seleccionado.esCarreraOficial
                                    ? const Color.fromRGBO(155, 89, 182, 0.15)
                                    : const Color.fromRGBO(200, 230, 201, 1))
                                : index.isEven
                                    ? const Color.fromRGBO(240, 240, 245, 1)
                                    : Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: seleccionado != null
                              ? Text(
                                  _buildDisplayTextWithTipo(seleccionado),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: seleccionado.esCarreraOficial ? FontWeight.bold : FontWeight.normal,
                                    color: seleccionado.esCarreraOficial ? const Color.fromRGBO(106, 27, 154, 1) : null,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                )
                              : Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.grey[500],
                                  size: 28,
                                ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _descargarPdfDia() async {
    final userId = AuthManager().currentUser?['id'];
    if (userId == null) return;

    try {
      final entradas = await EntradaItinerarioExport.getEntradasItinerarioExport(
        userId,
        idDia: widget.idDia,
      );
      if (entradas.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay entradas para este día')),
          );
        }
        return;
      }
      final pdfBytes = await PdfItinerarioService.crearPdf(entradas, diaFiltro: widget.nombreDia);
      final nombreArchivo = 'itinerario_${widget.nombreDia.toLowerCase().replaceAll(' ', '_')}.pdf';
      await Printing.sharePdf(bytes: pdfBytes, filename: nombreArchivo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: ${e.toString()}')),
        );
      }
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromRGBO(25, 52, 89, 1),
      centerTitle: true,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Mi Itinerario - ${widget.nombreDia}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'Descargar PDF',
          onPressed: _descargarPdfDia,
        ),
      ],
    );
  }
}