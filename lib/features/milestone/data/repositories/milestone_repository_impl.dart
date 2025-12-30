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
    return _supabase.from('goals').stream(primaryKey: ['id']).order('created_at').map(
          (data) => data.map((json) => GoalModel.fromJson(json)).toList(),
        );
  }

  @override
  Future<Goal?> getGoal(String id) async {
    final data = await _supabase.from('goals').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return GoalModel.fromJson(data);
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    try {
      final model = GoalModel.fromEntity(goal);
      final data = await _supabase.from('goals').insert(model.toJson()).select().single();
      return GoalModel.fromJson(data);
    } catch (e, s) {
      AppLogger.e('Failed to create goal', e, s);
      rethrow;
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      await _supabase.from('goals').delete().eq('id', id);
    } catch (e, s) {
      AppLogger.e('Failed to delete goal', e, s);
      rethrow;
    }
  }

  // --- Milestone CRUD ---

  @override
  Stream<List<Milestone>> getMilestonesStream(String goalId) {
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
  Future<void> createMilestone(Milestone milestone) async {
    final model = MilestoneModel.fromEntity(milestone);
    await _supabase.from('milestones').insert(model.toJson());
  }

  @override
  Future<void> updateMilestone(Milestone milestone) async {
    final model = MilestoneModel.fromEntity(milestone);
    await _supabase.from('milestones').update(model.toJson()).eq('id', milestone.id);
  }

  @override
  Future<void> deleteMilestone(String id) async {
    await _supabase.from('milestones').delete().eq('id', id);
  }

  // --- Todo <-> Milestone Attachment ---

  @override
  Stream<List<Todo>> getTodosForMilestone(String milestoneId) {
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
    await _supabase.from('todos').update({'milestone_id': milestoneId}).eq('id', todoId);
  }

  @override
  Future<void> detachTodoFromMilestone(String todoId) async {
    await _supabase.from('todos').update({'milestone_id': null}).eq('id', todoId);
  }
}
