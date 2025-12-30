import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TimerStatus { initial, running, paused, completed }

class FocusTimerState extends Equatable {
  final TimerStatus status;
  final int duration; // Total duration in seconds
  final int remaining; // Remaining seconds
  final bool isWorkSession;

  const FocusTimerState({
    this.status = TimerStatus.initial,
    this.duration = 1500, // 25 mins default
    this.remaining = 1500,
    this.isWorkSession = true,
  });

  @override
  List<Object> get props => [status, duration, remaining, isWorkSession];

  FocusTimerState copyWith({
    TimerStatus? status,
    int? duration,
    int? remaining,
    bool? isWorkSession,
  }) {
    return FocusTimerState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      remaining: remaining ?? this.remaining,
      isWorkSession: isWorkSession ?? this.isWorkSession,
    );
  }
}

class FocusTimerCubit extends Cubit<FocusTimerState> {
  // We might inject SaveFocusSession later to record history
  StreamSubscription<int>? _tickerSubscription;

  FocusTimerCubit() : super(const FocusTimerState());

  void setDuration(int minutes) {
    if (state.status == TimerStatus.running) return;
    final seconds = minutes * 60;
    emit(state.copyWith(duration: seconds, remaining: seconds));
  }

  void startTimer() {
    if (state.status == TimerStatus.running) return;
    
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
      emit(state.copyWith(status: TimerStatus.completed));
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

  void stopTimer() {
    _tickerSubscription?.cancel();
    emit(state.copyWith(
      status: TimerStatus.initial,
      remaining: state.duration,
    ));
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
