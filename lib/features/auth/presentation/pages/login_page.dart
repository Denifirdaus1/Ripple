import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/injection/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ripple_button.dart';
import '../../../../core/widgets/ripple_input.dart';
import '../bloc/login_cubit.dart';
import 'otp_verification_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.coralRed,
            ),
          );
        }
        if (state.status == LoginStatus.awaitingVerification) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<LoginCubit>(),
                child: const OtpVerificationPage(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.paperWhite,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  // -- Brand Logo/Icon --
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.rippleBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIcons.waves(),
                      size: 52,
                      color: AppColors.rippleBlue,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // -- Title --
                  Text(
                    'Ripple',
                    style: AppTypography.textTheme.displayLarge?.copyWith(
                      fontSize: 40,
                      color: AppColors.rippleBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cozy Productivity',
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // -- Auth Mode Toggle --
                  _AuthModeToggle(currentMode: state.mode),
                  const SizedBox(height: 24),

                  // -- Email Form --
                  const _EmailAuthForm(),
                  const SizedBox(height: 24),

                  // -- Divider --
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'atau',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // -- Google Sign-In Button --
                  _GoogleSignInButton(isLoading: state.status == LoginStatus.submitting),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AuthModeToggle extends StatelessWidget {
  final AuthMode currentMode;

  const _AuthModeToggle({required this.currentMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Masuk',
              isActive: currentMode == AuthMode.signIn,
              onTap: () {
                if (currentMode != AuthMode.signIn) {
                  context.read<LoginCubit>().toggleMode();
                }
              },
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'Daftar',
              isActive: currentMode == AuthMode.signUp,
              onTap: () {
                if (currentMode != AuthMode.signUp) {
                  context.read<LoginCubit>().toggleMode();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.paperWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: isActive ? AppColors.rippleBlue : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailAuthForm extends StatefulWidget {
  const _EmailAuthForm();

  @override
  State<_EmailAuthForm> createState() => _EmailAuthFormState();
}

class _EmailAuthFormState extends State<_EmailAuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, AuthMode mode) {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (mode == AuthMode.signUp) {
      context.read<LoginCubit>().signUpWithEmail(email, password);
    } else {
      context.read<LoginCubit>().signInWithEmail(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final isSignUp = state.mode == AuthMode.signUp;
        final isSubmitting = state.status == LoginStatus.submitting;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Email
              RippleInput(
                controller: _emailController,
                label: 'Email',
                hint: 'nama@email.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: PhosphorIcons.envelope(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email wajib diisi';
                  }
                  if (!value.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password
              RippleInput(
                controller: _passwordController,
                label: 'Password',
                hint: '••••••••',
                obscureText: _obscurePassword,
                prefixIcon: PhosphorIcons.lock(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? PhosphorIcons.eye() : PhosphorIcons.eyeSlash(),
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password wajib diisi';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),

              // Confirm Password (only for Sign Up)
              if (isSignUp) ...[
                const SizedBox(height: 16),
                RippleInput(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Password',
                  hint: '••••••••',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: PhosphorIcons.lockKey(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? PhosphorIcons.eye() : PhosphorIcons.eyeSlash(),
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),

              // Submit Button
              RippleButton(
                text: isSignUp ? 'Daftar' : 'Masuk',
                isLoading: isSubmitting,
                onPressed: () => _submit(context, state.mode),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;

  const _GoogleSignInButton({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return RippleButton(
      text: 'Lanjutkan dengan Google',
      icon: PhosphorIcons.googleLogo(),
      variant: RippleButtonVariant.outlined,
      isLoading: isLoading,
      onPressed: () {
        context.read<LoginCubit>().signInWithGoogle();
      },
    );
  }
}
