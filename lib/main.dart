import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/injection/injection_container.dart' as di;
import 'core/services/session_service.dart';
import 'core/services/notification_navigation_service.dart';
import 'core/services/timezone_service.dart';
import 'core/utils/notification_logger.dart';
import 'app.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/utils/app_bloc_observer.dart';

// Global instances for notification handling
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Android Notification Channel for FCM (Required for Android 8+)
const AndroidNotificationChannel todoRemindersChannel = AndroidNotificationChannel(
  'todo_reminders',
  'Todo Reminders',
  description: 'Notifications for scheduled todo reminders',
  importance: Importance.high,
  playSound: true,
);

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  NotificationLogger.fcmBackground(
    message.notification?.title,
    message.data,
  );
}

/// Handle notification response (tap) from flutter_local_notifications
@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(NotificationResponse response) {
  NotificationLogger.localNotificationTapped(
    response.id,
    response.payload,
    response.actionId,
  );
  
  // Navigate to todo detail page
  if (response.payload != null && response.payload!.isNotEmpty) {
    NotificationNavigationService.navigateToTodo(response.payload);
  } else {
    NotificationNavigationService.navigateToTodo(null);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  NotificationLogger.init('App starting...');

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  NotificationLogger.init('Firebase initialized');
  
  // 1. Create notification channel
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(todoRemindersChannel);
  NotificationLogger.init('Android notification channel created');
  
  // 2. Initialize FlutterLocalNotificationsPlugin
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);
  
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse: onDidReceiveNotificationResponse,
  );
  NotificationLogger.init('FlutterLocalNotificationsPlugin initialized');
  
  // 3. Check if app was launched from local notification tap
  final NotificationAppLaunchDetails? launchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  
  NotificationLogger.init('didNotificationLaunchApp: ${launchDetails?.didNotificationLaunchApp}');
  
  if (launchDetails?.didNotificationLaunchApp ?? false) {
    final payload = launchDetails!.notificationResponse?.payload;
    NotificationLogger.appLaunchedFromNotification(payload);
    NotificationNavigationService.pendingTodoId = payload;
  }
  
  // 4. Handle FOREGROUND messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    NotificationLogger.fcmForeground(
      message.notification?.title ?? 'No title',
      message.notification?.body,
      message.data,
    );
    
    final notification = message.notification;
    final android = message.notification?.android;
    
    if (notification != null && android != null) {
      final todoId = message.data['todo_id'] as String?;
      
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            todoRemindersChannel.id,
            todoRemindersChannel.name,
            channelDescription: todoRemindersChannel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: todoId,
      );
      NotificationLogger.localNotificationShown(notification.title, todoId);
    }
  });
  
  // 5. Handle notification tap when app is in BACKGROUND
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    NotificationLogger.fcmOpenedApp(
      message.notification?.title,
      message.data,
    );
    NotificationNavigationService.navigateToTodo(message.data['todo_id']);
  });
  
  // 6. Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // 7. Handle notification tap when app was TERMINATED (FCM)
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    NotificationLogger.fcmInitialMessage(
      initialMessage.notification?.title,
      initialMessage.data,
    );
    if (NotificationNavigationService.pendingTodoId == null) {
      NotificationNavigationService.pendingTodoId = initialMessage.data['todo_id'];
    }
  }
  
  // 8. iOS foreground presentation options
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
    ),
  );
  NotificationLogger.init('Supabase initialized');

  await di.init();
  di.sl<SessionService>().initialize();
  
  // Initialize Timezone (detect device timezone)
  await di.sl<TimezoneService>().initialize();
  NotificationLogger.init('Timezone initialized: ${di.sl<TimezoneService>().timezoneName}');
  
  Bloc.observer = AppBlocObserver();

  NotificationLogger.init('Running app...');
  runApp(const RippleApp());
}

final supabase = Supabase.instance.client;
