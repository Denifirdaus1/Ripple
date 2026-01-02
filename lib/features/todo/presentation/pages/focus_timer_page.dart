import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ripple_button.dart';
import '../bloc/focus_timer_cubit.dart';

class FocusTimerPage extends StatelessWidget {
  const FocusTimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Uses global FocusTimerCubit from app.dart MultiBlocProvider
    return const _FocusTimerView();
  }
}

class _FocusTimerView extends StatelessWidget {
  const _FocusTimerView();

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paperWhite,
      body: BlocConsumer<FocusTimerCubit, FocusTimerState>(
        listener: (context, state) {
          if (state.status == TimerStatus.completed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Session Completed! Great job!')),
            );
          }
        },
        builder: (context, state) {
          final progress = state.duration > 0 ? state.remaining / state.duration : 0.0;
          final currentTodo = state.currentTodo;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show which todo we're focusing on
                if (currentTodo != null) ...[
                  Text(
                    currentTodo.title,
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  state.isWorkSession ? 'Focus Time' : 'Break Time',
                  style: AppTypography.textTheme.headlineMedium,
                ),
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: AppColors.softGray,
                        color: state.isWorkSession ? AppColors.coralPink : AppColors.rippleBlue,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      _formatTime(state.remaining),
                      style: AppTypography.textTheme.displayLarge?.copyWith(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.status == TimerStatus.initial || state.status == TimerStatus.paused)
                      RippleButton(
                        text: state.status == TimerStatus.initial ? 'Start' : 'Resume',
                        onPressed: () => context.read<FocusTimerCubit>().startTimer(),
                        icon: PhosphorIconsFill.play,
                        type: RippleButtonType.primary,
                      ),
                    
                    if (state.status == TimerStatus.running)
                      RippleButton(
                        text: 'Pause',
                        onPressed: () => context.read<FocusTimerCubit>().pauseTimer(),
                        icon: PhosphorIconsFill.pause,
                        type: RippleButtonType.secondary,
                      ),

                    if (state.status != TimerStatus.initial) ...[
                      const SizedBox(width: 20),
                      RippleButton(
                        text: 'Stop',
                        onPressed: () => context.read<FocusTimerCubit>().stopTimer(),
                        icon: PhosphorIconsFill.stop,
                        type: RippleButtonType.danger,
                      ),
                    ],
                  ],
                ),
                // Show message when no todo is selected
                if (currentTodo == null && state.status == TimerStatus.initial) ...[
                  const SizedBox(height: 40),
                  Text(
                    'Select a task with Focus Mode enabled to start',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
