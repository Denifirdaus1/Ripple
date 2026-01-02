import 'package:flutter/foundation.dart';

/// Dedicated logger for notification system
/// Tag: RIPPLE_NOTIF - easy to filter in logcat
/// 
/// Filter in terminal:
///   adb logcat | findstr "RIPPLE_NOTIF"
///   adb logcat "*:S" "RIPPLE_NOTIF:V"
class NotificationLogger {
  static const String _tag = 'RIPPLE_NOTIF';
  
  /// Log FCM foreground message received
  static void fcmForeground(String title, String? body, Map<String, dynamic> data) {
    _log('FCM_FG', '📥 Foreground message: "$title"');
    _log('FCM_FG', '   Body: $body');
    _log('FCM_FG', '   Data: $data');
    _log('FCM_FG', '   todo_id: ${data['todo_id']}');
  }
  
  /// Log FCM background message received  
  static void fcmBackground(String? title, Map<String, dynamic> data) {
    _log('FCM_BG', '📥 Background message: "$title"');
    _log('FCM_BG', '   Data: $data');
  }
  
  /// Log when app opened from background notification (FCM)
  static void fcmOpenedApp(String? title, Map<String, dynamic> data) {
    _log('FCM_OPEN', '📲 App opened from background!');
    _log('FCM_OPEN', '   Title: $title');
    _log('FCM_OPEN', '   todo_id: ${data['todo_id']}');
  }
  
  /// Log when app launched from terminated state (FCM)
  static void fcmInitialMessage(String? title, Map<String, dynamic> data) {
    _log('FCM_INIT', '🚀 App launched from FCM notification!');
    _log('FCM_INIT', '   Title: $title');
    _log('FCM_INIT', '   todo_id: ${data['todo_id']}');
  }
  
  /// Log local notification displayed
  static void localNotificationShown(String? title, String? payload) {
    _log('LOCAL', '🔔 Local notification displayed');
    _log('LOCAL', '   Title: $title');
    _log('LOCAL', '   Payload: $payload');
  }
  
  /// Log local notification tapped
  static void localNotificationTapped(int? id, String? payload, String? actionId) {
    _log('TAP', '================================');
    _log('TAP', '👆 NOTIFICATION TAPPED!');
    _log('TAP', '   ID: $id');
    _log('TAP', '   Payload (todo_id): $payload');
    _log('TAP', '   Action ID: $actionId');
    _log('TAP', '================================');
  }
  
  /// Log app launch from local notification
  static void appLaunchedFromNotification(String? payload) {
    _log('LAUNCH', '🚀 App launched from local notification!');
    _log('LAUNCH', '   Payload: $payload');
  }
  
  /// Log navigation attempt
  static void navigationAttempt(String? todoId, bool hasContext) {
    _log('NAV', '🧭 Navigation attempt');
    _log('NAV', '   todoId: $todoId');
    _log('NAV', '   hasContext: $hasContext');
  }
  
  /// Log navigation success
  static void navigationSuccess(String route) {
    _log('NAV', '✅ Navigation SUCCESS to: $route');
  }
  
  /// Log navigation pending (app not ready)
  static void navigationPending(String? todoId) {
    _log('NAV', '⏳ Navigation pending (app not ready)');
    _log('NAV', '   Saved pendingTodoId: $todoId');
  }
  
  /// Log navigation error
  static void navigationError(String error) {
    _log('NAV', '❌ Navigation ERROR: $error');
  }
  
  /// Log pending navigation processing
  static void processingPendingNavigation(String? pendingTodoId) {
    _log('NAV', '🔄 Processing pending navigation');
    _log('NAV', '   pendingTodoId: $pendingTodoId');
  }
  
  /// Log initialization step
  static void init(String step) {
    _log('INIT', '⚙️ $step');
  }
  
  /// Core logging method - uses print() for direct logcat output
  static void _log(String subTag, String message) {
    // Format: [RIPPLE_NOTIF][SubTag] Message
    // This will appear in logcat under "flutter" tag
    final output = '[$_tag][$subTag] $message';
    
    // print() goes directly to logcat in Flutter
    // ignore: avoid_print
    print(output);
    
    // Also use debugPrint for flutter run console (truncates long lines better)
    debugPrint(output);
  }
}
