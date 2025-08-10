import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Servicio para gestionar el identificador único del usuario.
///
/// Guarda el [userId] en SharedPreferences para persistencia local.
/// Si no existe un ID guardado, genera uno nuevo usando UUID y lo guarda.
class UserService {
  static const String _userIdKey = 'user_id';
  static const Uuid _uuid = Uuid();

  /// Obtiene el ID único del usuario almacenado localmente.
  ///
  /// Si no existe un ID guardado, crea uno nuevo, lo almacena y lo retorna.
  /// En caso de error, genera y retorna un nuevo UUID sin almacenarlo.
  static Future<String> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString(_userIdKey);

      if (userId == null || userId.isEmpty) {
        userId = _uuid.v4();
        await prefs.setString(_userIdKey, userId);
        print('Nuevo usuario creado con ID: $userId');
      } else {
        print('Usuario existente con ID: $userId');
      }

      return userId;
    } catch (e) {
      print('Error al obtener/crear userId: $e');
      return _uuid.v4();
    }
  }
}
