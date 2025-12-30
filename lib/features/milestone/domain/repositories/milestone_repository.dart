import '../entities/goal.dart';
import '../entities/milestone.dart';
import '../../../todo/domain/entities/todo.dart';

abstract class MilestoneRepository {
  // Goal CRUD
  Stream<List<Goal>> getGoalsStream();
  Future<Goal?> getGoal(String id);
  Future<Goal> createGoal(Goal goal);
  Future<void> deleteGoal(String id);

  // Milestone CRUD
  Stream<List<Milestone>> getMilestonesStream(String goalId);
  Future<void> createMilestone(Milestone milestone);
  Future<void> updateMilestone(Milestone milestone);
  Future<void> deleteMilestone(String id);

  // Todo <-> Milestone Attachment
  Stream<List<Todo>> getTodosForMilestone(String milestoneId);
  Future<void> attachTodoToMilestone(String todoId, String milestoneId);
  Future<void> detachTodoFromMilestone(String todoId);
}
