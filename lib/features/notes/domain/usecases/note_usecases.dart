import '../repositories/note_repository.dart';
import '../entities/note.dart';
import '../../../todo/domain/entities/todo.dart';

class GetNotesStream {
  final NoteRepository repository;
  GetNotesStream(this.repository);
  Stream<List<Note>> call() => repository.getNotesStream();
}

class SaveNote {
  final NoteRepository repository;
  SaveNote(this.repository);
  Future<Note> call(Note note) => repository.saveNote(note);
}

class DeleteNote {
  final NoteRepository repository;
  DeleteNote(this.repository);
  Future<void> call(String id) => repository.deleteNote(id);
}

class GetNote {
  final NoteRepository repository;
  GetNote(this.repository);
  Future<Note> call(String id) => repository.getNote(id);
}

class SearchMentions {
  final NoteRepository repository;
  SearchMentions(this.repository);
  
  // Currently we only support mentioning Todos, but consistent naming allows expansion
  Future<List<Todo>> searchTodos(String query) => repository.searchTodos(query);
}
