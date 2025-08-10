import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/user_service.dart';
import '../services/api_service.dart';

/// Pantalla para crear o editar una tarea.
///
/// Recibe una función [onTaskSaved] que se ejecuta cuando se guarda la tarea.
/// Opcionalmente, recibe una tarea existente para editarla.
class AddTaskScreen extends StatefulWidget {
  /// Callback que se llama con la tarea guardada al crear o actualizar.
  final Function(Task) onTaskSaved;

  /// Tarea existente para editar. Si es nulo, se crea una nueva.
  final Task? task;

  AddTaskScreen({required this.onTaskSaved, this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _description;
  late bool _completed;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // Inicializa campos con datos de la tarea o valores por defecto
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _completed = widget.task?.completed ?? false;

    // Configuración de animaciones para la entrada de formulario
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    // Libera recursos del controlador de animación
    _animationController.dispose();
    super.dispose();
  }

  /// Guarda la tarea creando o actualizando en el backend.
  ///
  /// Valida el formulario, obtiene el userId, construye la tarea y llama al servicio API.
  /// Muestra indicador de carga y mensajes de error en Snackbar si falla.
  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Obtiene el userId, ya sea de la tarea existente o del usuario actual
      final userId = widget.task?.userId ?? await UserService.getUserId();

      final task = Task(
        id: widget.task?.id,
        title: _title,
        description: _description,
        completed: _completed,
        userId: userId,
      );

      setState(() => _loading = true);

      try {
        if (task.id == null) {
          await ApiService.createTask(task);
        } else {
          await ApiService.updateTask(task);
        }

        // Cierra pantalla devolviendo la tarea guardada
        Navigator.pop(context, task);
      } catch (e) {
        // Muestra error en snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll("ERROR: ", ""),
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // AppBar con gradiente y botón de retroceso
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isEditing
                        ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
                        : [const Color(0xFF4F46E5), const Color(0xFF7C3AED), const Color(0xFFEC4899)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                isEditing ? Icons.edit : Icons.add_task,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isEditing ? 'Editar Tarea' : 'Nueva Tarea',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    isEditing
                                        ? 'Actualiza los detalles de tu tarea'
                                        : 'Crea una nueva tarea',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Formulario con animaciones de entrada
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // Campo de título con validación
                        _buildInputCard(
                          child: TextFormField(
                            initialValue: _title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Título de la tarea',
                              labelStyle: TextStyle(color: Colors.indigo[300]),
                              prefixIcon: Icon(Icons.title, color: Colors.indigo[400]),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingresa un título';
                              }
                              if (value.trim().length < 2) {
                                return 'El título debe tener al menos 2 caracteres';
                              }
                              return null;
                            },
                            onSaved: (value) => _title = value!.trim(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Campo descripción con varias líneas
                        _buildInputCard(
                          child: TextFormField(
                            initialValue: _description,
                            maxLines: 4,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                              labelStyle: TextStyle(color: Colors.indigo[300]),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 60),
                                child: Icon(Icons.description, color: Colors.indigo[400]),
                              ),
                              border: InputBorder.none,
                              alignLabelWithHint: true,
                            ),
                            onSaved: (value) => _description = value ?? '',
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Switch para marcar tarea completada o pendiente
                        _buildInputCard(
                          child: SwitchListTile(
                            title: Text(
                              'Marcar como completada',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[800]),
                            ),
                            subtitle: Text(
                              _completed ? 'Esta tarea está completa' : 'Esta tarea está pendiente',
                              style: TextStyle(
                                fontSize: 14,
                                color: _completed ? Colors.green[600] : Colors.orange[600],
                              ),
                            ),
                            value: _completed,
                            activeColor: Colors.green,
                            onChanged: (value) => setState(() => _completed = value),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Botón para guardar o actualizar tarea, o indicador de carga
                        _loading
                            ? Center(child: CircularProgressIndicator())
                            : Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isEditing
                                  ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
                                  : [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (isEditing ? const Color(0xFF667EEA) : const Color(0xFF4F46E5))
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _saveTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(isEditing ? Icons.update : Icons.save, color: Colors.white, size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  isEditing ? 'Actualizar Tarea' : 'Crear Tarea',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta blanca con sombra para envolver inputs.
  ///
  /// Recibe un widget hijo para mostrar dentro de la tarjeta.
  Widget _buildInputCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }
}
