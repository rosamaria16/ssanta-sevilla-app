import 'package:flutter/material.dart';
import 'package:frontend/utils/hora_utils.dart';
import 'package:frontend/utils/franja_horaria_utils.dart';
import 'package:frontend/utils/tipopaso_utils.dart';
import '../services/api_service.dart';
import '../services/auth_manager.dart';

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
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            displayTipoPaso(info.tipoPaso),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

    //Para cada franja, calcula infopasos activos,
    //siendo el activo de cada hermandad el último cuya horaAjustada <= franjaAdj
    //pero solo se arrastra si la hermandad tiene un infopaso futuro (sigue en la calle).
    //Si el activo es el último de la hermandad, solo se muestra en su propia franja
    final opcionesMap = <String, List<InfoPaso>>{};
    for (int i = 0; i < franjasHoras.length; i++) {
      final franjaAdj = franjasHorasEnMinutos[i];
      final activos = <InfoPaso>[];
      for (final entry in porGrupo.entries) {
        final infoList = entry.value;
        InfoPaso? activo;
        for (final info in infoList) {
          final infoAdj = franjaHoraria.ajustarHora(horaAMinutos(info.hora));
          if (infoAdj <= franjaAdj) {
            activo = info;
          } else {
            break;
          }
        }
        if (activo != null) {
          final activoAdj = franjaHoraria.ajustarHora(horaAMinutos(activo.hora));
          final esUltimo = identical(activo, infoList.last);

          if (!esUltimo || (franjaAdj - activoAdj) < 30) {
            activos.add(activo);
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
                                ? const Color.fromRGBO(200, 230, 201, 1)
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
                                  style: const TextStyle(fontSize: 12),
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
    );
  }
}