import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ripple_button.dart';
import '../bloc/login_cubit.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _resendTimer;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-submit when all 6 digits are entered
    if (_otpCode.length == 6) {
      _verifyOtp();
    }
  }

  void _verifyOtp() {
    if (_otpCode.length != 6) return;
    context.read<LoginCubit>().verifyOtp(_otpCode);
  }

  void _resendCode() {
    if (_resendCooldown > 0) return;
    context.read<LoginCubit>().resendConfirmation();
    _startResendCooldown();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          // Pop back and let AppRouter handle navigation
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        if (state.status == LoginStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.coralRed,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == LoginStatus.submitting;

        return Scaffold(
          backgroundColor: AppColors.paperWhite,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(PhosphorIcons.arrowLeft(), color: AppColors.inkDark),
              onPressed: () {
                context.read<LoginCubit>().resetState();
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    PhosphorIcons.envelopeSimple(),
                    size: 64,
                    color: AppColors.rippleBlue,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Verifikasi Email',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: AppColors.inkDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Masukkan kode 6 digit yang telah dikirim ke:',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.pendingEmail ?? '',
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 40,
                        height: 48,
                        margin: EdgeInsets.only(right: index < 5 ? 6 : 0),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: AppTypography.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.inkDark,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.outlineGray),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.outlineGray),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.rippleBlue,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) => _onOtpChanged(index, value),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Verify Button
                  RippleButton(
                    text: 'Verifikasi',
                    isLoading: isSubmitting,
                    onPressed: _verifyOtp,
                  ),
                  const SizedBox(height: 24),

                  // Resend Code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tidak menerima kode? ',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _resendCooldown > 0 ? null : _resendCode,
                        child: Text(
                          _resendCooldown > 0
                              ? 'Kirim ulang ($_resendCooldown s)'
                              : 'Kirim ulang',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: _resendCooldown > 0
                                ? AppColors.textSecondary
                                : AppColors.rippleBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
