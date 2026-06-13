import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';
const Duration requestTimeout = Duration(seconds: 10);

class AdminService {

  static Future<List<Map<String, dynamic>>> getDias(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/admin/dias?usuario_id=$usuarioId'),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos de administrador');
      } else if (response.statusCode >= 500) {
        throw Exception('Error en el servidor');
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<Map<String, dynamic>> actualizarFechasDesdeInicio(
    int usuarioId,
    String fechaInicio,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/admin/dias/fecha-inicio?usuario_id=$usuarioId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fecha_inicio': fechaInicio}),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos de administrador');
      } else if (response.statusCode == 404) {
        throw Exception('No hay días configurados');
      } else if (response.statusCode >= 500) {
        throw Exception('Error en el servidor');
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<Map<String, dynamic>> uploadInfopasosCsv(
    int usuarioId,
    String filePath,
    List<int> fileBytes,
    String fileName,
  ) async {
    try {
      final uri = Uri.parse(
        '$apiBaseUrl/admin/upload-infopasos?usuario_id=$usuarioId',
      );
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de conexión agotado');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['detail'] ?? 'Error en el archivo CSV');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos de administrador');
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
