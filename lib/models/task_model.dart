import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { pending, started, completed, cancelled }

enum RecurrenceType { daily, weekly, bi_weekly, monthly_day }

RecurrenceType? recurrenceTypeFromString(String? typeString) {
  if (typeString == null) return null;
  return RecurrenceType.values.firstWhere((e) => e.toString().split('.').last == typeString, orElse: () => RecurrenceType.daily);
}

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
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final List<String> assignedUserIds;
  final List<String> assignedPositionIds;
  final bool isRecurring;
  final RecurrenceType? recurrenceType;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.assignedUserIds = const [],
    this.assignedPositionIds = const [],
    this.isRecurring = false,
    this.recurrenceType
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    TaskStatus getStatus(String? status) {
      switch (status) {
        case 'started':
          return TaskStatus.started;
        case 'completed':
          return TaskStatus.completed;
        case 'cancelled':
          return TaskStatus.cancelled;
        default:
          return TaskStatus.pending;
      }
    }

    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: getStatus(data['status']),
      assignedUserIds: List<String>.from(data['assigned_user_ids'] ?? []),
      assignedPositionIds: List<String>.from(data['assigned_position_ids'] ?? []),
      isRecurring: data['is_recurring'] ?? false,
      recurrenceType: recurrenceTypeFromString(data['recurrence_type']),
    );
  }

  Map<String, dynamic> toMap() {
    String getStatusString(TaskStatus status) {
      switch (status) {
        case TaskStatus.started:
          return 'started';
        case TaskStatus.completed:
          return 'completed';
        case TaskStatus.cancelled:
          return 'cancelled';
        default:
          return 'pending';
      }
    }

    return {
      'title': title,
      'description': description,
      'status': getStatusString(status),
      'assigned_user_ids': assignedUserIds,
      'assigned_position_ids': assignedPositionIds,
      'is_recurring': isRecurring,
      'recurrence_type': recurrenceType?.toString().split('.').last,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp()
    };
  }

  Map<String, dynamic> toJson() => toMap();

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    List<String>? assignedUserIds,
    List<String>? assignedPositionIds,
    bool? isRecurring,
    RecurrenceType? recurrenceType,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedUserIds: assignedUserIds ?? this.assignedUserIds,
      assignedPositionIds: assignedPositionIds ?? this.assignedPositionIds,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
    );
  }
}