import '../../domain/entities/note_tag.dart';

class NoteTagModel extends NoteTag {
  const NoteTagModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.colorHex,
    required super.createdAt,
  });

  factory NoteTagModel.fromJson(Map<String, dynamic> json) {
    return NoteTagModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      colorHex: json['color_hex'] as String? ?? '#808080',
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty && !id.startsWith('default_')) 'id': id,
      'user_id': userId,
      'name': name,
      'color_hex': colorHex,
    };
  }

  factory NoteTagModel.fromEntity(NoteTag tag) {
    return NoteTagModel(
      id: tag.id,
      userId: tag.userId,
      name: tag.name,
      colorHex: tag.colorHex,
      createdAt: tag.createdAt,
    );
  }
}
