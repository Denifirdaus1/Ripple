import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/goal.dart';
import '../../domain/usecases/milestone_usecases.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../../../../core/utils/logger.dart';

// --- Events ---
abstract class GoalListEvent extends Equatable {
  const GoalListEvent();
  @override
  List<Object> get props => [];
}

class GoalListSubscriptionRequested extends GoalListEvent {}

class GoalListGoalCreated extends GoalListEvent {
  final Goal goal;
  const GoalListGoalCreated(this.goal);
  @override
  List<Object> get props => [goal];
}

class GoalListGoalDeleted extends GoalListEvent {
  final String id;
  const GoalListGoalDeleted(this.id);
  @override
  List<Object> get props => [id];
}

class _GoalListUpdated extends GoalListEvent {
  final List<Goal> goals;
  const _GoalListUpdated(this.goals);
  @override
  List<Object> get props => [goals];
}

// --- States ---
enum GoalListStatus { initial, loading, success, failure }

class GoalListState extends Equatable {
  final GoalListStatus status;
  final List<Goal> goals;

  const GoalListState({
    this.status = GoalListStatus.initial,
    this.goals = const [],
  });

  GoalListState copyWith({
    GoalListStatus? status,
    List<Goal>? goals,
  }) {
    return GoalListState(
      status: status ?? this.status,
      goals: goals ?? this.goals,
    );
  }

  @override
  List<Object> get props => [status, goals];
}

// --- BLoC ---
class GoalListBloc extends Bloc<GoalListEvent, GoalListState> {
  final GetGoalsStream _getGoalsStream;
  final CreateGoal _createGoal;
  final MilestoneRepository _repository; // Needed for delete if we don't have separate use case, using Repo directly for simplicity or define use case

  StreamSubscription<List<Goal>>? _subscription;

  GoalListBloc({
    required GetGoalsStream getGoalsStream,
    required CreateGoal createGoal,
    required MilestoneRepository repository,
  })  : _getGoalsStream = getGoalsStream,
        _createGoal = createGoal,
        _repository = repository,
        super(const GoalListState()) {
    on<GoalListSubscriptionRequested>(_onSubscriptionRequested);
    on<_GoalListUpdated>(_onListUpdated);
    on<GoalListGoalCreated>(_onGoalCreated);
    on<GoalListGoalDeleted>(_onGoalDeleted);
  }

  Future<void> _onSubscriptionRequested(
    GoalListSubscriptionRequested event,
    Emitter<GoalListState> emit,
  ) async {
    emit(state.copyWith(status: GoalListStatus.loading));
    await _subscription?.cancel();
    _subscription = _getGoalsStream().listen(
      (goals) => add(_GoalListUpdated(goals)),
      onError: (e, s) {
         AppLogger.e('Goals Stream Error', e, s);
         emit(state.copyWith(status: GoalListStatus.failure));
      },
    );
  }

  void _onListUpdated(
    _GoalListUpdated event,
    Emitter<GoalListState> emit,
  ) {
    emit(state.copyWith(
      status: GoalListStatus.success,
      goals: event.goals,
    ));
  }

  Future<void> _onGoalCreated(
    GoalListGoalCreated event,
    Emitter<GoalListState> emit,
  ) async {
    try {
      final newGoal = await _createGoal(event.goal);
      final currentGoals = List<Goal>.from(state.goals)..add(newGoal);
      emit(state.copyWith(status: GoalListStatus.success, goals: currentGoals));
    } catch (_) {
      emit(state.copyWith(status: GoalListStatus.failure));
    }
  }

  Future<void> _onGoalDeleted(
    GoalListGoalDeleted event,
    Emitter<GoalListState> emit,
  ) async {
    try {
      await _repository.deleteGoal(event.id);
      final currentGoals = List<Goal>.from(state.goals)..removeWhere((g) => g.id == event.id);
      emit(state.copyWith(status: GoalListStatus.success, goals: currentGoals));
    } catch (_) {
      emit(state.copyWith(status: GoalListStatus.failure));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
