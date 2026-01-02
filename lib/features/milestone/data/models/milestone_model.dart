import '../../domain/entities/milestone.dart';

class MilestoneModel extends Milestone {
  const MilestoneModel({
    required super.id,
    required super.goalId,
    required super.title,
    super.notes,
    super.targetDate,
    required super.isCompleted,
    super.completedAt,
    required super.orderIndex,
    super.bannerUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MilestoneModel.fromEntity(Milestone milestone) {
    return MilestoneModel(
      id: milestone.id,
      goalId: milestone.goalId,
      title: milestone.title,
      notes: milestone.notes,
      targetDate: milestone.targetDate,
      isCompleted: milestone.isCompleted,
      completedAt: milestone.completedAt,
      orderIndex: milestone.orderIndex,
      bannerUrl: milestone.bannerUrl,
      createdAt: milestone.createdAt,
      updatedAt: milestone.updatedAt,
    );
  }

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      id: json['id'] as String,
      goalId: json['goal_id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as Map<String, dynamic>?,
      targetDate: json['target_date'] != null ? DateTime.parse(json['target_date']) : null,
      isCompleted: json['is_completed'] as bool,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']).toLocal() : null,
      orderIndex: json['order_index'] as int,
      bannerUrl: json['banner_url'] as String?,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'goal_id': goalId,
      'title': title,
      'notes': notes,
      'target_date': targetDate?.toIso8601String().split('T').first,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'order_index': orderIndex,
      'banner_url': bannerUrl,
      // created_at / updated_at handled by DB
    };
  }
}
