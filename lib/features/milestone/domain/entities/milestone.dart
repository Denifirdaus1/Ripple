import 'package:equatable/equatable.dart';

class Milestone extends Equatable {
  final String id;
  final String goalId;
  final String title;
  final Map<String, dynamic>? notes; // JSONB
  final DateTime? targetDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final int orderIndex;
  final String? bannerUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Milestone({
    required this.id,
    required this.goalId,
    required this.title,
    this.notes,
    this.targetDate,
    required this.isCompleted,
    this.completedAt,
    required this.orderIndex,
    this.bannerUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, goalId, title, notes, targetDate, isCompleted, completedAt, orderIndex, bannerUrl, createdAt, updatedAt];

  Milestone copyWith({
    String? title,
    Map<String, dynamic>? notes,
    DateTime? targetDate,
    bool? isCompleted,
    DateTime? completedAt,
    int? orderIndex,
    String? bannerUrl,
  }) {
    return Milestone(
      id: id,
      goalId: goalId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      orderIndex: orderIndex ?? this.orderIndex,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
