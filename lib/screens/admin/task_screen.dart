import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agpop/models/task_model.dart';
import 'package:agpop/models/position_model.dart';
import 'package:agpop/models/user_model.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:agpop/widgets/loading_indicator.dart';
import 'package:agpop/widgets/task_card.dart';
import 'package:agpop/screens/admin/task_form_screen.dart';

class TaskScreen extends StatefulWidget {
  final String? initialTab;
  const TaskScreen({
    super.key,
    this.initialTab
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TaskModel> _tasks = [];
  List<UserModel> _users = [];
  List<PositionModel> _positions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    super.initState();
    int initialIndex = 0;
    if (widget.initialTab != null) {
      switch (widget.initialTab) {
        case 'pending':
          initialIndex = 1;
          break;
        case 'started':
          initialIndex = 2;
          break;
        case 'completed':
          initialIndex = 3;
          break;
        case 'all':
          initialIndex = 0;
          break;
      }
    }
    _tabController = TabController(length: 4, vsync: this, initialIndex: initialIndex);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final tasksSnapshot = await _firestore.collection('tasks').orderBy('createdAt', descending: true).get();
      final usersSnapshot = await _firestore.collection('users').get();
      final positionsSnapshot = await _firestore.collection('positions').get();

      setState(() {
        _tasks = tasksSnapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
        _users = usersSnapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
        _positions = positionsSnapshot.docs.map((doc) => PositionModel.fromFirestore(doc)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao carregar dados: $e'),
          backgroundColor: AppTheme.errorColor
        ));
        setState(() => _isLoading = false);
      }
    }
  }

  UserModel? _getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  PositionModel? _getPositionById(String positionId) {
    try {
      return _positions.firstWhere((pos) => pos.id == positionId);
    } catch (e) {
      return null;
    }
  }

  List<TaskModel> _getFilteredTasks(TaskStatus? status) {
    if (status == null) {
      return _tasks;
    }
    return _tasks.where((task) => task.status == status).toList();
  }

  Future<void> _navigateToTaskForm({TaskModel? task}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          task: task,
          availableUsers: _users,
          availablePositions: _positions
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _updateTaskStatus(TaskModel task, TaskStatus newStatus) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update({'status': newStatus.name});
      if (mounted) {
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao atualizar status da tarefa: $e'),
          backgroundColor: AppTheme.errorColor
        ));
      }
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir esta tarefa? Esta ação é irreversível.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Excluir')
          )
        ]
      )
    );

    if (confirmDelete == true) {
      try {
        await _firestore.collection('task_user').where('task_id', isEqualTo: task.id).get().then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

        await _firestore.collection('task_position').where('task_id', isEqualTo: task.id).get().then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.delete();
          }
        });

        await _firestore.collection('tasks').doc(task.id).delete();

        if (mounted) {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tarefa "${task.title}" excluída com sucesso!'), backgroundColor: AppTheme.completedColor));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao excluir tarefa: $e'),
            backgroundColor: AppTheme.errorColor
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gerenciar Tarefas')),
        body: const LoadingIndicator()
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Tarefas'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.accentColor,
          unselectedLabelColor: Colors.white,
          indicatorColor: AppTheme.primaryColor,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Pendentes'),
            Tab(text: 'Em Andamento'),
            Tab(text: 'Concluídas')
          ]
        )
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(_getFilteredTasks(null)),
          _buildTaskList(_getFilteredTasks(TaskStatus.pending)),
          _buildTaskList(_getFilteredTasks(TaskStatus.started)),
          _buildTaskList(_getFilteredTasks(TaskStatus.completed))
        ]
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToTaskForm(),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Nova Tarefa')
      )
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: AppTheme.subtitleTextColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Nenhuma tarefa encontrada', style: TextStyle(color: AppTheme.subtitleTextColor, fontSize: 16))
          ]
        )
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final List<UserModel> assignedUsers = task.assignedUserIds
              .map((id) => _getUserById(id))
              .whereType<UserModel>()
              .toList();
          final List<PositionModel> assignedPositions = task.assignedPositionIds
              .map((id) => _getPositionById(id))
              .whereType<PositionModel>()
              .toList();

          return TaskCard(
            task: task,
            assignedUsers: assignedUsers,
            assignedPositions: assignedPositions,
            isAdmin: true,
            onStatusChanged: (newStatus) => _updateTaskStatus(task, newStatus),
            onEdit: () => _navigateToTaskForm(task: task),
            onDelete: () => _deleteTask(task)
          );
        }
      )
    );
  }
}