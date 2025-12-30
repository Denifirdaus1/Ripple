import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity> get user;
  Future<void> signInWithGoogle();
  Future<void> signOut();
  UserEntity get currentUser;

  // Email authentication
  Future<void> signUpWithEmail(String email, String password);
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> verifyOtp(String email, String token);
  Future<void> resendConfirmationEmail(String email);
}
