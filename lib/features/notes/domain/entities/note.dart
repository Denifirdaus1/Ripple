import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String userId;
  final String title;
  final Map<String, dynamic> content; // Delta JSON
  final String? milestoneId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.milestoneId,
    required this.createdAt,
    required this.updatedAt,
  });

  static final empty = Note(
    id: '',
    userId: '',
    title: '',
    content: const {'ops': []},
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  bool get isEmpty => this == Note.empty;
  bool get isNotEmpty => this != Note.empty;

  Note copyWith({
    String? id,
    String? userId,
    String? title,
    Map<String, dynamic>? content,
    String? milestoneId,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      milestoneId: milestoneId ?? this.milestoneId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, content, milestoneId, createdAt, updatedAt];
}
