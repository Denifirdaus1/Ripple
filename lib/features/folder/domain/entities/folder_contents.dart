import 'package:equatable/equatable.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../todo/domain/entities/todo.dart';

/// Value object containing hydrated folder contents.
/// Contains actual Note and Todo entities, not just IDs.
/// This solves the N+1 query problem by batch-fetching entities.
class FolderContents extends Equatable {
  final List<Note> notes;
  final List<Todo> todos;

  const FolderContents({
    this.notes = const [],
    this.todos = const [],
  });

  /// Returns true if folder is empty
  bool get isEmpty => notes.isEmpty && todos.isEmpty;

  /// Returns true if folder has any items
  bool get isNotEmpty => !isEmpty;

  /// Total count of items in folder
  int get totalCount => notes.length + todos.length;

  /// Get all items as a combined list (for display)
  /// Each item is wrapped in a FolderContentItem for type safety
  List<FolderContentItem> get allItems => [
        ...notes.map((n) => FolderContentItem.note(n)),
        ...todos.map((t) => FolderContentItem.todo(t)),
      ];

  @override
  List<Object?> get props => [notes, todos];
}

/// Wrapper class for folder content items (either Note or Todo)
class FolderContentItem extends Equatable {
  final Note? note;
  final Todo? todo;

  const FolderContentItem._({this.note, this.todo});

  factory FolderContentItem.note(Note note) => FolderContentItem._(note: note);
  factory FolderContentItem.todo(Todo todo) => FolderContentItem._(todo: todo);

  bool get isNote => note != null;
  bool get isTodo => todo != null;

  String get id => note?.id ?? todo?.id ?? '';
  String get title => note?.title ?? todo?.title ?? '';
  DateTime get createdAt => note?.createdAt ?? todo?.createdAt ?? DateTime.now();

  @override
  List<Object?> get props => [note, todo];
}
