import 'package:equatable/equatable.dart';

/// Model for promotional banner data from Supabase
class PromoBanner extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final String? targetRoute;
  final bool isActive;
  final int priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  const PromoBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.targetRoute,
    this.isActive = true,
    this.priority = 0,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory PromoBanner.fromJson(Map<String, dynamic> json) {
    return PromoBanner(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      targetRoute: json['target_route'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      priority: json['priority'] as int? ?? 0,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Check if banner is valid for display (within date range if specified)
  bool get isValidForDisplay {
    final now = DateTime.now();

    if (startDate != null && now.isBefore(startDate!)) {
      return false;
    }

    if (endDate != null && now.isAfter(endDate!)) {
      return false;
    }

    return isActive;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    imageUrl,
    targetRoute,
    isActive,
    priority,
    startDate,
    endDate,
    createdAt,
  ];
}
