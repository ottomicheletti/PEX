import 'package:flutter/material.dart';
import 'package:agpop/models/task_model.dart';
import 'package:agpop/models/user_model.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:agpop/widgets/task_card.dart';
import 'package:agpop/widgets/loading_indicator.dart';
import 'package:agpop/services/firebase_service.dart';
import 'package:intl/intl.dart';

class EmployeeHome extends StatefulWidget {
  final UserModel user;
  
  const EmployeeHome({
    super.key,
    required this.user,
  });

  @override
  State<EmployeeHome> createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> with SingleTickerProviderStateMixin {
  final _firebaseService = FirebaseService();
  late TabController _tabController;
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _firebaseService.getTasksForUser(widget.user.id);
      
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar tarefas: ${error.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<TaskModel> _getFilteredTasks(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    final today = DateTime.now();
    final formatter = DateFormat('EEEE, d MMMM', 'pt_BR');
    final formattedDate = formatter.format(today);

    return Column(
      children: [
        // Cabeçalho com data
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.subtitleTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Suas tarefas de hoje',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Abas para filtrar tarefas
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.subtitleTextColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Pendentes'),
            Tab(text: 'Em Andamento'),
            Tab(text: 'Concluídas'),
          ],
        ),
        
        // Conteúdo das abas
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTaskList(_getFilteredTasks(TaskStatus.pending)),
              _buildTaskList(_getFilteredTasks(TaskStatus.started)),
              _buildTaskList(_getFilteredTasks(TaskStatus.completed)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: AppTheme.subtitleTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma tarefa encontrada',
              style: TextStyle(
                color: AppTheme.subtitleTextColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onStatusChanged: (newStatus) async {
              try {
                await _firebaseService.updateTaskStatus(task.id, newStatus);
                if (mounted) {
                  _loadTasks();
                }
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao atualizar tarefa: ${error.toString()}'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}
