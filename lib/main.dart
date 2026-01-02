import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/injection/injection_container.dart' as di;
import 'core/services/session_service.dart';
import 'core/services/notification_navigation_service.dart';
import 'app.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/utils/app_bloc_observer.dart';

// Global instances for notification handling
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Android Notification Channel for FCM (Required for Android 8+)
const AndroidNotificationChannel todoRemindersChannel = AndroidNotificationChannel(
  'todo_reminders', // Must match channel_id from Edge Function
  'Todo Reminders',
  description: 'Notifications for scheduled todo reminders',
  importance: Importance.high,
  playSound: true,
);

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.notification?.title}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp();
  
  // =========================================
  // NOTIFICATION SETUP (Complete)
  // =========================================
  
  // 1. Create the notification channel (Required for Android 8+)
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(todoRemindersChannel);
  
  // 2. Initialize FlutterLocalNotificationsPlugin with navigation handler
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);
  
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint('Notification tapped: ${response.payload}');
      // Navigate to todo/schedule when notification is tapped
      NotificationNavigationService.navigateToTodo(response.payload);
    },
  );
  
  // 3. Handle FOREGROUND messages - display notification banner
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Foreground message received: ${message.notification?.title}');
    
    final notification = message.notification;
    final android = message.notification?.android;
    
    // Show notification banner when app is in foreground
    if (notification != null && android != null) {
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
        payload: message.data['todo_id'],
      );
    }
  });
  
  // 4. Handle notification tap when app is in BACKGROUND
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('Notification opened app from background: ${message.notification?.title}');
    NotificationNavigationService.navigateToTodo(message.data['todo_id']);
  });
  
  // 5. Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // 6. Handle notification tap when app was TERMINATED
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    debugPrint('App launched from notification: ${initialMessage.notification?.title}');
    NotificationNavigationService.pendingTodoId = initialMessage.data['todo_id'];
  }
  
  // 7. Set foreground notification presentation options (iOS)
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Initialize Supabase with explicit auto-refresh
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
    ),
  );

  // Initialize dependency injection
  await di.init();

  // Initialize session management service
  di.sl<SessionService>().initialize();

  // Initialize Logging
  Bloc.observer = AppBlocObserver();

  runApp(const RippleApp());
}

// Global Supabase client accessor
final supabase = Supabase.instance.client;
