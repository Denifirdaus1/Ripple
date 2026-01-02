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

class TodosOverviewViewModeChanged extends TodosOverviewEvent {
  final TodosViewMode viewMode;
  const TodosOverviewViewModeChanged(this.viewMode);
  @override
  List<Object> get props => [viewMode];
}

/// Event to clear all todos data (triggered on logout)
class TodosOverviewClearRequested extends TodosOverviewEvent {}

// Internal event for stream updates
class _TodosOverviewTodosUpdated extends TodosOverviewEvent {
  final List<Todo> todos;
  const _TodosOverviewTodosUpdated(this.todos);
  @override
  List<Object> get props => [todos];
}

// --- States ---
enum TodosViewFilter { all, active, completed }
enum TodosViewMode { list, schedule }

enum TodosOverviewStatus { initial, loading, success, failure }

class TodosOverviewState extends Equatable {
  final TodosOverviewStatus status;
  final List<Todo> todos;
  final TodosViewFilter filter;
  final TodosViewMode viewMode;

  const TodosOverviewState({
    this.status = TodosOverviewStatus.initial,
    this.todos = const [],
    this.filter = TodosViewFilter.all,
    this.viewMode = TodosViewMode.list,
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
    TodosViewMode? viewMode,
  }) {
    return TodosOverviewState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  List<Object> get props => [status, todos, filter, viewMode];
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
    on<TodosOverviewViewModeChanged>(_onViewModeChanged);
    on<TodosOverviewClearRequested>(_onClearRequested);
  }

  Future<void> _onSubscriptionRequested(
    TodosOverviewSubscriptionRequested event,
    Emitter<TodosOverviewState> emit,
  ) async {
    AppLogger.d('Todos subscription requested');
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
    AppLogger.d('Todos updated: ${event.todos.length} items');
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
      AppLogger.d('Saving todo: ${event.todo.title}');
      
      // OPTIMISTIC UPDATE (Optional but risky if DB fails, sticking to Wait-Then-Update as per plan)
      // Implementation: Wait for DB response, then update local list.
      
      final savedTodo = await _saveTodo(event.todo);
      
      // Create a new list from the current state to ensure immutability
      final currentTodos = List<Todo>.from(state.todos);
      final index = currentTodos.indexWhere((t) => t.id == savedTodo.id);
      
      if (index >= 0) {
        currentTodos[index] = savedTodo;
      } else {
        // If it's a new item, add it to the top or bottom? 
        // Stream usually orders by created_at. Let's add to end for now, or match Repo order.
        // Repo implementation orders by created_at (ascending).
        // Since we don't know the exact position without resort, adding to end is safe, 
        // or we could sort.
        currentTodos.add(savedTodo);
      }
      
      AppLogger.i('Todo saved successfully, updating UI manually');
      
      // Emit success state with the updated list
      emit(state.copyWith(
        status: TodosOverviewStatus.success,
        todos: currentTodos,
      ));
    } catch (e, s) {
      AppLogger.e('Failed to save todo in Bloc', e, s);
      // Emit failure but keep the old todos
      emit(state.copyWith(status: TodosOverviewStatus.failure));
    }
  }

  Future<void> _onTodoDeleted(
    TodosOverviewTodoDeleted event,
    Emitter<TodosOverviewState> emit,
  ) async {
    try {
      AppLogger.d('Deleting todo: ${event.todo.id}');
      await _deleteTodo(event.todo.id);
      final currentTodos = List<Todo>.from(state.todos)
        ..removeWhere((t) => t.id == event.todo.id);
      AppLogger.i('Todo deleted successfully');
      emit(state.copyWith(status: TodosOverviewStatus.success, todos: currentTodos));
    } catch (e, s) {
      AppLogger.e('Failed to delete todo in Bloc', e, s);
      emit(state.copyWith(status: TodosOverviewStatus.failure));
    }
  }

  void _onFilterChanged(
    TodosOverviewFilterChanged event,
    Emitter<TodosOverviewState> emit,
  ) {
    AppLogger.d('Filter changed: ${event.filter}');
    emit(state.copyWith(filter: event.filter));
  }

  void _onViewModeChanged(
    TodosOverviewViewModeChanged event,
    Emitter<TodosOverviewState> emit,
  ) {
    AppLogger.d('View mode changed: ${event.viewMode}');
    emit(state.copyWith(viewMode: event.viewMode));
  }

  /// Clears all todos data and cancels subscription (triggered on logout)
  void _onClearRequested(
    TodosOverviewClearRequested event,
    Emitter<TodosOverviewState> emit,
  ) {
    AppLogger.d('Clearing todos data');
    _todosSubscription?.cancel();
    _todosSubscription = null;
    emit(const TodosOverviewState());
  }

  @override
  Future<void> close() {
    _todosSubscription?.cancel();
    return super.close();
  }
}
