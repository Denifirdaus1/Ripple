import 'package:ripple/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing out
class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.signOut();
  }
}
