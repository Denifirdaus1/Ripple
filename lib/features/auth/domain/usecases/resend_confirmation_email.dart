import '../repositories/auth_repository.dart';

/// Use case for resending confirmation email
class ResendConfirmationEmail {
  final AuthRepository _repository;

  ResendConfirmationEmail(this._repository);

  Future<void> call(String email) {
    return _repository.resendConfirmationEmail(email);
  }
}
