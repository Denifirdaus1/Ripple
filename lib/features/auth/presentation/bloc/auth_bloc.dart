import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/notification_service.dart';

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
    AppLogger.d('Auth subscription requested');
    await _authSubscription?.cancel();
    _authSubscription = _getAuthStream().listen(
      (user) => add(AuthUserChanged(user)),
      onError: (error, stackTrace) {
        AppLogger.e('Auth stream error', error, stackTrace);
        add(AuthLogoutRequested());
      },
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user.isEmpty) {
      AppLogger.d('Auth state: Unauthenticated');
      emit(const Unauthenticated());
    } else {
      AppLogger.i('Auth state: Authenticated (User: ${event.user.id})');
      emit(Authenticated(event.user));
    }
  }

  void _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    AppLogger.d('Logout requested');
    
    // Reset notification service for next user
    GetIt.I<NotificationService>().reset();
    
    unawaited(_signOut());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
