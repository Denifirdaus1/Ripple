import '../../domain/entities/focus_session.dart';

class FocusSessionModel extends FocusSession {
  const FocusSessionModel({
    required super.id,
    required super.userId,
    required super.todoId,
    required super.startedAt,
    super.endedAt,
    super.durationMinutes,
    super.sessionType,
    super.wasCompleted,
    super.wasInterrupted,
  });

  factory FocusSessionModel.fromEntity(FocusSession session) {
    return FocusSessionModel(
      id: session.id,
      userId: session.userId,
      todoId: session.todoId,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      durationMinutes: session.durationMinutes,
      sessionType: session.sessionType,
      wasCompleted: session.wasCompleted,
      wasInterrupted: session.wasInterrupted,
    );
  }

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) {
    return FocusSessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      todoId: json['todo_id'] as String,
      startedAt: DateTime.parse(json['started_at']).toLocal(),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']).toLocal() : null,
      durationMinutes: json['duration_minutes'] as int?,
      sessionType: _parseType(json['session_type'] as String?),
      wasCompleted: json['was_completed'] as bool? ?? false,
      wasInterrupted: json['was_interrupted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'todo_id': todoId,
      'started_at': startedAt.toUtc().toIso8601String(),
      'ended_at': endedAt?.toUtc().toIso8601String(),
      'duration_minutes': durationMinutes,
      'session_type': _typeToString(sessionType),
      'was_completed': wasCompleted,
      'was_interrupted': wasInterrupted,
    };
  }

  static SessionType _parseType(String? type) {
    return type == 'breakTime' ? SessionType.breakTime : SessionType.work;
  }

  static String _typeToString(SessionType type) {
    return type == SessionType.breakTime ? 'breakTime' : 'work';
  }
}
