import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../services/dia_service.dart';
import '../services/itinerario_service.dart';
import '../services/auth_manager.dart';
import '../services/pdf_itinerario_service.dart';
import 'mi_itinerario_second_screen.dart';

class ItinerarioFirstScreen extends StatefulWidget {
  const ItinerarioFirstScreen({super.key});

  @override
  State<ItinerarioFirstScreen> createState() => _ItinerarioFirstScreenState();
}

class _ItinerarioFirstScreenState extends State<ItinerarioFirstScreen> {
  List<Dia> listaDias = [];
  List<Dia> diasSeleccionados = [];
  Map<int, int> diaIdToDiaItinerarioId = {};
  int? itinerarioId;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final dias = await Dia.getDiasSemanaSanta();
    final userId = AuthManager().currentUser?['id'];
    
    List<Dia> seleccionados = [];
    Map<int, int> mapDiaItinerario = {};

    if (userId != null) {
      final itinerario = await ItinerarioApi.getOrCreateByUsuario(userId);
      itinerarioId = itinerario['id'];
      
      final diasGuardados = await ItinerarioApi.getDias(itinerarioId!);
      for (final diaIt in diasGuardados) {
        final idDia = diaIt['idDia'];
        final diaItId = diaIt['id'];
        mapDiaItinerario[idDia] = diaItId;
        final dia = dias.where((d) => d.id == idDia).firstOrNull;
        if (dia != null) {
          seleccionados.add(dia);
        }
      }
      seleccionados.sort((a, b) => a.id.compareTo(b.id));
    }

    setState(() {
      listaDias = dias;
      diasSeleccionados = seleccionados;
      diaIdToDiaItinerarioId = mapDiaItinerario;
      _cargando = false;
    });
  }

  Future<void> _descargarPdfGeneral() async {
    final userId = AuthManager().currentUser?['id'];
    if (userId == null) return;

    try {
      final entradas = await EntradaItinerarioExport.getEntradasItinerarioExport(userId);
      if (entradas.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay entradas en tu itinerario')),
          );
        }
        return;
      }
      final pdfBytes = await PdfItinerarioService.crearPdf(entradas);
      await Printing.sharePdf(bytes: pdfBytes, filename: 'mi_itinerario_semana_santa.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _mostrarSelectorDias() async {
    final seleccionadosIds = diasSeleccionados.map((d) => d.id).toSet();
    final seleccionTemporal = Set<int>.from(seleccionadosIds);

    final resultado = await showDialog<Set<int>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Selecciona los días'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: listaDias.length,
                  itemBuilder: (ctx, index) {
                    final dia = listaDias[index];
                    final marcado = seleccionTemporal.contains(dia.id);
                    return CheckboxListTile(
                      title: Text(dia.nombre),
                      value: marcado,
                      activeColor: const Color.fromARGB(255, 26, 19, 92),
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            seleccionTemporal.add(dia.id);
                          } else {
                            seleccionTemporal.remove(dia.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, seleccionTemporal),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado == null || itinerarioId == null) return;

    final diasToAdd = resultado.difference(seleccionadosIds);
    final diasToRemove = seleccionadosIds.difference(resultado);

    for (final idDia in diasToAdd) {
      final res = await ItinerarioApi.addDia(itinerarioId!, idDia);
      diaIdToDiaItinerarioId[idDia] = res['id'];
    }

    for (final idDia in diasToRemove) {
      final diaItId = diaIdToDiaItinerarioId[idDia];
      if (diaItId != null) {
        await ItinerarioApi.removeDia(itinerarioId!, diaItId);
        diaIdToDiaItinerarioId.remove(idDia);
      }
    }

    setState(() {
      diasSeleccionados = listaDias.where((d) => resultado.contains(d.id)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _mostrarSelectorDias,
              icon: const Icon(Icons.edit_calendar),
              label: const Text("Editar días de mi itinerario"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color.fromARGB(255, 26, 19, 92)),
                foregroundColor: const Color.fromARGB(255, 26, 19, 92),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: diasSeleccionados.isEmpty ? null : _descargarPdfGeneral,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Descargar itinerario completo"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: diasSeleccionados.isEmpty
                      ? Colors.grey
                      : const Color.fromARGB(255, 26, 19, 92),
                ),
                foregroundColor: const Color.fromARGB(255, 26, 19, 92),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: diasSeleccionados.isEmpty
                ? const Center(
                    child: Text(
                      'No has seleccionado ningún día.\nPulsa el botón superior para añadir días.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
              itemCount: diasSeleccionados.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final dia = diasSeleccionados[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItinerarioSecondScreen(idDia: dia.id, nombreDia: dia.nombre),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      backgroundColor: const Color.fromARGB(255, 26, 19, 92),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      dia.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}