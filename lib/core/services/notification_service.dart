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

  /// Internal logging helper
  void _log(String message) {
    debugPrint('[NotificationService] $message');
  }

  /// Requests notification permissions from the user.
  /// Uses platform-aware helper for Android 13+ compatibility.
  Future<bool> requestPermission() async {
    _log('requestPermission() called');
    final result = await NotificationPermissionHelper.requestPermission();
    _log('requestPermission() result: $result');
    return result;
  }

  /// Checks if notification permission is currently granted.
  Future<bool> isPermissionGranted() async {
    final result = await NotificationPermissionHelper.isGranted();
    _log('isPermissionGranted(): $result');
    return result;
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
    _log('initialize() called with userId: ${userId.substring(0, 8)}...');

    // CASE 1: Different user logged in (logout → login with different account)
    if (_currentUserId != null && _currentUserId != userId) {
      _log('Different user detected, resetting notification state...');
      _isInitialized = false;
    }

    // CASE 2: Same user, but force re-sync token (handles long inactive period)
    // Always sync token on initialize to ensure it's fresh
    _currentUserId = userId;

    // Check permission status (don't request again, already done in main.dart)
    final hasPermission = await isPermissionGranted();
    _log('Permission status in initialize(): $hasPermission');

    if (hasPermission) {
      // Always sync token (even if already initialized)
      // This ensures token is always fresh after long inactive periods
      await _syncToken(userId);

      // Only set up listeners once
      if (!_isInitialized) {
        _log('Setting up FCM listeners...');

        // Listen for Token Refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _log('FCM Token refreshed, syncing...');
          _repository.saveDeviceToken(newToken, userId);
        });

        // Handle Foreground Messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _log('Foreground message: ${message.notification?.title}');
        });

        _isInitialized = true;
        _log('FCM listeners initialized successfully');
      } else {
        _log('FCM listeners already initialized, skipped');
      }
    } else {
      _log('Notification permission denied, skipping FCM setup');
    }
  }

  /// Call this on logout to reset state for next user.
  void reset() {
    _isInitialized = false;
    _currentUserId = null;
    _log('NotificationService reset');
  }

  /// Force sync token (useful after long inactive period).
  Future<void> forceTokenSync(String userId) async {
    await _syncToken(userId);
  }

  /// Helper to get and save FCM token.
  Future<void> _syncToken(String userId) async {
    _log('_syncToken() starting...');
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        _log('FCM Token obtained: ${token.substring(0, 20)}...');
        await _repository.saveDeviceToken(token, userId);
        _log('FCM Token synced successfully to database');
      } else {
        _log('FCM Token is null!');
      }
    } catch (e, stack) {
      _log('Error syncing token: $e');
      _log('Stack: $stack');
    }
  }
}
