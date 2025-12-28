import 'package:equatable/equatable.dart';

/// Base Failure class for handling errors in domain/presentation layers
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure for server-side errors
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server failure occurred']);
}

/// Failure for authentication errors
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failure occurred']);
}

/// Failure for cache/local storage errors
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure occurred']);
}

/// Failure for network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network failure occurred']);
}

/// Failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}
