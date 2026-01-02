import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ripple_page_header.dart';
import '../../../../core/injection/injection_container.dart'; // Correct path
import '../bloc/goal_list_bloc.dart';
import '../widgets/goal_card.dart';
import '../../domain/entities/goal.dart';

class GoalsDashboardPage extends StatelessWidget {
  const GoalsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<GoalListBloc>()..add(GoalListSubscriptionRequested()),
      child: const _GoalsDashboardView(),
    );
  }
}

class _GoalsDashboardView extends StatelessWidget {
  const _GoalsDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const RipplePageHeader(
              title: 'Goals',
              subtitle: 'Your big picture.',
            ),
            Expanded(
              child: BlocBuilder<GoalListBloc, GoalListState>(
                builder: (context, state) {
                  if (state.status == GoalListStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state.goals.isEmpty) {
                    return const Center(child: Text('No goals yet. Start dreaming!'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.goals.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final goal = state.goals[index];
                      return GoalCard(
                        goal: goal,
                        onTap: () {
                           context.push('/goals/${goal.id}');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _AddGoalDialog extends StatefulWidget {
  const _AddGoalDialog();

  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isNotEmpty) {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final newGoal = Goal(
        id: '', // Repo generates ID usually or we generate GUID.
        userId: userId, // Fix: Must be populated
        title: title,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      context.read<GoalListBloc>().add(GoalListGoalCreated(newGoal));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Goal'),
      content: TextField(
        controller: _titleController,
        decoration: const InputDecoration(hintText: 'e.g. Learn Flutter'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
