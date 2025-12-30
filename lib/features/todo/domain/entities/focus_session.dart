import 'package:equatable/equatable.dart';

enum SessionType { work, breakTime }

class FocusSession extends Equatable {
  final String id;
  final String userId;
  final String todoId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationMinutes;
  final SessionType sessionType;
  final bool wasCompleted;
  final bool wasInterrupted;

  const FocusSession({
    required this.id,
    required this.userId,
    required this.todoId,
    required this.startedAt,
    this.endedAt,
    this.durationMinutes,
    this.sessionType = SessionType.work,
    this.wasCompleted = false,
    this.wasInterrupted = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        todoId,
        startedAt,
        endedAt,
        durationMinutes,
        sessionType,
        wasCompleted,
        wasInterrupted,
      ];
}
