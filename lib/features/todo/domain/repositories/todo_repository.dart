import '../entities/todo.dart';

abstract class TodoRepository {
  Stream<List<Todo>> getTodosStream();
  Stream<List<Todo>> getSubtasksStream(String parentTodoId);
  Future<Todo> saveTodo(Todo todo);
  Future<void> deleteTodo(String id);
}
