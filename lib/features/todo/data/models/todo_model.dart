import '../../domain/entities/todo.dart';

class TodoModel extends Todo {
  const TodoModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    super.priority,
    super.isCompleted,
    super.completedAt,
    super.isScheduled,
    super.scheduledDate,
    super.startTime,
    super.endTime,
    super.focusEnabled,
    super.focusDurationMinutes,
    super.milestoneId,
    super.recurrenceRule,
    super.parentTodoId,
    super.notificationSent,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      id: todo.id,
      userId: todo.userId,
      title: todo.title,
      description: todo.description,
      priority: todo.priority,
      isCompleted: todo.isCompleted,
      completedAt: todo.completedAt,
      isScheduled: todo.isScheduled,
      scheduledDate: todo.scheduledDate,
      startTime: todo.startTime,
      endTime: todo.endTime,
      focusEnabled: todo.focusEnabled,
      focusDurationMinutes: todo.focusDurationMinutes,
      milestoneId: todo.milestoneId,
      recurrenceRule: todo.recurrenceRule,
      parentTodoId: todo.parentTodoId,
      notificationSent: todo.notificationSent,
      createdAt: todo.createdAt,
      updatedAt: todo.updatedAt,
    );
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: _parsePriority(json['priority'] as String?),
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']).toLocal() : null,
      isScheduled: json['is_scheduled'] as bool? ?? false,
      scheduledDate: json['scheduled_date'] != null ? DateTime.parse(json['scheduled_date']).toLocal() : null,
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']).toLocal() : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']).toLocal() : null,
      focusEnabled: json['focus_enabled'] as bool? ?? false,
      focusDurationMinutes: json['focus_duration_minutes'] as int?,
      milestoneId: json['milestone_id'] as String?,
      recurrenceRule: json['recurrence_rule'] as Map<String, dynamic>?,
      parentTodoId: json['parent_todo_id'] as String?,
      notificationSent: json['notification_sent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'priority': _priorityToString(priority),
      'is_completed': isCompleted,
      'completed_at': completedAt?.toUtc().toIso8601String(),
      'is_scheduled': isScheduled,
      'scheduled_date': scheduledDate?.toUtc().toIso8601String().split('T').first, // Date only
      'start_time': startTime?.toUtc().toIso8601String(),
      'end_time': endTime?.toUtc().toIso8601String(),
      'focus_enabled': focusEnabled,
      'focus_duration_minutes': focusDurationMinutes,
      'milestone_id': (milestoneId?.isEmpty ?? true) ? null : milestoneId,
      'recurrence_rule': recurrenceRule,
      'parent_todo_id': (parentTodoId?.isEmpty ?? true) ? null : parentTodoId,
      'notification_sent': notificationSent,
      // created_at / updated_at handled by DB defaults and triggers
    };
  }

  static TodoPriority _parsePriority(String? priority) {
    switch (priority) {
      case 'high': return TodoPriority.high;
      case 'medium': return TodoPriority.medium;
      case 'low': return TodoPriority.low;
      default: return TodoPriority.none;
    }
  }

  static String _priorityToString(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high: return 'high';
      case TodoPriority.medium: return 'medium';
      case TodoPriority.low: return 'low';
      case TodoPriority.none: return 'none';
    }
  }
}
