import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ripple_button.dart';
import '../bloc/focus_timer_cubit.dart';

class FocusTimerPage extends StatelessWidget {
  const FocusTimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FocusTimerCubit(), // Cubit local to this page for now, or global?
      // If we want the timer to run in background while browsing todos, it should be Global.
      // For MVP, let's keep it local to this page, or lift it up if needed.
      // PLAN_003 says "Uses Cubit", doesn't specify scope. Global is better for productivity apps.
      // But for now, let's keep it local, if user leaves page, timer dies (MVP limitation).
      // Actually, let's make it safe: if we navigate away, it dies. 
      // Ideally, it should be in MultiBlocProvider in app.dart if we want global.
      // I'll stick to local for simplicity unless specified otherwise.
      child: const _FocusTimerView(),
    );
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.x),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                        onPressed: () => context.read<FocusTimerCubit>().startTimer(), // Resume/Start same logic
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
              ],
            ),
          );
        },
      ),
    );
  }
}
