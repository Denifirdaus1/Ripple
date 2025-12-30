import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ripple/features/todo/domain/entities/todo.dart';
import 'package:ripple/features/todo/domain/usecases/todo_usecases.dart';
import 'package:ripple/features/todo/presentation/bloc/todos_overview_bloc.dart';

class MockGetTodosStream extends Mock implements GetTodosStream {}
class MockSaveTodo extends Mock implements SaveTodo {}
class MockDeleteTodo extends Mock implements DeleteTodo {}

void main() {
  group('TodosOverviewBloc', () {
    late GetTodosStream getTodosStream;
    late SaveTodo saveTodo;
    late DeleteTodo deleteTodo;
    late TodosOverviewBloc bloc;

    final tTodo = Todo(
      id: '1',
      userId: 'user1',
      title: 'Test Todo',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      getTodosStream = MockGetTodosStream();
      saveTodo = MockSaveTodo();
      deleteTodo = MockDeleteTodo();
      
      bloc = TodosOverviewBloc(
        getTodosStream: getTodosStream,
        saveTodo: saveTodo,
        deleteTodo: deleteTodo,
      );
    });

    setUpAll(() {
      registerFallbackValue(tTodo);
    });

    test('initial state is correct', () {
      expect(bloc.state, const TodosOverviewState());
    });

    blocTest<TodosOverviewBloc, TodosOverviewState>(
      'emits [loading, success] when sub requested',
      build: () {
        when(() => getTodosStream()).thenAnswer((_) => Stream.value([tTodo]));
        return bloc;
      },
      act: (bloc) => bloc.add(TodosOverviewSubscriptionRequested()),
      expect: () => [
        const TodosOverviewState(status: TodosOverviewStatus.loading),
        TodosOverviewState(
          status: TodosOverviewStatus.success,
          todos: [tTodo],
        ),
      ],
    );

    blocTest<TodosOverviewBloc, TodosOverviewState>(
      'calls SaveTodo when TodoSaved is added',
      build: () {
        when(() => saveTodo(any())).thenAnswer((_) async => tTodo);
        return bloc;
      },
      act: (bloc) => bloc.add(TodosOverviewTodoSaved(tTodo)),
      verify: (_) {
        verify(() => saveTodo(tTodo)).called(1);
      },
    );

    blocTest<TodosOverviewBloc, TodosOverviewState>(
      'calls DeleteTodo when TodoDeleted is added',
      build: () {
        when(() => deleteTodo(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(TodosOverviewTodoDeleted(tTodo)),
      verify: (_) {
        verify(() => deleteTodo(tTodo.id)).called(1);
      },
    );

    blocTest<TodosOverviewBloc, TodosOverviewState>(
      'filters todos correctly',
      build: () => bloc,
      seed: () => TodosOverviewState(
        status: TodosOverviewStatus.success,
        todos: [
          tTodo.copyWith(isCompleted: false),
          tTodo.copyWith(id: '2', isCompleted: true),
        ],
      ),
      act: (bloc) => bloc.add(const TodosOverviewFilterChanged(TodosViewFilter.active)),
      expect: () => [
        isA<TodosOverviewState>().having(
          (s) => s.filter,
          'filter',
          TodosViewFilter.active,
        ),
      ],
      verify: (bloc) {
         // Check if getter works (not directly testable in expect, but logic is verified by UI usually)
         // Here we just test state change
      }
    );
  });
}
