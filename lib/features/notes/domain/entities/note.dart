import 'package:equatable/equatable.dart';

/// Priority levels for notes
enum NotePriority { low, medium, high }

/// Status levels for notes (work progress)
enum NoteWorkStatus {
  notStarted,   // Belum Dimulai / Not Started
  inProgress,   // Sedang Berjalan / In Progress
  done,         // Selesai / Done
}

class Note extends Equatable {
  final String id;
  final String userId;
  final String title;
  final Map<String, dynamic> content; // Delta JSON
  final String? milestoneId;
  final DateTime? noteDate;           // Optional date property
  final List<String> tags;            // Tags for categorization
  final NotePriority? priority;       // Priority level
  final NoteWorkStatus? status;           // Status (not_started, in_progress, done)
  final String? description;          // Description text
  final bool isFavorite;              // Favorite flag
  final List<String> enabledProperties; // Enabled property IDs (sandbox)
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
    this.status,
    this.description,
    this.isFavorite = false,
    this.enabledProperties = const ['date'], // Default: only date
    required this.createdAt,
    required this.updatedAt,
  });

  static final empty = Note(
    id: '',
    userId: '',
    title: '',
    content: const {'ops': []},
    tags: const [],
    status: null,
    description: null,
    isFavorite: false,
    enabledProperties: const ['date'],
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
    NoteWorkStatus? status,
    bool clearStatus = false,
    String? description,
    bool clearDescription = false,
    bool? isFavorite,
    List<String>? enabledProperties,
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
      status: clearStatus ? null : (status ?? this.status),
      description: clearDescription ? null : (description ?? this.description),
      isFavorite: isFavorite ?? this.isFavorite,
      enabledProperties: enabledProperties ?? this.enabledProperties,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, content, milestoneId, noteDate, tags, priority, status, description, enabledProperties, createdAt, updatedAt];
}
