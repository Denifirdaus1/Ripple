import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for verifying email OTP
class VerifyEmailOtp {
  final AuthRepository _repository;

  VerifyEmailOtp(this._repository);

  Future<UserEntity> call(String email, String token) {
    return _repository.verifyOtp(email, token);
  }
}
