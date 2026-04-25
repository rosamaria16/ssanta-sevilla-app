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

// Dia (para poder sacar los datos de la BD)
class Dia {
  final int id;
  final String nombre;

  Dia({
    required this.id,
    required this.nombre
  });

  factory Dia.fromJson(Map<String, dynamic> json) {
    return Dia(
      id: json['id'],
      nombre: json['nombre']
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

// Dia (para poder sacar los datos de la BD)
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

class InfoPaso {
  final int id;
  final String hora;
  final String tipoPaso;
  final String localizacion;
  final int idHermandad;
  final String? difHora;

  InfoPaso({
    required this.id,
    required this.hora,
    required this.tipoPaso,
    required this.localizacion,
    required this.idHermandad,
    this.difHora,
  });

  factory InfoPaso.fromJson(Map<String, dynamic> json) {
    return InfoPaso(
      id: json['id'],
      hora: json['hora'],
      tipoPaso: json['tipoPaso'],
      localizacion: json['localizacion'],
      idHermandad: json['idHermandad'],
      difHora: json['difHora'],
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

class ItinerarioApi {
  static Future<Map<String, dynamic>> getOrCreateByUsuario(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/itinerarios/usuario/$userId'),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        final createResponse = await http.post(
          Uri.parse('$apiBaseUrl/itinerarios/'),
          body: json.encode({'idUsuario': userId}),
        ).timeout(requestTimeout, onTimeout: () {
          throw Exception('Tiempo de conexión agotado');
        });

        if (createResponse.statusCode == 201) {
          final data = json.decode(createResponse.body);
          data['items'] = [];
          return data;
        }
        throw Exception('Error al crear itinerario');
      } else if (response.statusCode >= 500) {
        throw Exception('Error en el servidor');
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<Map<String, dynamic>> addItem(int itinerarioId, int idInfoPaso) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/itinerarios/$itinerarioId/items'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idInfoPaso': idInfoPaso}),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode >= 500) {
        throw Exception('Error en el servidor');
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<void> removeItem(int itinerarioId, int itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/itinerarios/$itinerarioId/items/$itemId'),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode != 204) {
        throw Exception('Error al eliminar elemento');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}