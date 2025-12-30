import '../repositories/auth_repository.dart';

/// Use case for signing up with email and password
class SignUpWithEmail {
  final AuthRepository _repository;

  SignUpWithEmail(this._repository);

  Future<void> call(String email, String password) {
    return _repository.signUpWithEmail(email, password);
  }
}
