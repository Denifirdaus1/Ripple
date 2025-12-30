import '../entities/todo.dart';

abstract class TodoRepository {
  Stream<List<Todo>> getTodosStream();
  Future<Todo> saveTodo(Todo todo);
  Future<void> deleteTodo(String id);
}
