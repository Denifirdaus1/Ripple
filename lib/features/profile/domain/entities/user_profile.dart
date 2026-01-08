import 'package:equatable/equatable.dart';

/// Domain entity representing a user's profile
class UserProfile extends Equatable {
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get display name or fallback to 'User'
  String get name => displayName ?? 'User';

  /// Get first letter for avatar fallback
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : 'U';

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? avatarUrl,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    displayName,
    avatarUrl,
    timezone,
    createdAt,
    updatedAt,
  ];
}
