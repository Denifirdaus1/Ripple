import 'package:ripple/core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with Google
class SignInWithGoogle implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  @override
  Future<UserEntity> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}
