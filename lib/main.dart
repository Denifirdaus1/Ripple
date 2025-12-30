import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/injection/injection_container.dart' as di;
import 'app.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/utils/app_bloc_observer.dart';

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize dependency injection
  await di.init();

  // Initialize Logging
  Bloc.observer = AppBlocObserver();

  runApp(const RippleApp());
}

// Global Supabase client accessor
final supabase = Supabase.instance.client;

