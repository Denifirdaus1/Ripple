// Export all auth use cases
export 'sign_up_with_email.dart';
export 'sign_in_with_email.dart';
export 'verify_email_otp.dart';
export 'resend_confirmation_email.dart';

import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class GetAuthStream {
  final AuthRepository repository;

  GetAuthStream(this.repository);

  Stream<UserEntity> call() {
    return repository.user;
  }
}

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<void> call() {
    return repository.signInWithGoogle();
  }
}

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}
