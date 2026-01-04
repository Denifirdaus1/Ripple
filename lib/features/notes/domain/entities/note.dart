import 'package:equatable/equatable.dart';

/// Priority levels for notes
enum NotePriority { low, medium, high }

class Note extends Equatable {
  final String id;
  final String userId;
  final String title;
  final Map<String, dynamic> content; // Delta JSON
  final String? milestoneId;
  final DateTime? noteDate;           // Optional date property
  final List<String> tags;            // Tags for categorization
  final NotePriority? priority;       // Priority level
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.milestoneId,
    this.noteDate,
    this.tags = const [],
    this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  static final empty = Note(
    id: '',
    userId: '',
    title: '',
    content: const {'ops': []},
    tags: const [],
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
    DateTime? noteDate,
    bool clearNoteDate = false,
    List<String>? tags,
    NotePriority? priority,
    bool clearPriority = false,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      milestoneId: milestoneId ?? this.milestoneId,
      noteDate: clearNoteDate ? null : (noteDate ?? this.noteDate),
      tags: tags ?? this.tags,
      priority: clearPriority ? null : (priority ?? this.priority),
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, content, milestoneId, noteDate, tags, priority, createdAt, updatedAt];
}
