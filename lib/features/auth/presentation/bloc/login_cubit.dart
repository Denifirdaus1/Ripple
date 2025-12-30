import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/auth_usecases.dart';

enum LoginStatus { initial, submitting, success, failure, awaitingVerification }
enum AuthMode { signIn, signUp }

class LoginState extends Equatable {
  final LoginStatus status;
  final AuthMode mode;
  final String? errorMessage;
  final String? pendingEmail; // Email awaiting OTP verification

  const LoginState({
    this.status = LoginStatus.initial,
    this.mode = AuthMode.signIn,
    this.errorMessage,
    this.pendingEmail,
  });

  LoginState copyWith({
    LoginStatus? status,
    AuthMode? mode,
    String? errorMessage,
    String? pendingEmail,
  }) {
    return LoginState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      errorMessage: errorMessage,
      pendingEmail: pendingEmail ?? this.pendingEmail,
    );
  }

  @override
  List<Object?> get props => [status, mode, errorMessage, pendingEmail];
}

class LoginCubit extends Cubit<LoginState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final VerifyEmailOtp _verifyEmailOtp;
  final ResendConfirmationEmail _resendConfirmationEmail;

  LoginCubit({
    required SignInWithGoogle signInWithGoogle,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required VerifyEmailOtp verifyEmailOtp,
    required ResendConfirmationEmail resendConfirmationEmail,
  })  : _signInWithGoogle = signInWithGoogle,
        _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _verifyEmailOtp = verifyEmailOtp,
        _resendConfirmationEmail = resendConfirmationEmail,
        super(const LoginState());

  void toggleMode() {
    emit(state.copyWith(
      mode: state.mode == AuthMode.signIn ? AuthMode.signUp : AuthMode.signIn,
      status: LoginStatus.initial,
    ));
  }

  void resetState() {
    emit(const LoginState());
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _signInWithGoogle();
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _signInWithEmail(email, password);
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      final message = e.toString();
      // Check if email not confirmed
      if (message.contains('Email not confirmed')) {
        emit(state.copyWith(
          status: LoginStatus.awaitingVerification,
          pendingEmail: email,
          errorMessage: 'Please verify your email first',
        ));
      } else {
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorMessage: message,
        ));
      }
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _signUpWithEmail(email, password);
      emit(state.copyWith(
        status: LoginStatus.awaitingVerification,
        pendingEmail: email,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> verifyOtp(String token) async {
    if (state.pendingEmail == null) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'No pending email for verification',
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _verifyEmailOtp(state.pendingEmail!, token);
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> resendConfirmation() async {
    if (state.pendingEmail == null) return;

    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      await _resendConfirmationEmail(state.pendingEmail!);
      emit(state.copyWith(status: LoginStatus.awaitingVerification));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
