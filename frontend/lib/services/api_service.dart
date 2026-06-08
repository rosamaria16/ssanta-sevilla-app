import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_manager.dart';

const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1';
const Duration requestTimeout = Duration(seconds: 10);

class ApiService {
  //Login
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
        throw Exception('Email o contraseña incorrectos');
      } else if (response.statusCode >= 500) {
        throw Exception('Error en el servidor');
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  //Registro
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

  //Actualizar perfil (nombre y/o email)
  static Future<Map<String, dynamic>> updateProfile(
    int userId, {
    String? nombre,
    String? email,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nombre != null) body['nombre'] = nombre;
      if (email != null) body['email'] = email;

      final response = await http.put(
        Uri.parse('$apiBaseUrl/usuarios/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        AuthManager().setUser(data);
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else if (response.statusCode >= 500) {
        throw Exception('Error en el servidor');
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  //Cambiar contraseña
  static Future<void> changePassword(
    int userId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/usuarios/$userId/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contrasena_actual': currentPassword,
          'contrasena_nueva': newPassword,
        }),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 400) {
        throw Exception('La contraseña actual es incorrecta');
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else if (response.statusCode >= 500) {
        throw Exception('Error en el servidor');
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  //Logout
  static void logout() {
    AuthManager().logout();
  }
}

//Dia (para poder sacar los datos de la BD)
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

//Dia (para poder sacar los datos de la BD)
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
          headers: {'Content-Type': 'application/json'},
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

  static Future<List<Map<String, dynamic>>> getDias(int itinerarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/itinerarios/$itinerarioId/dias'),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode >= 500) {
        throw Exception('Error en el servidor');
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  static Future<Map<String, dynamic>> addDia(int itinerarioId, int idDia) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/itinerarios/$itinerarioId/dias'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idDia': idDia}),
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

  static Future<void> removeDia(int itinerarioId, int diaItinerarioId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/itinerarios/$itinerarioId/dias/$diaItinerarioId'),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode != 204) {
        throw Exception('Error al eliminar día del itinerario');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}


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

  static Future<Map<String, dynamic>> actualizarFechaDia(
    int usuarioId,
    int diaId,
    String fecha,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/admin/dias/$diaId/fecha?usuario_id=$usuarioId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'fecha': fecha}),
      ).timeout(requestTimeout, onTimeout: () {
        throw Exception('Tiempo de conexión agotado');
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos de administrador');
      } else if (response.statusCode == 404) {
        throw Exception('Día no encontrado');
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