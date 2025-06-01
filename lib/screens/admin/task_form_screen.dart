import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agpop/models/task_model.dart';
import 'package:agpop/models/user_model.dart';
import 'package:agpop/models/position_model.dart';
import 'package:agpop/theme/app_theme.dart';
import 'package:agpop/widgets/custom_button.dart';

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
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
}

enum AssignmentMode { position, user }

enum RecurrenceType { daily, weekly, bi_weekly, monthly_day }

extension RecurrenceTypeExtension on RecurrenceType {
  String get displayName {
    switch (this) {
      case RecurrenceType.daily:
        return 'Diário';
      case RecurrenceType.weekly:
        return 'Semanal';
      case RecurrenceType.bi_weekly:
        return 'Quinzenal (a cada 2 semanas)';
      case RecurrenceType.monthly_day:
        return 'Mensal (mesmo dia do mês)';
    }
  }

  String get value {
    switch (this) {
      case RecurrenceType.daily:
        return 'daily';
      case RecurrenceType.weekly:
        return 'weekly';
      case RecurrenceType.bi_weekly:
        return 'bi_weekly';
      case RecurrenceType.monthly_day:
        return 'monthly_day';
    }
  }
}

RecurrenceType? recurrenceTypeFromString(String? typeString) {
  if (typeString == null) return null;
  return RecurrenceType.values.firstWhere((e) => e.value == typeString, orElse: () => RecurrenceType.daily); // Default or handle error
}


