import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationRepository _repository;

  NotificationService(this._repository);

  Future<void> initialize(String userId) async {
    // 1. Request Permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }

      // 2. Get Token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        if (kDebugMode) {
          print('FCM Token: $token');
        }
        // 3. Sync to DB
        await _repository.saveDeviceToken(token, userId);
      }

      // 4. Listen for Token Refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _repository.saveDeviceToken(newToken, userId);
      });

      // 5. Handle Foreground Messages (Optional for now)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');
        }
         
        if (message.notification != null) {
          if (kDebugMode) {
            print('Message also contained a notification: ${message.notification}');
          }
        }
      });
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }
  }
}
