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
