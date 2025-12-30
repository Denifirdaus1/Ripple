import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

// --- Events ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthSubscriptionRequested extends AuthEvent {}
class AuthLogoutRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final UserEntity user;
  const AuthUserChanged(this.user);
  @override
  List<Object> get props => [user];
}

// --- States ---
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);
  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthStream _getAuthStream;
  final SignOut _signOut;
  StreamSubscription<UserEntity>? _authSubscription;

  AuthBloc({
    required GetAuthStream getAuthStream,
    required SignOut signOut,
  })  : _getAuthStream = getAuthStream,
        _signOut = signOut,
        super(const AuthUnknown()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserChanged>(_onUserChanged);
  }

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authSubscription?.cancel();
    _authSubscription = _getAuthStream().listen(
      (user) => add(AuthUserChanged(user)),
      onError: (error) => add(AuthLogoutRequested()), // Simplistic error handling
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user.isEmpty) {
      emit(const Unauthenticated());
    } else {
      emit(Authenticated(event.user));
    }
  }

  void _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    unawaited(_signOut());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
