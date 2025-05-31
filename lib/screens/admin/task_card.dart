
import 'package:flutter/material.dart';
import 'package:agpop/models/task_model.dart';
import 'package:agpop/models/user_model.dart';
import 'package:agpop/models/position_model.dart';
import 'package:agpop/theme/app_theme.dart';
// import 'package:intl/intl.dart';
import 'package:agpop/widgets/custom_button.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final List<UserModel> assignedUsers; // Novos campos
  final List<PositionModel> assignedPositions; // Novos campos
  final bool isAdmin;
  final Function(TaskStatus) onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.assignedUsers, // Adicione ao construtor
    required this.assignedPositions, // Adicione ao construtor
    required this.isAdmin,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.started:
        return AppTheme.primaryColor; // Azul
      case TaskStatus.completed:
        return AppTheme.completedColor; // Verde
      case TaskStatus.cancelled:
        return AppTheme.errorColor; // Vermelho
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pendente';
      case TaskStatus.started:
        return 'Em Andamento';
      case TaskStatus.completed:
        return 'Concluída';
      case TaskStatus.cancelled:
        return 'Cancelada';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit, // Mantém a edição no clique do card
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<TaskStatus>(
                    icon: Icon(Icons.more_vert, color: AppTheme.subtitleTextColor),
                    onSelected: (TaskStatus newStatus) {
                      onStatusChanged(newStatus);
                    },
                    itemBuilder: (BuildContext context) {
                      return TaskStatus.values.map((status) {
                        return PopupMenuItem<TaskStatus>(
                          value: status,
                          child: Text(_getStatusText(status)),
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.subtitleTextColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppTheme.subtitleTextColor),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(task.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(task.status),
                      ),
                    ),
                  ),
                ],
              ),
              if (task.isRecurring)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.repeat, size: 16, color: AppTheme.subtitleTextColor),
                      const SizedBox(width: 4),
                      Text(
                        'Recorrência: ${task.recurrenceType ?? 'Não definido'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.subtitleTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              if (assignedUsers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.people, size: 18, color: AppTheme.subtitleTextColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: assignedUsers.map((user) {
                            return Tooltip( // Mostra o nome do usuário ao passar o mouse
                              message: user.name,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                                child: Text(
                                  user.name[0].toUpperCase(),
                                  style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

              if (assignedPositions.isNotEmpty)
                Row(
                  children: [
                    Icon(Icons.work_outline, size: 18, color: AppTheme.subtitleTextColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: assignedPositions.map((position) {
                          if (position.iconCodePoint != null) {
                            return Tooltip(
                              message: position.name,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  IconData(position.iconCodePoint!, fontFamily: 'MaterialIcons'),
                                  color: Colors.grey.shade600,
                                  size: 18,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }).toList(),
                      ),
                    ),
                  ],
                ),

              // Ações de Edição e Exclusão (se for admin)
              if (isAdmin) ...[
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: onDelete,
                      style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
                      child: const Text('Excluir'),
                    ),
                    const SizedBox(width: 8),
                    CustomButton(
                      text: 'Editar',
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onPressed: onEdit,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}