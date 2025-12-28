import 'package:equatable/equatable.dart';

/// User entity representing the core user data
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
  });

  /// Check if user has a display name
  bool get hasDisplayName => displayName != null && displayName!.isNotEmpty;

  /// Check if user has a photo
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  /// Get display name or email as fallback
  String get displayNameOrEmail => hasDisplayName ? displayName! : email;

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, createdAt];
}
