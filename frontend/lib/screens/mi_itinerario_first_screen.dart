import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../services/dia_service.dart';
import '../services/itinerario_service.dart';
import '../services/auth_manager.dart';
import '../services/pdf_itinerario_service.dart';
import '../utils/app_theme.dart';
import '../utils/hora_utils.dart';
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
          AppSnackBar.show(context, message: 'No hay entradas en tu itinerario');
        }
        return;
      }
      final pdfBytes = await PdfItinerarioService.crearPdf(entradas);
      await Printing.sharePdf(bytes: pdfBytes, filename: 'mi_itinerario_semana_santa.pdf');
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Error al generar PDF: ${e.toString()}',
          isError: true,
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
                      activeColor: AppColors.primary,
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

    return Column(
      children: [
        // Acciones superiores
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.edit_calendar,
                  label: 'Editar días',
                  onTap: _mostrarSelectorDias,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.picture_as_pdf,
                  label: 'Descargar PDF',
                  onTap: diasSeleccionados.isEmpty ? null : _descargarPdfGeneral,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Lista de días
        Expanded(
          child: diasSeleccionados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_note, size: 56, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      const Text(
                        'No has seleccionado ningún día',
                        style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Pulsa "Editar días" para añadir',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: diasSeleccionados.length,
                  itemBuilder: (context, index) {
                    final dia = diasSeleccionados[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ItinerarioSecondScreen(
                                  idDia: dia.id,
                                  nombreDia: dia.nombre,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 62,
                                  height: 72,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      bottomLeft: Radius.circular(14),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${dia.fecha.day}',
                                        style: const TextStyle(
                                          color: AppColors.primaryDark,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          height: 1.1,
                                        ),
                                      ),
                                      Text(
                                        mesesDelAnyo[dia.fecha.month],
                                        style: const TextStyle(
                                          color: AppColors.primaryDark,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 20,
                                    ),
                                    child: Text(
                                      dia.nombre,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Icon(
                                    Icons.chevron_right,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.surface : AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? AppColors.border : AppColors.divider,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: enabled ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: enabled ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}