import 'package:ripple/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with Google
class SignInWithGoogle implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}
