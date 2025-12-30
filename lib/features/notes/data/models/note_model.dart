import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.content,
    super.milestoneId,
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
      // created_at / updated_at handled by DB defaults usually
    };
  }
}
