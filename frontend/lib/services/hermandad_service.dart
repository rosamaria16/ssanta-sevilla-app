import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class Hermandad {
  final int id;
  final String nombre;

  Hermandad({
    required this.id,
    required this.nombre
  });

  factory Hermandad.fromJson(Map<String, dynamic> json) {
    return Hermandad(
      id: json['id'],
      nombre: json['nombre']
    );
  }

  static Future<List<Hermandad>> getHermandadesDia(int idDia) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/hermandades/dia/$idDia'),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((hdad) => Hermandad.fromJson(hdad)).toList();
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
