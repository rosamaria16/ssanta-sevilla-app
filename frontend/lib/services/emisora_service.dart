import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class Emisora {
  final int id;
  final String nombre;
  final String urlStream;
  final String urlImagen;

  Emisora({
    required this.id,
    required this.nombre,
    required this.urlStream,
    required this.urlImagen,
  });

  factory Emisora.fromJson(Map<String, dynamic> json) {
    return Emisora(
      id: json['id'],
      nombre: json['nombre'],
      urlStream: json['urlStream'],
      urlImagen: json['urlImagen'],
    );
  }

  static Future<List<Emisora>> getEmisoras() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/emisoras/'),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((e) => Emisora.fromJson(e)).toList();
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
