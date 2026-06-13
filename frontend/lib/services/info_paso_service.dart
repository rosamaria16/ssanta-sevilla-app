import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';
const Duration requestTimeout = Duration(seconds: 10);

class InfoPaso {
  final int id;
  final String hora;
  final String tipoPaso;
  final String localizacion;
  final int idHermandad;
  final String? difHora;
  final bool esCarreraOficial;

  InfoPaso({
    required this.id,
    required this.hora,
    required this.tipoPaso,
    required this.localizacion,
    required this.idHermandad,
    this.difHora,
    this.esCarreraOficial = false,
  });

  factory InfoPaso.fromJson(Map<String, dynamic> json) {
    return InfoPaso(
      id: json['id'],
      hora: json['hora'],
      tipoPaso: json['tipoPaso'],
      localizacion: json['localizacion'],
      idHermandad: json['idHermandad'],
      difHora: json['difHora'],
      esCarreraOficial: (json['esCarreraOficial'] ?? 0) == 1,
    );
  }

  static Future<List<InfoPaso>> getByHermandad(int idHermandad) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/infopasos/hermandad/$idHermandad'),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((infopaso) => InfoPaso.fromJson(infopaso)).toList();
      } else if (response.statusCode >= 500) {
        throw Exception('Error en el servidor');
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<List<InfoPaso>> getByDia(int idDia) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/infopasos/dia/$idDia'),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((infopaso) => InfoPaso.fromJson(infopaso)).toList();
      } else if (response.statusCode >= 500) {
        throw Exception('Error en el servidor');
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
