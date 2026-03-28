import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_manager.dart';

const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';
const Duration requestTimeout = Duration(seconds: 10);

class ApiService {
  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'contrasena': password,
        }),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        AuthManager().setUser(data['usuario'] ?? data);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Credenciales inválidas');
      } else if (response.statusCode >= 500) {
        throw Exception('Error en el servidor');
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Registro
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String nombre,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/usuarios/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'contrasena': password,
          'nombre': nombre,
        }),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        AuthManager().setUser(data['usuario'] ?? data);
        return data;
      } else if (response.statusCode == 400) {
        throw Exception('Email ya registrado');
      } else if (response.statusCode >= 500) {
        throw Exception('Error en el servidor');
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Logout
  static void logout() {
    AuthManager().logout();
  }
}
