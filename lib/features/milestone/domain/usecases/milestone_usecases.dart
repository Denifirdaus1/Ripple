import '../repositories/milestone_repository.dart';
import '../entities/goal.dart';
import '../entities/milestone.dart';

class GetGoalsStream {
  final MilestoneRepository repository;
  GetGoalsStream(this.repository);
  Stream<List<Goal>> call() => repository.getGoalsStream();
}

class GetGoal {
  final MilestoneRepository repository;
  GetGoal(this.repository);
  Future<Goal?> call(String id) => repository.getGoal(id);
}

class CreateGoal {
  final MilestoneRepository repository;
  CreateGoal(this.repository);
  Future<Goal> call(Goal goal) => repository.createGoal(goal);
}

class GetMilestonesStream {
  final MilestoneRepository repository;
  GetMilestonesStream(this.repository);
  Stream<List<Milestone>> call(String goalId) => repository.getMilestonesStream(goalId);
}

class CreateMilestone {
  final MilestoneRepository repository;
  CreateMilestone(this.repository);
  Future<void> call(Milestone milestone) => repository.createMilestone(milestone);
}

class UpdateMilestone {
  final MilestoneRepository repository;
  UpdateMilestone(this.repository);
  Future<void> call(Milestone milestone) => repository.updateMilestone(milestone);
}

class DeleteMilestone {
  final MilestoneRepository repository;
  DeleteMilestone(this.repository);
  Future<void> call(String id) => repository.deleteMilestone(id);
}
