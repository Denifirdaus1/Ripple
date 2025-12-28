import 'package:equatable/equatable.dart';

/// Auth events for the AuthBloc
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check current authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event to trigger Google Sign-In
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

/// Event to trigger sign out
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Event when auth state changes externally
class AuthStateChanged extends AuthEvent {
  final bool isAuthenticated;

  const AuthStateChanged(this.isAuthenticated);

  @override
  List<Object?> get props => [isAuthenticated];
}
