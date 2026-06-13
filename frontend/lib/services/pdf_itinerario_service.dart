import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:frontend/services/itinerario_service.dart';
import 'package:frontend/utils/tipopaso_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfItinerarioService {
  static Future<Uint8List> crearPdf(
    List<EntradaItinerarioExport> entradas, {
    String? diaFiltro,
  }) async {
    final pdf = pw.Document();

    final entradasFiltradas = diaFiltro != null
        ? entradas.where((e) => e.dia == diaFiltro).toList()
        : entradas;

    final Map<String, List<EntradaItinerarioExport>> entradasPorDia = {};
    for (final entrada in entradasFiltradas) {
      entradasPorDia.putIfAbsent(entrada.dia, () => []).add(entrada);
    }

    final titulo = diaFiltro != null
        ? 'Mi Itinerario - $diaFiltro'
        : 'Mi Itinerario - Semana Santa';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final List<pw.Widget> widgets = [
            pw.Text(
              titulo,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
          ];

          for (final dia in entradasPorDia.keys) {
            final entradasDia = entradasPorDia[dia]!;
            final fechaFormateada = DateFormat('dd/MM/yyyy').format(entradasDia.first.fecha);

            widgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
                child: pw.Text(
                  '$dia - $fechaFormateada',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            );

            widgets.add(
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerLeft,
                },
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                headers: ['Hora', 'Hermandad', 'Paso', 'Localización'],
                data: entradasDia.map((e) {
                  final style = e.esCarreraOficial
                      ? pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)
                      : const pw.TextStyle(fontSize: 9);
                  final horaSinSegundos = e.hora.length >= 5 ? e.hora.substring(0, 5) : e.hora;
                  return [
                    pw.Text(horaSinSegundos, style: style),
                    pw.Text(e.hermandad, style: style),
                    pw.Text(displayTipoPaso(e.tipoPaso), style: style),
                    pw.Text(e.localizacion, style: style),
                  ];
                }).toList(),
              ),
            );
          }

          return widgets;
        },
      ),
    );
    return pdf.save();
  }
}
