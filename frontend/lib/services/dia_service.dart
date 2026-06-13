import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';
const Duration requestTimeout = Duration(seconds: 10);

class Dia {
  final int id;
  final String nombre;
  final DateTime fecha;

  Dia({
    required this.id,
    required this.nombre,
    required this.fecha
  });

  factory Dia.fromJson(Map<String, dynamic> json) {
    return Dia(
      id: json['id'],
      nombre: json['nombre'],
      fecha: DateTime.parse(json['fecha'])
    );
  }

  static Future<List<Dia>> getDiasSemanaSanta() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/dias/'),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((dia) => Dia.fromJson(dia)).toList();
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
