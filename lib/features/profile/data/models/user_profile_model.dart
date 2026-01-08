import '../../domain/entities/user_profile.dart';

/// Data model for UserProfile with JSON serialization
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    super.displayName,
    super.avatarUrl,
    required super.timezone,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from Supabase JSON response
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      timezone: json['timezone'] as String? ?? 'UTC',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'timezone': timezone,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create model from entity
  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      displayName: entity.displayName,
      avatarUrl: entity.avatarUrl,
      timezone: entity.timezone,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to domain entity
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      displayName: displayName,
      avatarUrl: avatarUrl,
      timezone: timezone,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
