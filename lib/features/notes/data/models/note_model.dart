import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.content,
    super.milestoneId,
    super.noteDate,
    super.tags = const [],
    super.priority,
    super.status,
    super.description,
    super.isFavorite = false,
    super.enabledProperties = const ['date'],
    required super.createdAt,
    required super.updatedAt,
  });

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      userId: note.userId,
      title: note.title,
      content: note.content,
      milestoneId: note.milestoneId,
      noteDate: note.noteDate,
      tags: note.tags,
      priority: note.priority,
      status: note.status,
      description: note.description,
      isFavorite: note.isFavorite,
      enabledProperties: note.enabledProperties,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as Map<String, dynamic>,
      milestoneId: json['milestone_id'] as String?,
      noteDate: json['note_date'] != null 
          ? _parseDateAsLocal(json['note_date'] as String) 
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      priority: _parsePriority(json['priority'] as String?),
      status: _parseStatus(json['status'] as String?),
      description: json['description'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      enabledProperties: (json['enabled_properties'] as List<dynamic>?)
          ?.cast<String>() ?? ['date'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'milestone_id': milestoneId,
      'note_date': noteDate != null 
          ? '${noteDate!.year}-${noteDate!.month.toString().padLeft(2, '0')}-${noteDate!.day.toString().padLeft(2, '0')}' 
          : null,
      'tags': tags,
      'priority': _priorityToString(priority),
      'status': _statusToString(status),
      'description': description,
      'is_favorite': isFavorite,
      'enabled_properties': enabledProperties,
    };
  }

  static NotePriority? _parsePriority(String? priority) {
    switch (priority) {
      case 'high': return NotePriority.high;
      case 'medium': return NotePriority.medium;
      case 'low': return NotePriority.low;
      default: return null;
    }
  }

  static String? _priorityToString(NotePriority? priority) {
    switch (priority) {
      case NotePriority.high: return 'high';
      case NotePriority.medium: return 'medium';
      case NotePriority.low: return 'low';
      default: return null;
    }
  }

  static NoteWorkStatus? _parseStatus(String? status) {
    switch (status) {
      case 'not_started': return NoteWorkStatus.notStarted;
      case 'in_progress': return NoteWorkStatus.inProgress;
      case 'done': return NoteWorkStatus.done;
      default: return null;
    }
  }

  static String? _statusToString(NoteWorkStatus? status) {
    switch (status) {
      case NoteWorkStatus.notStarted: return 'not_started';
      case NoteWorkStatus.inProgress: return 'in_progress';
      case NoteWorkStatus.done: return 'done';
      default: return null;
    }
  }

  /// Parse date-only string (YYYY-MM-DD) as LOCAL DateTime
  static DateTime _parseDateAsLocal(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
