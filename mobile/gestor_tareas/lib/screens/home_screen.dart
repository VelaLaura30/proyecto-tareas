import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

/// Pantalla principal que muestra la lista de tareas del usuario.
///
/// Permite filtrar tareas por estado (todas, próximas, hechas),
/// crear, editar, eliminar y marcar tareas como completadas.
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  /// Futuro que carga las tareas desde la API.
  late Future<List<Task>> _futureTasks;

  /// Controlador para animaciones de entrada.
  late AnimationController _animationController;

  /// Animación de opacidad para transición suave.
  late Animation<double> _fadeAnimation;

  /// Índice de pestaña seleccionada para filtrado.
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadTasks();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Carga las tareas desde la API con manejo de errores.
  void _loadTasks() {
    setState(() {
      _futureTasks = _getTasksWithErrorHandling();
    });
  }

  /// Obtiene las tareas y maneja errores mostrando un Snackbar.
  Future<List<Task>> _getTasksWithErrorHandling() async {
    try {
      return await ApiService.getTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      return [];
    }
  }

  /// Añade una tarea nueva asociada al usuario actual.
  Future<void> _addTask(Task task) async {
    try {
      final userId = await UserService.getUserId();
      final taskWithUser = Task(
        title: task.title,
        description: task.description,
        completed: task.completed,
        userId: userId,
      );

      await ApiService.createTask(taskWithUser);
      _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  /// Actualiza una tarea existente.
  Future<void> _updateTask(Task task) async {
    try {
      await ApiService.updateTask(task);
      _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  /// Elimina una tarea por su ID.
  Future<void> _deleteTask(int id) async {
    try {
      await ApiService.deleteTask(id);
      _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  /// Cambia el estado completado de una tarea y actualiza.
  Future<void> _toggleComplete(Task task) async {
    try {
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        completed: !task.completed,
        userId: task.userId,
      );
      await ApiService.updateTask(updatedTask);
      _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  /// Filtra las tareas según la pestaña seleccionada:
  /// 0 - Todas, 1 - Pendientes, 2 - Completadas.
  List<Task> _filterTasks(List<Task> tasks) {
    switch (_selectedTab) {
      case 1:
        return tasks.where((task) => !task.completed).toList();
      case 2:
        return tasks.where((task) => task.completed).toList();
      case 0:
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<List<Task>>(
        future: _futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Muestra un loader mientras carga las tareas
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            );
          } else if (snapshot.hasError) {
            // Muestra mensaje de error con opción a reintentar
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTasks,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else {
            final allTasks = snapshot.data ?? [];
            final filteredTasks = _filterTasks(allTasks);
            final completedCount = allTasks.where((t) => t.completed).length;
            final totalCount = allTasks.length;
            final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;

            return FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeader(allTasks, completedCount, totalCount, progress),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _buildStatsSection(allTasks, completedCount, totalCount),
                  ),

                  if (filteredTasks.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyState())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final task = filteredTasks[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                            child: TaskCard(
                              task: task,
                              onToggleComplete: () => _toggleComplete(task),
                              onEdit: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddTaskScreen(
                                      task: task,
                                      onTaskSaved: _updateTask,
                                    ),
                                  ),
                                );
                                _loadTasks();
                              },
                              onDelete: () => _showDeleteDialog(task),
                            ),
                          );
                        },
                        childCount: filteredTasks.length,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// Construye el encabezado con saludo y barra de progreso.
  Widget _buildHeader(List<Task> allTasks, int completedCount, int totalCount, double progress) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4F46E5),
            Color(0xFF7C3AED),
            Color(0xFFEC4899),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Hola!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Tienes ${allTasks.where((t) => !t.completed).length} tareas pendientes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.indigo[100],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$completedCount de $totalCount tareas completadas',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.indigo[100],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la sección de estadísticas y filtro de tareas.
  Widget _buildStatsSection(List<Task> allTasks, int completedCount, int totalCount) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildTab('Todas las tareas', 0),
                _buildTab('Próximas', 1),
                _buildTab('Hechas', 2),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pendientes',
                  '${allTasks.where((t) => !t.completed).length}',
                  Icons.circle_outlined,
                  Colors.indigo,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Completadas',
                  '$completedCount',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              Expanded(
                flex: 2,
                child: _buildStatCard(
                  'Total',
                  '$totalCount',
                  Icons.list_alt,
                  Colors.orange,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Tareas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: _loadTasks,
                icon: const Icon(Icons.refresh, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Widget que muestra cuando no hay tareas disponibles.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay tareas aquí',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega una nueva tarea con el botón +',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el botón flotante para agregar nuevas tareas.
  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(onTaskSaved: _addTask),
            ),
          );
          _loadTasks();
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  /// Construye una pestaña para filtrar tareas.
  ///
  /// [title] es el texto visible en la pestaña,
  /// [index] es el índice que representa la pestaña.
  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.indigo : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  /// Construye una tarjeta para mostrar estadísticas.
  ///
  /// [label] texto descriptivo,
  /// [value] valor numérico,
  /// [icon] icono representativo,
  /// [color] color del icono.
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: color, size: 24),
        ],
      ),
    );
  }

  /// Muestra diálogo para confirmar eliminación de tarea.
  void _showDeleteDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Tarea'),
        content: Text('¿Estás seguro de que deseas eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTask(task.id!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
