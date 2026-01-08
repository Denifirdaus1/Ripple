import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

// ==================== EVENTS ====================

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;
  const ProfileLoadRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class ProfileDisplayNameChanged extends ProfileEvent {
  final String displayName;
  const ProfileDisplayNameChanged(this.displayName);
  @override
  List<Object?> get props => [displayName];
}

class ProfileAvatarUploadRequested extends ProfileEvent {
  final Uint8List imageBytes;
  final String fileName;
  const ProfileAvatarUploadRequested(this.imageBytes, this.fileName);
  @override
  List<Object?> get props => [imageBytes, fileName];
}

class ProfileAvatarDeleteRequested extends ProfileEvent {
  const ProfileAvatarDeleteRequested();
}

// ==================== STATE ====================

enum ProfileStatus { initial, loading, loaded, saving, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}

// ==================== BLOC ====================

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;
  String? _currentUserId;

  ProfileBloc({required ProfileRepository repository})
    : _repository = repository,
      super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileDisplayNameChanged>(_onDisplayNameChanged);
    on<ProfileAvatarUploadRequested>(_onAvatarUploadRequested);
    on<ProfileAvatarDeleteRequested>(_onAvatarDeleteRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    debugPrint('🧑 [ProfileBloc] Loading profile for: ${event.userId}');
    _currentUserId = event.userId;
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final profile = await _repository.getProfile(event.userId);
      debugPrint('🧑 [ProfileBloc] Profile loaded: ${profile?.displayName}');
      emit(state.copyWith(status: ProfileStatus.loaded, profile: profile));
    } catch (e) {
      debugPrint('❌ [ProfileBloc] Error loading profile: $e');
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDisplayNameChanged(
    ProfileDisplayNameChanged event,
    Emitter<ProfileState> emit,
  ) async {
    if (_currentUserId == null) return;

    debugPrint('🧑 [ProfileBloc] Updating display name: ${event.displayName}');
    emit(state.copyWith(status: ProfileStatus.saving));

    try {
      await _repository.updateDisplayName(_currentUserId!, event.displayName);

      final updatedProfile = state.profile?.copyWith(
        displayName: event.displayName,
        updatedAt: DateTime.now(),
      );

      debugPrint('✅ [ProfileBloc] Display name updated');
      emit(
        state.copyWith(status: ProfileStatus.loaded, profile: updatedProfile),
      );
    } catch (e) {
      debugPrint('❌ [ProfileBloc] Error updating name: $e');
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAvatarUploadRequested(
    ProfileAvatarUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (_currentUserId == null) return;

    debugPrint(
      '🧑 [ProfileBloc] Uploading avatar, size: ${event.imageBytes.length} bytes',
    );
    emit(state.copyWith(status: ProfileStatus.saving));

    try {
      final newAvatarUrl = await _repository.uploadAvatar(
        _currentUserId!,
        event.imageBytes,
        event.fileName,
      );

      final updatedProfile = state.profile?.copyWith(
        avatarUrl: newAvatarUrl,
        updatedAt: DateTime.now(),
      );

      debugPrint('✅ [ProfileBloc] Avatar uploaded: $newAvatarUrl');
      emit(
        state.copyWith(status: ProfileStatus.loaded, profile: updatedProfile),
      );
    } catch (e) {
      debugPrint('❌ [ProfileBloc] Error uploading avatar: $e');
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAvatarDeleteRequested(
    ProfileAvatarDeleteRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (_currentUserId == null) return;

    debugPrint('🧑 [ProfileBloc] Deleting avatar');
    emit(state.copyWith(status: ProfileStatus.saving));

    try {
      await _repository.deleteAvatar(_currentUserId!);

      final updatedProfile = state.profile?.copyWith(
        avatarUrl: null,
        updatedAt: DateTime.now(),
      );

      debugPrint('✅ [ProfileBloc] Avatar deleted');
      emit(
        state.copyWith(status: ProfileStatus.loaded, profile: updatedProfile),
      );
    } catch (e) {
      debugPrint('❌ [ProfileBloc] Error deleting avatar: $e');
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
