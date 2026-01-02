import 'package:equatable/equatable.dart';

enum TodoPriority { high, medium, low }

class Todo extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final TodoPriority priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isScheduled;
  final DateTime? scheduledDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool focusEnabled;
  final int? focusDurationMinutes;
  final String? milestoneId;
  // New fields synced with DB
  final Map<String, dynamic>? recurrenceRule;
  final String? parentTodoId;
  final bool notificationSent;
  final int reminderMinutes; // Minutes before start_time to send reminder
  final DateTime createdAt;
  final DateTime updatedAt;

  const Todo({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.priority = TodoPriority.medium,  // Match DB default
    this.isCompleted = false,
    this.completedAt,
    this.isScheduled = false,
    this.scheduledDate,
    this.startTime,
    this.endTime,
    this.focusEnabled = false,
    this.focusDurationMinutes,
    this.milestoneId,
    this.recurrenceRule,
    this.parentTodoId,
    this.notificationSent = false,
    this.reminderMinutes = 5, // Default 5 minutes before
    required this.createdAt,
    required this.updatedAt,
  });

  // Empty todo for initial states
  static final empty = Todo(
    id: '',
    userId: '',
    title: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  bool get isEmpty => this == Todo.empty;
  bool get isNotEmpty => this != Todo.empty;

  /// Indicates if this is a recurring todo template
  bool get isRecurring => recurrenceRule != null;

  /// Indicates if this is a child instance of a recurring todo
  bool get isRecurrenceInstance => parentTodoId != null;

  Todo copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TodoPriority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isScheduled,
    DateTime? scheduledDate,
    DateTime? startTime,
    DateTime? endTime,
    bool? focusEnabled,
    int? focusDurationMinutes,
    String? milestoneId,
    Map<String, dynamic>? recurrenceRule,
    String? parentTodoId,
    bool? notificationSent,
    int? reminderMinutes,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isScheduled: isScheduled ?? this.isScheduled,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      focusEnabled: focusEnabled ?? this.focusEnabled,
      focusDurationMinutes: focusDurationMinutes ?? this.focusDurationMinutes,
      milestoneId: milestoneId ?? this.milestoneId,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      parentTodoId: parentTodoId ?? this.parentTodoId,
      notificationSent: notificationSent ?? this.notificationSent,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        priority,
        isCompleted,
        completedAt,
        isScheduled,
        scheduledDate,
        startTime,
        endTime,
        focusEnabled,
        focusDurationMinutes,
        milestoneId,
        recurrenceRule,
        parentTodoId,
        notificationSent,
        reminderMinutes,
        createdAt,
        updatedAt,
      ];
}
