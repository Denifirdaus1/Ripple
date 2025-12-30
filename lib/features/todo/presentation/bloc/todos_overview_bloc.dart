import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/todo.dart';
import '../../domain/usecases/todo_usecases.dart';

// --- Events ---
abstract class TodosOverviewEvent extends Equatable {
  const TodosOverviewEvent();
  @override
  List<Object> get props => [];
}

class TodosOverviewSubscriptionRequested extends TodosOverviewEvent {}

class TodosOverviewTodoSaved extends TodosOverviewEvent {
  final Todo todo;
  const TodosOverviewTodoSaved(this.todo);
  @override
  List<Object> get props => [todo];
}

class TodosOverviewTodoDeleted extends TodosOverviewEvent {
  final Todo todo;
  const TodosOverviewTodoDeleted(this.todo);
  @override
  List<Object> get props => [todo];
}

class TodosOverviewFilterChanged extends TodosOverviewEvent {
  final TodosViewFilter filter;
  const TodosOverviewFilterChanged(this.filter);
  @override
  List<Object> get props => [filter];
}

// Internal event for stream updates
class _TodosOverviewTodosUpdated extends TodosOverviewEvent {
  final List<Todo> todos;
  const _TodosOverviewTodosUpdated(this.todos);
  @override
  List<Object> get props => [todos];
}

// --- States ---
enum TodosViewFilter { all, active, completed }

enum TodosOverviewStatus { initial, loading, success, failure }

class TodosOverviewState extends Equatable {
  final TodosOverviewStatus status;
  final List<Todo> todos;
  final TodosViewFilter filter;

  const TodosOverviewState({
    this.status = TodosOverviewStatus.initial,
    this.todos = const [],
    this.filter = TodosViewFilter.all,
  });

  Iterable<Todo> get filteredTodos {
    // Basic local filtering
    switch (filter) {
      case TodosViewFilter.all:
        return todos;
      case TodosViewFilter.active:
        return todos.where((t) => !t.isCompleted);
      case TodosViewFilter.completed:
        return todos.where((t) => t.isCompleted);
    }
  }

  TodosOverviewState copyWith({
    TodosOverviewStatus? status,
    List<Todo>? todos,
    TodosViewFilter? filter,
  }) {
    return TodosOverviewState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object> get props => [status, todos, filter];
}

// --- BLoC ---
class TodosOverviewBloc extends Bloc<TodosOverviewEvent, TodosOverviewState> {
  final GetTodosStream _getTodosStream;
  final SaveTodo _saveTodo;
  final DeleteTodo _deleteTodo;
  StreamSubscription<List<Todo>>? _todosSubscription;

  TodosOverviewBloc({
    required GetTodosStream getTodosStream,
    required SaveTodo saveTodo,
    required DeleteTodo deleteTodo,
  })  : _getTodosStream = getTodosStream,
        _saveTodo = saveTodo,
        _deleteTodo = deleteTodo,
        super(const TodosOverviewState()) {
    on<TodosOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<_TodosOverviewTodosUpdated>(_onTodosUpdated);
    on<TodosOverviewTodoSaved>(_onTodoSaved);
    on<TodosOverviewTodoDeleted>(_onTodoDeleted);
    on<TodosOverviewFilterChanged>(_onFilterChanged);
  }

  Future<void> _onSubscriptionRequested(
    TodosOverviewSubscriptionRequested event,
    Emitter<TodosOverviewState> emit,
  ) async {
    emit(state.copyWith(status: TodosOverviewStatus.loading));
    
    await _todosSubscription?.cancel();
    _todosSubscription = _getTodosStream().listen(
      (todos) {
        add(_TodosOverviewTodosUpdated(todos));
      },
      onError: (e, s) {
         AppLogger.e('Todos Stream Error', e, s);
         emit(state.copyWith(status: TodosOverviewStatus.failure));
      }
    );
  }

  void _onTodosUpdated(
    _TodosOverviewTodosUpdated event,
    Emitter<TodosOverviewState> emit,
  ) {
    emit(state.copyWith(
      status: TodosOverviewStatus.success,
      todos: event.todos,
    ));
  }

  Future<void> _onTodoSaved(
    TodosOverviewTodoSaved event,
    Emitter<TodosOverviewState> emit,
  ) async {
    try {
      final savedTodo = await _saveTodo(event.todo);
      final currentTodos = List<Todo>.from(state.todos);
      final index = currentTodos.indexWhere((t) => t.id == savedTodo.id);
      
      if (index >= 0) {
        currentTodos[index] = savedTodo;
      } else {
        currentTodos.add(savedTodo);
        // Optional: Sort if needed, but Stream usually handles order
      }
      emit(state.copyWith(status: TodosOverviewStatus.success, todos: currentTodos));
    } catch (_) {
      emit(state.copyWith(status: TodosOverviewStatus.failure));
    }
  }

  Future<void> _onTodoDeleted(
    TodosOverviewTodoDeleted event,
    Emitter<TodosOverviewState> emit,
  ) async {
    try {
      await _deleteTodo(event.todo.id);
      final currentTodos = List<Todo>.from(state.todos)
        ..removeWhere((t) => t.id == event.todo.id);
      emit(state.copyWith(status: TodosOverviewStatus.success, todos: currentTodos));
    } catch (_) {
      emit(state.copyWith(status: TodosOverviewStatus.failure));
    }
  }

  void _onFilterChanged(
    TodosOverviewFilterChanged event,
    Emitter<TodosOverviewState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  @override
  Future<void> close() {
    _todosSubscription?.cancel();
    return super.close();
  }
}
