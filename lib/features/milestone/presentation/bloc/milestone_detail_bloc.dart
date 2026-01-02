import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../../../../core/utils/logger.dart';

// --- Events ---
sealed class MilestoneDetailEvent extends Equatable {
  const MilestoneDetailEvent();
  @override
  List<Object?> get props => [];
}

final class MilestoneDetailSubscriptionRequested extends MilestoneDetailEvent {
  final String goalId;
  const MilestoneDetailSubscriptionRequested(this.goalId);
  @override
  List<Object?> get props => [goalId];
}

final class MilestoneDetailMilestoneCreated extends MilestoneDetailEvent {
  final Milestone milestone;
  const MilestoneDetailMilestoneCreated(this.milestone);
  @override
  List<Object?> get props => [milestone];
}

final class MilestoneDetailMilestoneUpdated extends MilestoneDetailEvent {
  final Milestone milestone;
  const MilestoneDetailMilestoneUpdated(this.milestone);
  @override
  List<Object?> get props => [milestone];
}

final class MilestoneDetailMilestoneDeleted extends MilestoneDetailEvent {
  final String milestoneId;
  const MilestoneDetailMilestoneDeleted(this.milestoneId);
  @override
  List<Object?> get props => [milestoneId];
}

final class MilestoneDetailMilestoneCompletionToggled extends MilestoneDetailEvent {
  final Milestone milestone;
  final bool isCompleted;
  const MilestoneDetailMilestoneCompletionToggled(this.milestone, this.isCompleted);
  @override
  List<Object?> get props => [milestone, isCompleted];
}

// --- State ---
enum MilestoneDetailStatus { initial, loading, success, failure }

final class MilestoneDetailState extends Equatable {
  final MilestoneDetailStatus status;
  final Goal? goal;
  final List<Milestone> milestones;
  final String? errorMessage;

  const MilestoneDetailState({
    this.status = MilestoneDetailStatus.initial,
    this.goal,
    this.milestones = const [],
    this.errorMessage,
  });

  double get progress {
    if (milestones.isEmpty) return 0;
    final completed = milestones.where((m) => m.isCompleted).length;
    return completed / milestones.length;
  }

  MilestoneDetailState copyWith({
    MilestoneDetailStatus? status,
    Goal? goal,
    List<Milestone>? milestones,
    String? errorMessage,
  }) {
    return MilestoneDetailState(
      status: status ?? this.status,
      goal: goal ?? this.goal,
      milestones: milestones ?? this.milestones,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, goal, milestones, errorMessage];
}

// --- Bloc ---
class MilestoneDetailBloc extends Bloc<MilestoneDetailEvent, MilestoneDetailState> {
  final MilestoneRepository _repository;

  MilestoneDetailBloc({required MilestoneRepository repository})
      : _repository = repository,
        super(const MilestoneDetailState()) {
    on<MilestoneDetailSubscriptionRequested>(_onSubscriptionRequested);
    on<MilestoneDetailMilestoneCreated>(_onMilestoneCreated);
    on<MilestoneDetailMilestoneUpdated>(_onMilestoneUpdated);
    on<MilestoneDetailMilestoneDeleted>(_onMilestoneDeleted);
    on<MilestoneDetailMilestoneCompletionToggled>(_onCompletionToggled);
  }

  Future<void> _onSubscriptionRequested(
    MilestoneDetailSubscriptionRequested event,
    Emitter<MilestoneDetailState> emit,
  ) async {
    AppLogger.d('Milestone detail subscription requested for goal: ${event.goalId}');
    emit(state.copyWith(status: MilestoneDetailStatus.loading));

    // Fetch goal once
    final goal = await _repository.getGoal(event.goalId);
    if (goal == null) {
      AppLogger.w('Goal not found for detail view: ${event.goalId}');
      emit(state.copyWith(status: MilestoneDetailStatus.failure, errorMessage: 'Goal not found'));
      return;
    }
    emit(state.copyWith(goal: goal));

    // Subscribe to milestones stream
    await emit.forEach<List<Milestone>>(
      _repository.getMilestonesStream(event.goalId),
      onData: (milestones) {
        AppLogger.d('Milestones updated for goal ${event.goalId}: ${milestones.length} items');
        return state.copyWith(
          status: MilestoneDetailStatus.success,
          milestones: milestones,
        );
      },
      onError: (e, s) {
        AppLogger.e('Milestones Stream Error', e, s);
        return state.copyWith(
          status: MilestoneDetailStatus.failure,
          errorMessage: 'Failed to load milestones',
        );
      },
    );
  }

