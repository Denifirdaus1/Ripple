import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../../../todo/domain/entities/todo.dart';
import '../../../todo/data/models/todo_model.dart';
import '../models/goal_model.dart';
import '../models/milestone_model.dart';
import '../../../../core/utils/logger.dart';

class MilestoneRepositoryImpl implements MilestoneRepository {
  final SupabaseClient _supabase;

  MilestoneRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // --- Goal CRUD ---

  @override
  Stream<List<Goal>> getGoalsStream() {
    AppLogger.d('Subscribing to goals stream');
    return _supabase.from('goals').stream(primaryKey: ['id']).order('created_at').map(
          (data) => data.map((json) => GoalModel.fromJson(json)).toList(),
        );
  }

  @override
  Future<Goal?> getGoal(String id) async {
    try {
      AppLogger.d('Fetching goal: $id');
      final data = await _supabase.from('goals').select().eq('id', id).maybeSingle();
      if (data == null) {
        AppLogger.w('Goal not found: $id');
        return null;
      }
      return GoalModel.fromJson(data);
    } catch (e, s) {
      AppLogger.e('Failed to fetch goal: $id', e, s);
      rethrow;
    }
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    try {
      final model = GoalModel.fromEntity(goal);
      final data = await _supabase.from('goals').insert(model.toJson()).select().single();
      AppLogger.i('Goal created successfully');
      return GoalModel.fromJson(data);
    } catch (e, s) {
      AppLogger.e('Failed to create goal', e, s);
      rethrow;
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      AppLogger.d('Deleting goal: $id');
      await _supabase.from('goals').delete().eq('id', id);
      AppLogger.i('Goal deleted successfully');
    } catch (e, s) {
      AppLogger.e('Failed to delete goal', e, s);
      rethrow;
    }
  }

  // --- Milestone CRUD ---

  @override
  Stream<List<Milestone>> getMilestonesStream(String goalId) {
    AppLogger.d('Subscribing to milestones stream for goal: $goalId');
    return _supabase
        .from('milestones')
        .stream(primaryKey: ['id'])
        .eq('goal_id', goalId)
        .order('order_index')
        .map(
          (data) => data.map((json) => MilestoneModel.fromJson(json)).toList(),
        );
  }

  @override
  Future<Milestone> createMilestone(Milestone milestone) async {
    try {
      AppLogger.d('Creating milestone: ${milestone.title}');
      final model = MilestoneModel.fromEntity(milestone);
      final data = await _supabase.from('milestones').insert(model.toJson()).select().single();
      AppLogger.i('Milestone created successfully');
      return MilestoneModel.fromJson(data);
    } catch (e, s) {
      AppLogger.e('Failed to create milestone', e, s);
      rethrow;
    }
  }

  @override
  Future<Milestone> updateMilestone(Milestone milestone) async {
    try {
      AppLogger.d('Updating milestone: ${milestone.id}');
      final model = MilestoneModel.fromEntity(milestone);
      final data = await _supabase.from('milestones').update(model.toJson()).eq('id', milestone.id).select().single();
      AppLogger.i('Milestone updated successfully');
      return MilestoneModel.fromJson(data);
    } catch (e, s) {
      AppLogger.e('Failed to update milestone', e, s);
      rethrow;
    }
  }

  @override
  Future<void> deleteMilestone(String id) async {
    try {
      AppLogger.d('Deleting milestone: $id');
      await _supabase.from('milestones').delete().eq('id', id);
      AppLogger.i('Milestone deleted successfully');
    } catch (e, s) {
      AppLogger.e('Failed to delete milestone', e, s);
      rethrow;
    }
  }

  // --- Todo <-> Milestone Attachment ---

  @override
  Stream<List<Todo>> getTodosForMilestone(String milestoneId) {
    AppLogger.d('Subscribing to todos for milestone: $milestoneId');
    return _supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .eq('milestone_id', milestoneId)
        .order('created_at')
        .map(
          (data) => data.map((json) => TodoModel.fromJson(json)).toList(),
        );
  }

  @override
  Future<void> attachTodoToMilestone(String todoId, String milestoneId) async {
    try {
      AppLogger.d('Attaching todo $todoId to milestone $milestoneId');
      await _supabase.from('todos').update({'milestone_id': milestoneId}).eq('id', todoId);
      AppLogger.i('Todo attached to milestone successfully');
    } catch (e, s) {
      AppLogger.e('Failed to attach todo to milestone', e, s);
      rethrow;
    }
  }

  @override
  Future<void> detachTodoFromMilestone(String todoId) async {
    try {
      AppLogger.d('Detaching todo $todoId from milestone');
      await _supabase.from('todos').update({'milestone_id': null}).eq('id', todoId);
      AppLogger.i('Todo detached from milestone successfully');
    } catch (e, s) {
      AppLogger.e('Failed to detach todo from milestone', e, s);
      rethrow;
    }
  }
}
