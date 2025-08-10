/// Modelo que representa una tarea.
///
/// Contiene información básica de la tarea como título, descripción,
/// estado de completado y el usuario al que pertenece.
///
/// Se encuentran los métodos para convertir desde y hacia JSON, para comunicarse con el servidor .
class Task {
  /// Identificador único de la tarea (puede ser nulo cuando se crea una nueva).
  final int? id;

  /// Título de la tarea (obligatorio).
  final String title;

  /// Descripción detallada de la tarea.
  final String description;

  /// Indica si la tarea está completada.
  final bool completed;

  /// ID del usuario propietario de la tarea (opcional).
  final String? userId;

  /// Constructor principal.
  Task({
    this.id,
    required this.title,
    required this.description,
    this.completed = false,
    this.userId,
  });

  /// Crea una instancia de [Task] a partir de un JSON recibido del backend.
  ///
  /// Usa valores por defecto si algunos campos vienen nulos.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      completed: json['completed'] ?? false,
      userId: json['userId'],
    );
  }

  /// Convierte esta instancia a un JSON para enviar al backend.
  ///
  /// Incluye el [id] solo si no es nulo (útil para crear o actualizar).
  Map<String, dynamic> toJson() {
    final data = {
      'title': title,
      'description': description,
      'completed': completed,
      'userId': userId,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }
}
