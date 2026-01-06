import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import 'notification_permission_helper.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationRepository _repository;

  bool _isInitialized = false;
  String? _currentUserId; // Track current user to detect user change

  NotificationService(this._repository);

  /// Requests notification permissions from the user.
  /// Uses platform-aware helper for Android 13+ compatibility.
  Future<bool> requestPermission() async {
    return await NotificationPermissionHelper.requestPermission();
  }

  /// Checks if notification permission is currently granted.
  Future<bool> isPermissionGranted() async {
    return await NotificationPermissionHelper.isGranted();
  }

  /// Checks if permission is permanently denied (Android only).
  Future<bool> isPermissionPermanentlyDenied() async {
    return await NotificationPermissionHelper.isPermanentlyDenied();
  }

  /// Opens app settings for the user to enable notifications manually.
  Future<bool> openNotificationSettings() async {
    return await NotificationPermissionHelper.openSettings();
  }

  /// Initializes notification listeners and syncs token.
  /// Handles: fresh install, re-login, user change, long inactive periods.
  Future<void> initialize(String userId) async {
    // CASE 1: Different user logged in (logout → login with different account)
    if (_currentUserId != null && _currentUserId != userId) {
      if (kDebugMode) {
        debugPrint('Different user detected, resetting notification state...');
      }
      _isInitialized = false;
    }

    // CASE 2: Same user, but force re-sync token (handles long inactive period)
    // Always sync token on initialize to ensure it's fresh
    _currentUserId = userId;

    // Use platform-aware permission request (Android 13+ compatible)
    final hasPermission = await requestPermission();

    if (hasPermission) {
      // Always sync token (even if already initialized)
      // This ensures token is always fresh after long inactive periods
      await _syncToken(userId);

      // Only set up listeners once
      if (!_isInitialized) {
        if (kDebugMode) {
          debugPrint('Setting up FCM listeners...');
        }

        // Listen for Token Refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          if (kDebugMode) {
            debugPrint('FCM Token refreshed, syncing...');
          }
          _repository.saveDeviceToken(newToken, userId);
        });

        // Handle Foreground Messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (kDebugMode) {
            debugPrint('Foreground message: ${message.notification?.title}');
          }
        });

        _isInitialized = true;
      }
    } else {
      if (kDebugMode) {
        debugPrint('Notification permission denied');
      }
    }
  }

  /// Call this on logout to reset state for next user.
  void reset() {
    _isInitialized = false;
    _currentUserId = null;
    if (kDebugMode) {
      debugPrint('NotificationService reset');
    }
  }

  /// Force sync token (useful after long inactive period).
  Future<void> forceTokenSync(String userId) async {
    await _syncToken(userId);
  }

  /// Helper to get and save FCM token.
  Future<void> _syncToken(String userId) async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        if (kDebugMode) {
          debugPrint('FCM Token: ${token.substring(0, 20)}...');
        }
        await _repository.saveDeviceToken(token, userId);
        if (kDebugMode) {
          debugPrint('FCM Token synced successfully');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error syncing token: $e');
      }
    }
  }
}
