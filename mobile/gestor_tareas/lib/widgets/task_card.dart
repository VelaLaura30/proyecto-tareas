import 'package:flutter/material.dart';
import '../models/task.dart';

/// Widget que representa una tarjeta visual para mostrar la información de una tarea.
///
/// Muestra el título, descripción y estado de la tarea (completada o pendiente),
/// con acciones para marcar como completada, editar o eliminar la tarea.
///
/// Recibe callbacks para manejar cada una de esas acciones.
class TaskCard extends StatelessWidget {
  /// La tarea que se va a mostrar en la tarjeta.
  final Task task;

  /// Callback para cuando el usuario toca el checkbox para marcar/completar la tarea.
  final VoidCallback onToggleComplete;

  /// Callback para cuando el usuario toca el botón de editar.
  final VoidCallback onEdit;

  /// Callback para cuando el usuario toca el botón de eliminar.
  final VoidCallback onDelete;

  /// Constructor que recibe la tarea y los callbacks para las acciones.
  const TaskCard({
    Key? key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: task.completed ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.completed ? Colors.grey[200]! : Colors.grey[100]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [

            // Checkbox personalizado para marcar la tarea como completada o no.
            GestureDetector(
              onTap: onToggleComplete,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.completed ? Colors.green : Colors.grey[300]!,
                    width: 2,
                  ),
                  color: task.completed ? Colors.green : Colors.transparent,
                ),
                child: task.completed
                    ? const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                )
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            // Información principal: título, descripción, estado y botones.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Título de la tarea
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: task.completed ? Colors.grey[500] : Colors.black87,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),

                  // Descripción, si existe
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: task.completed ? Colors.grey[400] : Colors.grey[600],
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Fila con estado y botones editar / eliminar
                  Row(
                    children: [
                      // Etiqueta de estado (completada o pendiente)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: task.completed ? Colors.green[100] : Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: task.completed ? Colors.green[200]! : Colors.blue[200]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          task.completed ? 'Completada' : 'Pendiente',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: task.completed ? Colors.green[700] : Colors.blue[700],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Botones editar y eliminar
                      Row(
                        children: [
                          GestureDetector(
                            onTap: onEdit,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.indigo[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.indigo[600],
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Colors.red[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
