import '../../domain/entities/goal.dart';

class GoalModel extends Goal {
  const GoalModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    super.targetYear,
    required super.createdAt,
    required super.updatedAt,
    super.progress,
  });

  factory GoalModel.fromEntity(Goal goal) {
    return GoalModel(
      id: goal.id,
      userId: goal.userId,
      title: goal.title,
      description: goal.description,
      targetYear: goal.targetYear,
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
      progress: goal.progress,
    );
  }

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      targetYear: json['target_year'] as int?,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
      // Progress calculation is usually done separately join or view, 
      // but if we use a view, it might come in json. 
      // For now default to 0.0 or check if 'progress' exists in json.
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'target_year': targetYear,
      // created_at / updated_at handled by DB
    };
  }
}
