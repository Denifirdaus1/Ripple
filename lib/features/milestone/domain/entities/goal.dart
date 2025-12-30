import 'package:equatable/equatable.dart';

class Goal extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final int? targetYear;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Calculated field (not in DB)
  final double progress; 

  const Goal({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.targetYear,
    required this.createdAt,
    required this.updatedAt,
    this.progress = 0.0,
  });

  @override
  List<Object?> get props => [id, userId, title, description, targetYear, createdAt, updatedAt, progress];

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    int? targetYear,
    DateTime? updatedAt,
    double? progress,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetYear: targetYear ?? this.targetYear,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      progress: progress ?? this.progress,
    );
  }
}
