import '../../domain/entities/user_entity.dart';

/// User model for data layer
/// Handles conversion between API/database data and domain entity
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.createdAt,
  });

  /// Create UserModel from Supabase User object
  factory UserModel.fromSupabaseUser(Map<String, dynamic> userData) {
    return UserModel(
      id: userData['id'] as String,
      email: userData['email'] as String,
      displayName: userData['user_metadata']?['full_name'] as String? ??
          userData['user_metadata']?['name'] as String?,
      photoUrl: userData['user_metadata']?['avatar_url'] as String? ??
          userData['user_metadata']?['picture'] as String?,
      createdAt: userData['created_at'] != null
          ? DateTime.parse(userData['created_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Create UserEntity from UserModel
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: createdAt,
    );
  }
}
