import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile_model.dart';

/// Remote data source for profile operations
class ProfileRemoteDataSource {
  final SupabaseClient _client;

  ProfileRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Fetch user profile by ID
  Future<UserProfileModel?> getProfile(String userId) async {
    debugPrint('📱 [ProfileDS] Fetching profile for user: $userId');

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      debugPrint('📱 [ProfileDS] No profile found for user: $userId');
      return null;
    }

    debugPrint('📱 [ProfileDS] Profile fetched: ${response['display_name']}');
    return UserProfileModel.fromJson(response);
  }

  /// Stream profile updates
  Stream<UserProfileModel?> watchProfile(String userId) {
    debugPrint('📱 [ProfileDS] Starting profile stream for user: $userId');

    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) {
          if (data.isEmpty) return null;
          return UserProfileModel.fromJson(data.first);
        });
  }

  /// Update display name
  Future<void> updateDisplayName(String userId, String displayName) async {
    debugPrint('📱 [ProfileDS] Updating display name to: $displayName');

    await _client
        .from('profiles')
        .update({
          'display_name': displayName,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);

    debugPrint('✅ [ProfileDS] Display name updated successfully');
  }

  /// Upload avatar image to storage
  Future<String> uploadAvatar(
    String userId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    debugPrint('📱 [ProfileDS] Uploading avatar for user: $userId');
    debugPrint('📱 [ProfileDS] Image size: ${imageBytes.length} bytes');

    // Generate unique file path: userId/avatar_timestamp.ext
    final extension = fileName.split('.').last;
    final filePath =
        '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';

    debugPrint('📱 [ProfileDS] Upload path: $filePath');

    // Upload to storage
    await _client.storage
        .from('user-avatars')
        .uploadBinary(
          filePath,
          imageBytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    // Get public URL
    final publicUrl = _client.storage
        .from('user-avatars')
        .getPublicUrl(filePath);

    debugPrint('✅ [ProfileDS] Avatar uploaded: $publicUrl');

    // Update profile with new avatar URL
    await _client
        .from('profiles')
        .update({
          'avatar_url': publicUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);

    debugPrint('✅ [ProfileDS] Profile avatar_url updated');

    return publicUrl;
  }

  /// Delete avatar from storage
  Future<void> deleteAvatar(String userId, String? currentAvatarUrl) async {
    if (currentAvatarUrl == null || currentAvatarUrl.isEmpty) {
      debugPrint('📱 [ProfileDS] No avatar to delete');
      return;
    }

    debugPrint('📱 [ProfileDS] Deleting avatar for user: $userId');

    // Extract file path from URL
    final uri = Uri.parse(currentAvatarUrl);
    final pathSegments = uri.pathSegments;
    final bucketIndex = pathSegments.indexOf('user-avatars');
    if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      debugPrint('📱 [ProfileDS] Deleting file: $filePath');

      await _client.storage.from('user-avatars').remove([filePath]);
    }

    // Clear avatar_url in profile
    await _client
        .from('profiles')
        .update({
          'avatar_url': null,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);

    debugPrint('✅ [ProfileDS] Avatar deleted');
  }
}
