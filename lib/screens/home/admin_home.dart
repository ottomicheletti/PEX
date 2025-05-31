import 'package:flutter/material.dart';
import 'package:agpop/models/user_model.dart';
import 'package:agpop/repositories/position_repository.dart';
import 'package:agpop/repositories/task_repository.dart';
import 'package:agpop/repositories/user_repository.dart';
import 'package:agpop/routes.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:agpop/widgets/dashboard_card.dart';

class AdminHome extends StatefulWidget {
  final UserModel user;
  
  const AdminHome({
    super.key,
    required this.user,
  });

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {

  final _userRepository = UserRepository();
  final _positionRepository = PositionRepository();
  final _taskRepository = TaskRepository();

  int _userCount = 0;
  int _positionCount = 0;
  int _taskCount = 0;
  int _pendingTaskCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final userCount = await _userRepository.getCount();
      final positionCount = await _positionRepository.getCount();
      final taskCount = await _taskRepository.getCount();
      // final positions = await _firebaseService.getAllPositions();
      // final tasks = await _firebaseService.getAllTasks();
      // final pendingTasks = await _firebaseService.getAllTasks(status: TaskStatus.pending);
      
      if (mounted) {
        setState(() {
          _userCount = userCount;
          _positionCount = positionCount;
          _taskCount = taskCount;
          // _pendingTaskCount = pendingTasks.length;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: ${error.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Text(
              'Bem-vindo, ${widget.user.name}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gerencie sua equipe e tarefas',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.subtitleTextColor,
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'Usuários',
                    value: _userCount.toString(),
                    icon: Icons.people_outline,
                    color: AppTheme.primaryColor,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.users);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    title: 'Funções',
                    value: _positionCount.toString(),
                    icon: Icons.work_outline,
                    color: AppTheme.secondaryColor,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.positions);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'Tarefas',
                    value: _taskCount.toString(),
                    icon: Icons.task_alt,
                    color: AppTheme.accentColor,
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.tasks);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    title: 'Pendentes',
                    value: _pendingTaskCount.toString(),
                    icon: Icons.pending_actions,
                    color: AppTheme.pendingColor,
                    onTap: () {
                      // Implementar filtro de tarefas pendentes
                      Navigator.of(context).pushNamed(AppRoutes.tasks);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Seção de gerenciamento
            Text(
              'Gerenciamento',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Lista de opções de gerenciamento
            _buildManagementOption(
              context,
              title: 'Gerenciar Usuários',
              subtitle: 'Adicionar, editar ou remover usuários',
              icon: Icons.people,
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.users);
              },
            ),
            _buildManagementOption(
              context,
              title: 'Gerenciar Funções',
              subtitle: 'Configurar funções e permissões',
              icon: Icons.work,
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.positions);
              },
            ),
            _buildManagementOption(
              context,
              title: 'Gerenciar Tarefas',
              subtitle: 'Criar e atribuir tarefas',
              icon: Icons.assignment,
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.tasks);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
