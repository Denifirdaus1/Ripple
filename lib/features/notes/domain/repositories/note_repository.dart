import '../entities/note.dart';
import '../../../todo/domain/entities/todo.dart';

abstract class NoteRepository {
  Stream<List<Note>> getNotesStream();
  Future<Note> getNote(String id);
  Future<Note> saveNote(Note note);
  Future<void> deleteNote(String id);
  
  // For mentions
  Future<List<Todo>> searchTodos(String query);
}
