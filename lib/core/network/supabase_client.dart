import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client wrapper and utilities
class SupabaseService {
  SupabaseService._();

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get SUPABASE_URL from environment
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Get SUPABASE_ANON_KEY from environment
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Get GOOGLE_WEB_CLIENT_ID from environment
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  /// Get GOOGLE_IOS_CLIENT_ID from environment
  static String get googleIosClientId =>
      dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';

  /// Listen to auth state changes
  static Stream<AuthState> get onAuthStateChange =>
      client.auth.onAuthStateChange;
}
