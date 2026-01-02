import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../models/todo_model.dart';
import '../../../../core/utils/logger.dart';

class TodoRepositoryImpl implements TodoRepository {
  final SupabaseClient _supabase;

  TodoRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Stream<List<Todo>> getTodosStream() {
    AppLogger.d('Subscribing to todos stream');
    return _supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => data.map((json) => TodoModel.fromJson(json)).toList());
  }

  @override
  Future<Todo> saveTodo(Todo todo) async {
    try {
      AppLogger.d('Saving todo to DB: ${todo.title} (ID: ${todo.id})');
      final model = TodoModel.fromEntity(todo);
      final json = model.toJson();
      Map<String, dynamic> data;
      if (model.id.isEmpty) {
        data = await _supabase.from('todos').insert(json).select().single();
      } else {
        data = await _supabase.from('todos').upsert(json).select().single();
      }
      AppLogger.i('Todo saved to DB successfully');
      return TodoModel.fromJson(data);
    } catch (e, s) {
      AppLogger.e('Failed to save todo', e, s);
      rethrow;
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      AppLogger.d('Deleting todo from DB: $id');
      await _supabase.from('todos').delete().eq('id', id);
      AppLogger.i('Todo deleted from DB successfully');
    } catch (e, s) {
      AppLogger.e('Failed to delete todo', e, s);
      rethrow;
    }
  }
}
