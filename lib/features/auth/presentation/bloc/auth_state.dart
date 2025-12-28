import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

/// Auth states for the AuthBloc
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking if user is authenticated
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state - authentication in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state - user is signed in
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state - user is not signed in
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Error state - authentication failed
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
