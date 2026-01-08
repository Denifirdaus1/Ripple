import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

/// Implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({ProfileRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ProfileRemoteDataSource();

  @override
  Future<UserProfile?> getProfile(String userId) async {
    debugPrint('📦 [ProfileRepo] Getting profile for: $userId');
    final model = await _remoteDataSource.getProfile(userId);
    return model?.toEntity();
  }

  @override
  Stream<UserProfile?> watchProfile(String userId) {
    debugPrint('📦 [ProfileRepo] Watching profile for: $userId');
    return _remoteDataSource
        .watchProfile(userId)
        .map((model) => model?.toEntity());
  }

  @override
  Future<void> updateDisplayName(String userId, String displayName) async {
    debugPrint('📦 [ProfileRepo] Updating display name: $displayName');
    await _remoteDataSource.updateDisplayName(userId, displayName);
  }

  @override
  Future<String> uploadAvatar(
    String userId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    debugPrint(
      '📦 [ProfileRepo] Uploading avatar, size: ${imageBytes.length} bytes',
    );
    return await _remoteDataSource.uploadAvatar(userId, imageBytes, fileName);
  }

  @override
  Future<void> deleteAvatar(String userId) async {
    debugPrint('📦 [ProfileRepo] Deleting avatar');
    final profile = await _remoteDataSource.getProfile(userId);
    await _remoteDataSource.deleteAvatar(userId, profile?.avatarUrl);
  }
}
