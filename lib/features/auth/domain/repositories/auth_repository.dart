import '../entities/user_entity.dart';

/// Auth repository interface (contract)
/// This defines what the auth repository should do without implementation details
abstract class AuthRepository {
  /// Sign in with Google OAuth via Supabase
  Future<UserEntity> signInWithGoogle();

  /// Sign out the current user
  Future<void> signOut();

  /// Get the currently authenticated user
  Future<UserEntity?> getCurrentUser();

  /// Stream of auth state changes
  Stream<UserEntity?> get authStateChanges;
}
