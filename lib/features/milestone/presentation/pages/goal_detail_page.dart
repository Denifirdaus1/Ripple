import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/milestone_detail_bloc.dart';
import '../widgets/milestone_timeline.dart';
import '../widgets/add_milestone_sheet.dart';

class GoalDetailPage extends StatelessWidget {
  final String goalId;

  const GoalDetailPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MilestoneDetailBloc, MilestoneDetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.paperWhite,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(PhosphorIconsRegular.arrowLeft, color: AppColors.inkBlack),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              state.goal?.title ?? 'Goal',
              style: AppTypography.h3?.copyWith(color: AppColors.inkBlack),
            ),
            actions: [
              IconButton(
                icon: const Icon(PhosphorIconsRegular.dotsThreeVertical, color: AppColors.inkBlack),
                onPressed: () {
                  // Future: Goal options menu (edit, delete)
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddMilestoneSheet(context),
            backgroundColor: AppColors.rippleBlue,
            child: const Icon(PhosphorIconsFill.plus, color: Colors.white),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MilestoneDetailState state) {
    if (state.status == MilestoneDetailStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == MilestoneDetailStatus.failure) {
      return Center(
        child: Text(
          state.errorMessage ?? 'Failed to load goal details',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal Description
          if (state.goal?.description != null && state.goal!.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                state.goal!.description!,
                style: AppTypography.body?.copyWith(color: AppColors.textSecondary),
              ),
            ),

          // Progress Indicator
          _buildProgressSection(state),

          const SizedBox(height: 24),

          // Milestones Timeline
          Text(
            'Milestones',
            style: AppTypography.h4?.copyWith(color: AppColors.inkBlack),
          ),
          const SizedBox(height: 16),

          if (state.milestones.isEmpty)
            _buildEmptyState()
          else
            MilestoneTimeline(
              milestones: state.milestones,
              onMilestoneToggle: (milestone, isCompleted) {
                context.read<MilestoneDetailBloc>().add(
                      MilestoneDetailMilestoneCompletionToggled(milestone, isCompleted),
                    );
              },
              onMilestoneDelete: (milestoneId) {
                context.read<MilestoneDetailBloc>().add(
                      MilestoneDetailMilestoneDeleted(milestoneId),
                    );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(MilestoneDetailState state) {
    final completedCount = state.milestones.where((m) => m.isCompleted).length;
    final totalCount = state.milestones.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppTypography.bodyBold?.copyWith(color: AppColors.inkBlack),
              ),
              Text(
                '$completedCount / $totalCount',
                style: AppTypography.body?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 8,
              backgroundColor: AppColors.softGray,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.successGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(PhosphorIconsRegular.flagCheckered, size: 48, color: AppColors.softGray),
          const SizedBox(height: 16),
          Text(
            'No milestones yet',
            style: AppTypography.body?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first milestone',
            style: AppTypography.caption?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showAddMilestoneSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return AddMilestoneSheet(
          goalId: goalId,
          onSave: (milestone) {
            context.read<MilestoneDetailBloc>().add(
                  MilestoneDetailMilestoneCreated(milestone),
                );
          },
        );
      },
    );
  }
}
