import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Platform-aware notification permission helper.
///
/// Handles the difference between iOS (uses FirebaseMessaging) and
/// Android 13+ (requires runtime POST_NOTIFICATIONS permission).
class NotificationPermissionHelper {
  /// Detailed logging for debugging permission issues
  static void _log(String message) {
    debugPrint('[NotificationPermission] $message');
  }

  /// Request notification permission with platform-specific handling.
  /// Returns true if permission granted, false otherwise.
  static Future<bool> requestPermission() async {
    _log('requestPermission() called. Platform: ${Platform.operatingSystem}');

    if (Platform.isAndroid) {
      return await _requestAndroidPermission();
    } else if (Platform.isIOS) {
      return await _requestIosPermission();
    } else {
      _log('Unsupported platform, returning true');
      return true;
    }
  }

  /// Check current permission status without requesting.
  static Future<bool> isGranted() async {
    _log('isGranted() called');

    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      _log('Android permission status: $status');
      return status.isGranted;
    } else if (Platform.isIOS) {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      _log('iOS authorization status: ${settings.authorizationStatus}');
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }
    return true;
  }

  static Future<bool> _requestAndroidPermission() async {
    _log('_requestAndroidPermission() started');

    try {
      // Check current status first
      final currentStatus = await Permission.notification.status;
      _log('Current Android status: $currentStatus');
      _log('  isGranted: ${currentStatus.isGranted}');
      _log('  isDenied: ${currentStatus.isDenied}');
      _log('  isPermanentlyDenied: ${currentStatus.isPermanentlyDenied}');
      _log('  isRestricted: ${currentStatus.isRestricted}');
      _log('  isLimited: ${currentStatus.isLimited}');

      if (currentStatus.isGranted) {
        _log('Permission already granted, returning true');
        return true;
      }

      if (currentStatus.isDenied) {
        _log('Permission denied, requesting...');
        final result = await Permission.notification.request();
        _log('Permission request result: $result');
        _log('  isGranted: ${result.isGranted}');
        _log('  isDenied: ${result.isDenied}');
        _log('  isPermanentlyDenied: ${result.isPermanentlyDenied}');
        return result.isGranted;
      }

      if (currentStatus.isPermanentlyDenied) {
        _log('Permission permanently denied, user must enable from settings');
        return false;
      }

      // For any other status, try to request
      _log('Unknown status, attempting request...');
      final result = await Permission.notification.request();
      _log('Request result: $result');
      return result.isGranted;
    } catch (e, stack) {
      _log('ERROR in _requestAndroidPermission: $e');
      _log('Stack trace: $stack');
      return false;
    }
  }

  static Future<bool> _requestIosPermission() async {
    _log('_requestIosPermission() started');

    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _log('iOS requestPermission result: ${settings.authorizationStatus}');

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e, stack) {
      _log('ERROR in _requestIosPermission: $e');
      _log('Stack trace: $stack');
      return false;
    }
  }

  /// Check if permission is permanently denied (requires settings redirect).
  /// Only relevant on Android.
  static Future<bool> isPermanentlyDenied() async {
    if (Platform.isAndroid) {
      final result = await Permission.notification.isPermanentlyDenied;
      _log('isPermanentlyDenied: $result');
      return result;
    }
    return false;
  }

  /// Open app settings for user to manually enable notifications.
  static Future<bool> openSettings() async {
    _log('Opening app settings...');
    final result = await openAppSettings();
    _log('openAppSettings result: $result');
    return result;
  }
}
