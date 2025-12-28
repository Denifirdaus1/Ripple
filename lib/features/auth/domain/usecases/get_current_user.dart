import 'package:ripple/core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting the current authenticated user
class GetCurrentUser implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<UserEntity?> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
