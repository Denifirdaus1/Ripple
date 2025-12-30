import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password
class SignInWithEmail {
  final AuthRepository _repository;

  SignInWithEmail(this._repository);

  Future<UserEntity> call(String email, String password) {
    return _repository.signInWithEmail(email, password);
  }
}
