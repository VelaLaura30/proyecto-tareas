import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/task.dart';
import '../services/user_service.dart';

/// Servicio para realizar operaciones HTTP relacionadas con tareas.
///
/// Incluye verificación de conexión a internet, manejo de respuestas y
/// métodos para obtener, crear, actualizar y eliminar tareas.
class ApiService {
  /// URL base del endpoint para las tareas.
  static const String baseUrl = 'https://task-manager-production-27af.up.railway.app/api/tasks';

  /// Verifica si hay conexión a internet disponible.
  ///
  /// Usa la librería [connectivity_plus].
  /// Retorna `true` si hay conexión, `false` si no.
  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Maneja la respuesta HTTP verificando el código de estado.
  ///
  /// Si el código es 2xx, decodifica y retorna el JSON.
  /// Si hay error, lanza una excepción con mensaje adecuado.
  static dynamic _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    } else {
      try {
        final body = jsonDecode(res.body);
        if (body['message'] != null) {
          if (body['message'] is List) {
            throw Exception(body['message'].join('\n'));
          } else {
            throw Exception(body['message']);
          }
        }
      } catch (_) {}

      switch (res.statusCode) {
        case 401:
          throw Exception('Sesión expirada. Por favor inicia sesión de nuevo.');
        case 500:
          throw Exception('Error interno del servidor. Intenta más tarde.');
        default:
          throw Exception('Error desconocido (${res.statusCode})');
      }
    }
  }

  /// Obtiene la lista de tareas para el usuario actual.
  ///
  /// Lanza excepción si no hay conexión o si el servidor responde con error.
  static Future<List<Task>> getTasks() async {
    final hasConnection = await hasInternetConnection();
    if (!hasConnection) {
      throw Exception('No hay conexión a internet. Por favor, verifica tu red.');
    }

    final userId = await UserService.getUserId();

    final res = await http
        .get(Uri.parse('$baseUrl?userId=$userId'))
        .timeout(const Duration(seconds: 5), onTimeout: () {
      throw Exception('El servidor no responde. Por favor intenta más tarde.');
    });

    final data = _handleResponse(res);
    return (data as List).map((e) => Task.fromJson(e)).toList();
  }

  /// Crea una nueva tarea en el servidor.
  ///
  /// Retorna la tarea creada con su ID asignado.
  /// Lanza excepción si no hay conexión o error del servidor.
  static Future<Task> createTask(Task task) async {
    final hasConnection = await hasInternetConnection();
    if (!hasConnection) {
      throw Exception('No hay conexión a internet. Por favor, verifica tu red.');
    }

    final res = await http
        .post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    )
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('El servidor no responde. Por favor intenta más tarde.');
    });

    final data = _handleResponse(res);
    return Task.fromJson(data);
  }

  /// Actualiza una tarea existente en el servidor.
  ///
  /// Retorna la tarea actualizada.
  /// Lanza excepción si no hay conexión o error del servidor.
  static Future<Task> updateTask(Task task) async {
    final hasConnection = await hasInternetConnection();
    if (!hasConnection) {
      throw Exception('No hay conexión a internet. Por favor, verifica tu red.');
    }

    final url = Uri.parse('$baseUrl/${task.id}');
    final body = jsonEncode({
      "title": task.title,
      "description": task.description,
      "completed": task.completed,
      "userId": task.userId,
    });

    final res = await http
        .put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    )
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('El servidor no responde. Por favor intenta más tarde.');
    });

    final data = _handleResponse(res);
    return Task.fromJson(data);
  }

  /// Elimina una tarea del servidor dado su [id].
  ///
  /// Lanza excepción si no hay conexión o si la eliminación falla.
  static Future<void> deleteTask(int id) async {
    final hasConnection = await hasInternetConnection();
    if (!hasConnection) {
      throw Exception('No hay conexión a internet. Por favor, verifica tu red.');
    }

    final res = await http
        .delete(Uri.parse('$baseUrl/$id'))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('El servidor no responde. Por favor intenta más tarde.');
    });

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Error al eliminar tarea');
    }
  }
}
