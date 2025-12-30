import '../repositories/todo_repository.dart';
import '../entities/todo.dart';

class GetTodosStream {
  final TodoRepository repository;
  GetTodosStream(this.repository);
  Stream<List<Todo>> call() => repository.getTodosStream();
}

class SaveTodo {
  final TodoRepository repository;
  SaveTodo(this.repository);
  Future<Todo> call(Todo todo) => repository.saveTodo(todo);
}

class DeleteTodo {
  final TodoRepository repository;
  DeleteTodo(this.repository);
  Future<void> call(String id) => repository.deleteTodo(id);
}