class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;
  final List<UserModel> availableUsers;
  final List<PositionModel> availablePositions;

  const TaskFormScreen({
    super.key,
    this.task,
    required this.availableUsers,
    required this.availablePositions
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  AssignmentMode _assignmentMode = AssignmentMode.position;
  List<String> _assignedUserIds = [];
  String? _selectedPositionId;

  bool _isRecurring = false;
  RecurrenceType? _selectedRecurrenceType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _assignedUserIds = [];
    _selectedPositionId = null;
    if (widget.task != null) {
      if (widget.task!.assignedPositionIds.isNotEmpty) {
        _assignmentMode = AssignmentMode.position;
        _selectedPositionId = widget.task!.assignedPositionIds.first;
        _assignedUserIds.clear();
      } else if (widget.task!.assignedUserIds.isNotEmpty) {
        _assignmentMode = AssignmentMode.user;
        _assignedUserIds = List.from(widget.task!.assignedUserIds);
        _selectedPositionId = null;
      } else {
        _assignmentMode = AssignmentMode.position;
      }

      try {
        _isRecurring = (widget.task as dynamic).isRecurring ?? false;
        _selectedRecurrenceType = recurrenceTypeFromString((widget.task as dynamic).recurrenceType);
      } catch (e) {
        _isRecurring = false;
        _selectedRecurrenceType = null;
      }
    } else {
      _assignmentMode = AssignmentMode.position;
      _isRecurring = false;
    }

    if (_isRecurring && _selectedRecurrenceType == null) {
      _selectedRecurrenceType = RecurrenceType.daily;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    bool assignmentValid = true;
    String assignmentErrorMsg = '';
    if (_assignmentMode == AssignmentMode.position && _selectedPositionId == null) {
      assignmentValid = false;
      assignmentErrorMsg = 'Por favor, selecione uma posição.';
    } else if (_assignmentMode == AssignmentMode.user && _assignedUserIds.isEmpty) {
      assignmentValid = false;
      assignmentErrorMsg = 'Por favor, selecione ao menos um usuário.';
    }
    if (!assignmentValid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(assignmentErrorMsg)));
      return;
    }

    if (_isRecurring && _selectedRecurrenceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de recorrência é obrigatório para tarefas recorrentes.')));
      return;
    }

    Map<String, dynamic> taskDataPayload = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'assigned_user_ids': _assignmentMode == AssignmentMode.user ? _assignedUserIds : [],
      'assigned_position_ids': _assignmentMode == AssignmentMode.position && _selectedPositionId != null
          ? [_selectedPositionId!]
          : [],
      'status': (widget.task?.status ?? TaskStatus.pending).name,
      'is_recurring': _isRecurring,
      'recurrence_type': _isRecurring ? _selectedRecurrenceType?.value : null,
    };


    if (widget.task == null) {
      String taskId = FirebaseFirestore.instance.collection('tasks').doc().id;
      taskDataPayload['id'] = taskId;
      taskDataPayload['createdAt'] = FieldValue.serverTimestamp();
      taskDataPayload['updatedAt'] = FieldValue.serverTimestamp();

      FirebaseFirestore.instance.collection('tasks').doc(taskId).set(taskDataPayload).then((_) {
        Navigator.of(context).pop(true);
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar tarefa: $e')));
      });
    } else {
      taskDataPayload['updatedAt'] = FieldValue.serverTimestamp();
      FirebaseFirestore.instance.collection('tasks').doc(widget.task!.id).update(taskDataPayload).then((_) {
        Navigator.of(context).pop(true);
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar tarefa: $e')));
      });
    }
  }

  Widget _buildAssignmentToggleButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_assignmentMode != AssignmentMode.position) {
                setState(() {
                  _assignmentMode = AssignmentMode.position;
                  _assignedUserIds.clear();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _assignmentMode == AssignmentMode.position ? AppTheme.primaryColor : Colors.white,
              foregroundColor: _assignmentMode == AssignmentMode.position ? Colors.white : AppTheme.primaryColor,
              side: _assignmentMode == AssignmentMode.position ? null : BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              padding: const EdgeInsets.symmetric(vertical: 12)
            ),
            child: const Text('Por Posição')
          )
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_assignmentMode != AssignmentMode.user) {
                setState(() {
                  _assignmentMode = AssignmentMode.user;
                  _selectedPositionId = null;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _assignmentMode == AssignmentMode.user ? AppTheme.primaryColor : Colors.white,
              foregroundColor: _assignmentMode == AssignmentMode.user ? Colors.white : AppTheme.primaryColor,
              side: _assignmentMode == AssignmentMode.user ? null : BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              padding: const EdgeInsets.symmetric(vertical: 12)
            ),
            child: const Text('Por Usuário')
          )
        )
      ]
    );
  }

  Widget _buildPositionSelection() {
    if (widget.availablePositions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('Nenhuma posição disponível.'))
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text('Selecionar Posição', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.availablePositions.length,
          itemBuilder: (context, index) {
            final position = widget.availablePositions[index];
            return RadioListTile<String>(
              title: Text(position.name),
              value: position.id,
              groupValue: _selectedPositionId,
              onChanged: (String? value) {
                setState(() {
                  _selectedPositionId = value;
                });
              },
              activeColor: AppTheme.primaryColor,
              controlAffinity: ListTileControlAffinity.trailing,
              contentPadding: EdgeInsets.zero
            );
          }
        )
      ]
    );
  }

  Widget _buildUserSelection() {
    if (widget.availableUsers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('Nenhum usuário disponível.'))
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(_assignmentMode == AssignmentMode.user ? 'Selecionar Usuário(s)' : 'Selecionar Usuário', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.availableUsers.length,
          itemBuilder: (context, index) {
            final user = widget.availableUsers[index];
            return CheckboxListTile(
              title: Text(user.name),
              value: _assignedUserIds.contains(user.id),
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    if (!_assignedUserIds.contains(user.id)) {
                      _assignedUserIds.add(user.id);
                    }
                  } else {
                    _assignedUserIds.remove(user.id);
                  }
                });
              },
              activeColor: AppTheme.primaryColor,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero
            );
          }
        )
      ]
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nova Tarefa' : 'Editar Tarefa')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título da Tarefa',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, insira um título';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                minLines: 1
              ),
              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text('Tarefa Recorrente?'),
                value: _isRecurring,
                onChanged: (bool value) {
                  setState(() {
                    _isRecurring = value;
                    if (_isRecurring) {
                      _selectedRecurrenceType ??= RecurrenceType.daily;
                    } else {
                      _selectedRecurrenceType = null;
                    }
                  });
                },
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.zero
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<RecurrenceType>(
                  value: _selectedRecurrenceType,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Recorrência',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  items: RecurrenceType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName)
                    );
                  }).toList(),
                  onChanged: (RecurrenceType? newValue) {
                    setState(() {
                      _selectedRecurrenceType = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Selecione um tipo de recorrência' : null,
                ),
              ],
              const SizedBox(height: 20),
              const Text('Atribuição', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildAssignmentToggleButtons(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _assignmentMode == AssignmentMode.position
                    ? _buildPositionSelection()
                    : _buildUserSelection()
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: widget.task == null ? 'Criar Tarefa' : 'Salvar Alterações',
                icon: Icons.save,
                onPressed: _saveTask
              )
            ]
          )
        )
      )
    );
  }
}