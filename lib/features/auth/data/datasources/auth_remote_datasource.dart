import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Abstract class defining remote data source operations
abstract class AuthRemoteDataSource {
  /// Sign in with Google and return UserModel
  Future<UserModel> signInWithGoogle();

  /// Sign out the current user
  Future<void> signOut();

  /// Get the currently authenticated user
  Future<UserModel?> getCurrentUser();

  /// Stream of auth state changes
  Stream<UserModel?> get authStateChanges;
}

/// Implementation of AuthRemoteDataSource using Supabase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;
  bool _isGoogleSignInInitialized = false;

  AuthRemoteDataSourceImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// Initialize GoogleSignIn with configuration
  Future<void> _ensureGoogleSignInInitialized() async {
    if (_isGoogleSignInInitialized) return;

    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
    final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'];

    // Initialize GoogleSignIn with the singleton instance (google_sign_in 7.x)
    await GoogleSignIn.instance.initialize(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    _isGoogleSignInInitialized = true;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();

      final googleSignIn = GoogleSignIn.instance;

      // Check if authenticate is supported on this platform
      if (!googleSignIn.supportsAuthenticate()) {
        // For web, you would typically use renderButton()
        if (kIsWeb) {
          throw const AppAuthException(
            'Web sign-in requires using Google Sign-In button widget. '
            'Please use the GoogleSignInButton widget from google_sign_in/widgets.dart',
          );
        }
        throw const AppAuthException(
          'Google Sign-In authentication is not supported on this platform',
        );
      }

      // Trigger the Google Sign-In flow
      // Returns GoogleSignInAccount with authentication tokens
      final GoogleSignInAccount account = await googleSignIn.authenticate();

      // Get authentication tokens from the account
      // In google_sign_in 7.x, GoogleSignInAuthentication only has idToken
      final GoogleSignInAuthentication auth = account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        throw const AppAuthException(
          'No ID token received from Google. Please ensure serverClientId is configured.',
        );
      }

      // For Supabase signInWithIdToken, we need both idToken and accessToken
      // In google_sign_in 7.x, accessToken is obtained through authorization
      // We'll use the authorization client to get an access token if needed
      String? accessToken;
      
      // Try to get access token through authorization
      final authClient = account.authorizationClient;
      final authResult = await authClient.authorizationForScopes(
        ['email', 'profile'],
      );
      accessToken = authResult?.accessToken;

      // Sign in to Supabase with the Google ID token
      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw const AppAuthException('Failed to sign in with Supabase');
      }

      return UserModel.fromSupabaseUser(response.user!.toJson());
    } on AppAuthException {
      rethrow;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AppAuthException('Google sign-in was cancelled');
      }
      throw AppAuthException('Google sign-in failed: ${e.description}');
    } catch (e) {
      throw AppAuthException('Google sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureGoogleSignInInitialized();

      // Sign out from Google
      await GoogleSignIn.instance.signOut();

      // Sign out from Supabase
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw AppAuthException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;

      if (user == null) {
        return null;
      }

      return UserModel.fromSupabaseUser(user.toJson());
    } catch (e) {
      throw AppAuthException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.map((authState) {
      final user = authState.session?.user;

      if (user == null) {
        return null;
      }

      return UserModel.fromSupabaseUser(user.toJson());
    });
  }
}