  Future<void> _onMilestoneCreated(
    MilestoneDetailMilestoneCreated event,
    Emitter<MilestoneDetailState> emit,
  ) async {
    try {
      AppLogger.d('Creating milestone in detail view: ${event.milestone.title}');
      final createdMilestone = await _repository.createMilestone(event.milestone);
      
      final currentMilestones = List<Milestone>.from(state.milestones)..add(createdMilestone);
      // Sort if necessary, traditionally by index or date?
      
      emit(state.copyWith(
        status: MilestoneDetailStatus.success,
        milestones: currentMilestones,
      ));
    } catch (e, s) {
      AppLogger.e('Failed to create milestone in Bloc', e, s);
    }
  }

  Future<void> _onMilestoneUpdated(
    MilestoneDetailMilestoneUpdated event,
    Emitter<MilestoneDetailState> emit,
  ) async {
    try {
      AppLogger.d('Updating milestone in detail view: ${event.milestone.id}');
      final updatedMilestone = await _repository.updateMilestone(event.milestone);
      
      final currentMilestones = List<Milestone>.from(state.milestones);
      final index = currentMilestones.indexWhere((m) => m.id == updatedMilestone.id);
      if (index >= 0) {
        currentMilestones[index] = updatedMilestone;
      }
      
      emit(state.copyWith(
        status: MilestoneDetailStatus.success,
        milestones: currentMilestones,
      ));
    } catch (e, s) {
      AppLogger.e('Failed to update milestone in Bloc', e, s);
    }
  }

  Future<void> _onMilestoneDeleted(
    MilestoneDetailMilestoneDeleted event,
    Emitter<MilestoneDetailState> emit,
  ) async {
    try {
      AppLogger.d('Deleting milestone in detail view: ${event.milestoneId}');
      await _repository.deleteMilestone(event.milestoneId);
      
      final currentMilestones = List<Milestone>.from(state.milestones)
        ..removeWhere((m) => m.id == event.milestoneId);
        
      emit(state.copyWith(
        status: MilestoneDetailStatus.success,
        milestones: currentMilestones,
      ));
    } catch (e, s) {
      AppLogger.e('Failed to delete milestone in Bloc', e, s);
    }
  }

  Future<void> _onCompletionToggled(
    MilestoneDetailMilestoneCompletionToggled event,
    Emitter<MilestoneDetailState> emit,
  ) async {
    try {
      AppLogger.d('Toggling completion for milestone: ${event.milestone.id} to ${event.isCompleted}');
      final updated = Milestone(
        id: event.milestone.id,
        goalId: event.milestone.goalId,
        title: event.milestone.title,
        targetDate: event.milestone.targetDate,
        notes: event.milestone.notes,
        bannerUrl: event.milestone.bannerUrl,
        isCompleted: event.isCompleted,
        completedAt: event.isCompleted ? DateTime.now() : null,
        orderIndex: event.milestone.orderIndex,
        createdAt: event.milestone.createdAt,
        updatedAt: DateTime.now(),
      );
      final resultMilestone = await _repository.updateMilestone(updated);
      
      final currentMilestones = List<Milestone>.from(state.milestones);
      final index = currentMilestones.indexWhere((m) => m.id == resultMilestone.id);
      if (index >= 0) {
        currentMilestones[index] = resultMilestone;
      }
      
      emit(state.copyWith(
        status: MilestoneDetailStatus.success,
        milestones: currentMilestones,
      ));
    } catch (e, s) {
      AppLogger.e('Failed to toggle completion in Bloc', e, s);
    }
  }
}
