import 'package:flutter/material.dart';
import 'package:agpop/models/task_model.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:agpop/models/user_model.dart'; // Importar UserModel
import 'package:agpop/models/position_model.dart'; // Importar PositionModel

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final Function(TaskStatus)? onStatusChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAdmin;
  final List<UserModel> assignedUsers; // Adicionado para receber usuários atribuídos
  final List<PositionModel> assignedPositions; // Adicionado para receber posições atribuídas

  const TaskCard({
    super.key,
    required this.task,
    this.onStatusChanged,
    this.onEdit,
    this.onDelete,
    this.isAdmin = false,
    this.assignedUsers = const [], // Valor padrão vazio
    this.assignedPositions = const [], // Valor padrão vazio
  });

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return AppTheme.pendingColor;
      case TaskStatus.started:
        return AppTheme.startedColor;
      case TaskStatus.completed:
        return AppTheme.completedColor;
      case TaskStatus.cancelled:
        return AppTheme.cancelledColor;
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

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.pending_actions;
      case TaskStatus.started:
        return Icons.play_circle_outline;
      case TaskStatus.completed:
        return Icons.check_circle_outline;
      case TaskStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(task.status).withOpacity(0.2),
          child: Icon(
            _getStatusIcon(task.status),
            color: _getStatusColor(task.status),
          ),
        ),
        title: Text(
          task.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(task.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(task.status),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(task.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (task.isRecurring) // Mostrar se a tarefa é recorrente
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Recorrência: ${task.recurrenceType?.displayName ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.subtitleTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Descrição:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(task.description.isNotEmpty ? task.description : 'Nenhuma descrição fornecida.'),
                const SizedBox(height: 16),

                // Exibir atribuição por Usuário(s)
                if (assignedUsers.isNotEmpty) ...[
                  const Text(
                    'Atribuído(s) a:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: assignedUsers.map((user) => Chip(
                      label: Text(user.name),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: AppTheme.primaryColor),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Exibir atribuição por Posição(ões)
                if (assignedPositions.isNotEmpty) ...[
                  const Text(
                    'Atribuído(s) à Posição:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ChipTheme(
                    data: ChipThemeData.fromDefaults(
                      brightness: Brightness.light,
                      secondaryColor: AppTheme.secondaryColor,
                      labelStyle: TextStyle(
                        color: AppTheme.secondaryColor,
                        fontSize: 16.0,
                      ),
                    ).copyWith(
                      backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                      ),
                      side: BorderSide.none, // Extra segurança
                    ),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: assignedPositions.map(
                            (position) => Chip(
                          label: Text(position.name,
                          style: TextStyle(color: AppTheme.secondaryColor),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide.none, // Ref ref: sem borda
                          ),
                          backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                        ),
                      ).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Ações
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onStatusChanged != null && task.status != TaskStatus.completed) ...[
                      TextButton.icon(
                        icon: Icon(
                          task.status == TaskStatus.pending ? Icons.play_arrow : Icons.check,
                          color: task.status == TaskStatus.pending
                              ? AppTheme.startedColor
                              : AppTheme.completedColor,
                        ),
                        label: Text(
                          task.status == TaskStatus.pending ? 'Iniciar' : 'Concluir',
                          style: TextStyle(
                            color: task.status == TaskStatus.pending
                                ? AppTheme.startedColor
                                : AppTheme.completedColor,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: (task.status == TaskStatus.pending
                              ? AppTheme.startedColor
                              : AppTheme.completedColor)
                              .withOpacity(0.1), // Cor de fundo com opacidade
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // Arredondado
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          foregroundColor: Colors.transparent, // Sem ripple visível
                        ),
                        onPressed: () {
                          onStatusChanged!(
                            task.status == TaskStatus.pending
                                ? TaskStatus.started
                                : TaskStatus.completed,
                          );
                        },
                      ),
                    ],
                    if (isAdmin) ...[
                      const SizedBox(width: 8),
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: onEdit,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: AppTheme.errorColor,
                          ),
                          onPressed: onDelete,
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}