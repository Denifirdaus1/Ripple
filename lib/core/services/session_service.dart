import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

/// Service for managing Supabase session lifecycle.
/// 
/// Monitors auth state changes, handles token refresh events,
/// and provides session validation utilities.
class SessionService {
  final SupabaseClient _client;
  StreamSubscription<AuthState>? _authSubscription;

  SessionService(this._client);

  /// Initialize session monitoring.
  /// 
  /// Call this after Supabase.initialize() in main.dart.
  void initialize() {
    _authSubscription = _client.auth.onAuthStateChange.listen(
      (data) {
        final event = data.event;
        final session = data.session;

        switch (event) {
          case AuthChangeEvent.initialSession:
            if (session != null) {
              AppLogger.i('Session: Initial session restored');
            } else {
              AppLogger.i('Session: No initial session');
            }
            break;
          case AuthChangeEvent.signedIn:
            AppLogger.i('Session: User signed in');
            break;
          case AuthChangeEvent.signedOut:
            AppLogger.i('Session: User signed out');
            break;
          case AuthChangeEvent.tokenRefreshed:
            AppLogger.i('Session: Token refreshed successfully');
            break;
          case AuthChangeEvent.userUpdated:
            AppLogger.i('Session: User data updated');
            break;
          case AuthChangeEvent.passwordRecovery:
            AppLogger.i('Session: Password recovery initiated');
            break;
          case AuthChangeEvent.mfaChallengeVerified:
            AppLogger.i('Session: MFA challenge verified');
            break;
          default:
            // Handle any unhandled or deprecated events
            break;
        }
      },
      onError: (error) {
        AppLogger.e('Session: Auth stream error', error);
      },
    );
    
    if (kDebugMode) {
      AppLogger.i('SessionService initialized');
    }
  }

  /// Check if current session is valid (not expired).
  bool get hasValidSession {
    final session = _client.auth.currentSession;
    if (session == null) return false;
    return !session.isExpired;
  }

  /// Get the current session if available.
  Session? get currentSession => _client.auth.currentSession;

  /// Get the current user if authenticated.
  User? get currentUser => _client.auth.currentUser;

  /// Attempt to refresh the session manually.
  /// 
  /// Returns true if refresh was successful, false otherwise.
  /// This is typically called when you detect a token-related error.
  Future<bool> tryRefreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      if (response.session != null) {
        AppLogger.i('Session: Manual refresh successful');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.e('Session: Manual refresh failed', e);
      return false;
    }
  }

  /// Check session validity and refresh if needed.
  /// 
  /// Returns true if session is valid (either was valid or successfully refreshed).
  Future<bool> ensureValidSession() async {
    if (hasValidSession) return true;
    
    // Session expired, try to refresh
    return await tryRefreshSession();
  }

  /// Dispose the session service.
  void dispose() {
    _authSubscription?.cancel();
    _authSubscription = null;
  }
}
