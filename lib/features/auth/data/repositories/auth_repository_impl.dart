import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

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
    await _remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    await _remoteDataSource.signUpWithEmail(email, password);
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    final model = await _remoteDataSource.signInWithEmail(email, password);
    return model.toEntity();
  }

  @override
  Future<UserEntity> verifyOtp(String email, String token) async {
    final model = await _remoteDataSource.verifyOtp(email, token);
    return model.toEntity();
  }

  @override
  Future<void> resendConfirmationEmail(String email) async {
    await _remoteDataSource.resendConfirmationEmail(email);
  }
}
