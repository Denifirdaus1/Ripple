import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/todo.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/repositories/focus_repository.dart';

enum TimerStatus { initial, running, paused, completed }

class FocusTimerState extends Equatable {
  final TimerStatus status;
  final int duration; // Total duration in seconds
  final int remaining; // Remaining seconds
  final bool isWorkSession;
  final Todo? currentTodo;  // Track which todo we're focusing on

  const FocusTimerState({
    this.status = TimerStatus.initial,
    this.duration = 1500, // 25 mins default
    this.remaining = 1500,
    this.isWorkSession = true,
    this.currentTodo,
  });

  @override
  List<Object?> get props => [status, duration, remaining, isWorkSession, currentTodo];

  FocusTimerState copyWith({
    TimerStatus? status,
    int? duration,
    int? remaining,
    bool? isWorkSession,
    Todo? currentTodo,
    bool clearTodo = false,
  }) {
    return FocusTimerState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      remaining: remaining ?? this.remaining,
      isWorkSession: isWorkSession ?? this.isWorkSession,
      currentTodo: clearTodo ? null : (currentTodo ?? this.currentTodo),
    );
  }
}

class FocusTimerCubit extends Cubit<FocusTimerState> {
  final FocusRepository _focusRepository;
  StreamSubscription<int>? _tickerSubscription;
  DateTime? _sessionStartedAt;

  FocusTimerCubit({required FocusRepository focusRepository}) 
      : _focusRepository = focusRepository,
        super(const FocusTimerState());

  /// Start a focus session for a specific todo
  void startFocusForTodo(Todo todo) {
    final durationMinutes = todo.focusDurationMinutes ?? 25;
    final seconds = durationMinutes * 60;
    
    emit(FocusTimerState(
      status: TimerStatus.initial,
      duration: seconds,
      remaining: seconds,
      isWorkSession: true,
      currentTodo: todo,
    ));
  }

  void setDuration(int minutes) {
    if (state.status == TimerStatus.running) return;
    final seconds = minutes * 60;
    emit(state.copyWith(duration: seconds, remaining: seconds));
  }

  void startTimer() {
    if (state.status == TimerStatus.running) return;
    
    _sessionStartedAt ??= DateTime.now();
    
    emit(state.copyWith(status: TimerStatus.running));
    _tickerSubscription?.cancel();
    _tickerSubscription = Stream.periodic(const Duration(seconds: 1), (x) => x).listen((_) {
      _tick();
    });
  }

  void _tick() {
    if (state.remaining > 0) {
      emit(state.copyWith(remaining: state.remaining - 1));
    } else {
      _tickerSubscription?.cancel();
      _onSessionComplete();
    }
  }

  Future<void> _onSessionComplete() async {
    emit(state.copyWith(status: TimerStatus.completed));
    
    // Save session to database
    if (state.currentTodo != null && _sessionStartedAt != null) {
      await _saveSession(wasCompleted: true, wasInterrupted: false);
    }
  }

  void pauseTimer() {
    if (state.status == TimerStatus.running) {
      _tickerSubscription?.pause();
      emit(state.copyWith(status: TimerStatus.paused));
    }
  }

  void resumeTimer() {
    if (state.status == TimerStatus.paused) {
      _tickerSubscription?.resume();
      emit(state.copyWith(status: TimerStatus.running));
    }
  }

  Future<void> stopTimer() async {
    _tickerSubscription?.cancel();
    
    // Save interrupted session if we were tracking one
    if (state.currentTodo != null && 
        _sessionStartedAt != null && 
        state.status != TimerStatus.initial &&
        state.status != TimerStatus.completed) {
      await _saveSession(wasCompleted: false, wasInterrupted: true);
    }
    
    _sessionStartedAt = null;
    emit(state.copyWith(
      status: TimerStatus.initial,
      remaining: state.duration,
      clearTodo: true,
    ));
  }

  Future<void> _saveSession({
    required bool wasCompleted,
    required bool wasInterrupted,
  }) async {
    if (state.currentTodo == null || _sessionStartedAt == null) return;
    
    final session = FocusSession(
      id: const Uuid().v4(),
      userId: state.currentTodo!.userId,
      todoId: state.currentTodo!.id,
      startedAt: _sessionStartedAt!,
      endedAt: DateTime.now(),
      durationMinutes: (state.duration - state.remaining) ~/ 60,
      sessionType: state.isWorkSession ? SessionType.work : SessionType.breakTime,
      wasCompleted: wasCompleted,
      wasInterrupted: wasInterrupted,
    );
    
    try {
      await _focusRepository.saveSession(session);
    } catch (e) {
      // Log error but don't crash the timer
      // TODO: Add proper error handling/logging
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
