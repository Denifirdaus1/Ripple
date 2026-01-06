import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Platform-aware notification permission helper.
///
/// Handles the difference between iOS (uses FirebaseMessaging) and
/// Android 13+ (requires runtime POST_NOTIFICATIONS permission).
class NotificationPermissionHelper {
  /// Request notification permission with platform-specific handling.
  /// Returns true if permission granted, false otherwise.
  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      return await _requestAndroidPermission();
    } else {
      // iOS: Use FirebaseMessaging (works correctly)
      return await _requestIosPermission();
    }
  }

  /// Check current permission status without requesting.
  static Future<bool> isGranted() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }
  }

  static Future<bool> _requestAndroidPermission() async {
    final status = await Permission.notification.status;

    if (kDebugMode) {
      debugPrint('Android notification permission status: $status');
    }

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.notification.request();
      if (kDebugMode) {
        debugPrint('Permission request result: $result');
      }
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (kDebugMode) {
        debugPrint('Notification permission permanently denied');
      }
      // User previously denied and checked "Don't ask again"
      // App needs to guide user to settings
      return false;
    }

    return false;
  }

  static Future<bool> _requestIosPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Check if permission is permanently denied (requires settings redirect).
  /// Only relevant on Android.
  static Future<bool> isPermanentlyDenied() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isPermanentlyDenied;
    }
    return false;
  }

  /// Open app settings for user to manually enable notifications.
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
