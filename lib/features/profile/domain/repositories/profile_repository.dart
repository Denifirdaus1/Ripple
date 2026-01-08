import 'dart:typed_data';

import '../entities/user_profile.dart';

/// Abstract repository for profile operations
abstract class ProfileRepository {
  /// Get current user's profile
  Future<UserProfile?> getProfile(String userId);

  /// Stream of profile updates
  Stream<UserProfile?> watchProfile(String userId);

  /// Update display name
  Future<void> updateDisplayName(String userId, String displayName);

  /// Upload avatar image and update avatar_url
  /// [imageBytes] - compressed image data
  /// [fileName] - original file name for extension
  Future<String> uploadAvatar(
    String userId,
    Uint8List imageBytes,
    String fileName,
  );

  /// Delete avatar
  Future<void> deleteAvatar(String userId);
}
