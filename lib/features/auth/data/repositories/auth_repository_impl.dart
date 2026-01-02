import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/utils/logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Stream<UserEntity> get user {
    return _remoteDataSource.authStateChanges.map((model) {
      if (model == null) return UserEntity.empty;
      return model.toEntity();
    });
  }

  @override
  UserEntity get currentUser {
    final model = _remoteDataSource.currentUserSync;
    if (model == null) return UserEntity.empty;
    return model.toEntity();
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      AppLogger.d('Signing in with Google...');
      await _remoteDataSource.signInWithGoogle();
      AppLogger.i('Google sign-in successful');
    } catch (e, s) {
      AppLogger.e('Google sign-in failed', e, s);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      AppLogger.d('Signing out...');
      await _remoteDataSource.signOut();
      AppLogger.i('Signed out successfully');
    } catch (e, s) {
      AppLogger.e('Sign-out failed', e, s);
      rethrow;
    }
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      AppLogger.d('Signing up with email: $email');
      await _remoteDataSource.signUpWithEmail(email, password);
      AppLogger.i('Sign-up successful for $email');
    } catch (e, s) {
      AppLogger.e('Sign-up failed for $email', e, s);
      rethrow;
    }
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    try {
      AppLogger.d('Signing in with email: $email');
      final model = await _remoteDataSource.signInWithEmail(email, password);
      AppLogger.i('Email sign-in successful for $email');
      return model.toEntity();
    } catch (e, s) {
      AppLogger.e('Email sign-in failed for $email', e, s);
      rethrow;
    }
  }

  @override
  Future<UserEntity> verifyOtp(String email, String token) async {
    try {
      AppLogger.d('Verifying OTP for $email');
      final model = await _remoteDataSource.verifyOtp(email, token);
      AppLogger.i('OTP verified for $email');
      return model.toEntity();
    } catch (e, s) {
      AppLogger.e('OTP verification failed for $email', e, s);
      rethrow;
    }
  }

  @override
  Future<void> resendConfirmationEmail(String email) async {
    try {
      AppLogger.d('Resending confirmation email to $email');
      await _remoteDataSource.resendConfirmationEmail(email);
      AppLogger.i('Confirmation email sent to $email');
    } catch (e, s) {
      AppLogger.e('Failed to resend confirmation email to $email', e, s);
      rethrow;
    }
  }
}
