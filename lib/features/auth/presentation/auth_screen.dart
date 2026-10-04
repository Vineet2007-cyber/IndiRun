import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/indirun_logo.dart';
import '../application/auth_controller.dart';

/// S02 Login Screen
///
/// Implements:
/// - Brand header: "Welcome to" + "INDIRUN" in Peacock Teal
/// - Lowercase-friendly Username field with `@` prefix
/// - Password field with visibility toggle
/// - Forgot password link
/// - Login button (disabled until valid, lockout countdown on repeated fails)
/// - Error & offline states
/// - Google Login button
/// - Navigation to Sign up
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _usernameCtrl.addListener(_onFieldChanged);
    _passwordCtrl.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _usernameCtrl.removeListener(_onFieldChanged);
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _isValidInput =>
      _usernameCtrl.text.trim().isNotEmpty && _passwordCtrl.text.isNotEmpty;

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final authState = ref.read(authControllerProvider);
      if (!authState.isLockedOut) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() {});
      }
    });
  }

  Future<void> _handleLogin() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) return;

    FocusScope.of(context).unfocus();
    await ref.read(authControllerProvider.notifier).signIn(username, password);

    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.isLockedOut) {
      _startLockoutTimer();
    } else if (state.isAuthenticated) {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _handleGoogleLogin() async {
    FocusScope.of(context).unfocus();
    await ref.read(authControllerProvider.notifier).signInWithGoogle();

    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.isAuthenticated) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLockedOut = authState.isLockedOut;
    final isLoading = authState.isLoading;
    final isButtonEnabled = _isValidInput && !isLoading && !isLockedOut;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingWide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimensions.space48),
              // Header
              Text(
                'Welcome to',
                style: AppTextStyles.bodyLarge(color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: AppDimensions.space4),
              Text(
                'INDIRUN',
                style: AppTextStyles.headlineLarge(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: AppDimensions.space40),

              // Lockout Banner
              if (isLockedOut) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  margin: const EdgeInsets.only(bottom: AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_clock_outlined, color: AppColors.error, size: 20),
                      const SizedBox(width: AppDimensions.space8),
                      Expanded(
                        child: Text(
                          'Too many failed attempts. Locked out for ${authState.remainingLockoutSeconds}s.',
                          style: AppTextStyles.caption(color: AppColors.error).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (authState.errorMessage != null) ...[
                // Error Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  margin: const EdgeInsets.only(bottom: AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: AppDimensions.space8),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: AppTextStyles.bodySmall(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Username input
              _AuthInputField(
                controller: _usernameCtrl,
                hintText: 'Username',
                prefixIcon: Icons.alternate_email_rounded,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                enabled: !isLockedOut && !isLoading,
              ),
              const SizedBox(height: AppDimensions.space12),

              // Password input
              _AuthInputField(
                controller: _passwordCtrl,
                hintText: 'Password',
                prefixIcon: Icons.square_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                enabled: !isLockedOut && !isLoading,
                onSubmitted: (_) => _handleLogin(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondaryLight,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),

              // Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.space8),
                  ),
                  child: Text(
                    'Forgot password?',
                    style: AppTextStyles.bodyMedium(color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space8),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: FilledButton(
                  onPressed: isButtonEnabled ? _handleLogin : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.outlineLight.withValues(alpha: 0.5),
                    disabledForegroundColor: AppColors.textMutedLight,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isLockedOut
                              ? 'Locked (${authState.remainingLockoutSeconds}s)'
                              : 'Login',
                          style: AppTextStyles.buttonLarge(
                            color: isButtonEnabled ? Colors.white : AppColors.textMutedLight,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // "or" Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.outlineLight)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space12),
                    child: Text(
                      'or',
                      style: AppTextStyles.caption(color: AppColors.textSecondaryLight),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.outlineLight)),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Login with Google Button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed: isLoading ? null : _handleGoogleLogin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.outlineLight, width: 1.2),
                    shape: const StadiumBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _GoogleBrandIcon(),
                      const SizedBox(width: AppDimensions.space10),
                      Text(
                        'Login with Google',
                        style: AppTextStyles.labelLarge(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space64),

              // Footer: New user? Sign up with Google
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New user? ',
                    style: AppTextStyles.bodyMedium(color: AppColors.textSecondaryLight),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.signup),
                    child: Text(
                      'Sign up with Google',
                      style: AppTextStyles.bodyMedium(color: AppColors.primary).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }
}

/// S03 Sign Up Screen
///
/// Implements:
/// - Header back button & "Sign up" title
/// - "Create your account" + "Sign up with Google to get started"
/// - Approved IndiRun logo
/// - "Continue with Google" outlined button (identity verification only)
/// - Privacy callout: "Google is only used to verify you. Your Google name is never shown."
/// - Terms footnote
/// - "Already registered? Login" footer
class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  Future<void> _handleGoogleSignUp(BuildContext context, WidgetRef ref) async {
    // 1. Google OAuth verifies identity only
    await ref.read(authControllerProvider.notifier).signInWithGoogle();

    // 2. Product rule: User must explicitly choose their own username next
    if (context.mounted) {
      context.go(AppRoutes.username);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.only(
                left: AppDimensions.space8,
                top: AppDimensions.space8,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.login),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
                    tooltip: 'Back to Login',
                  ),
                  Text(
                    'Sign up',
                    style: AppTextStyles.titleLarge(color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingWide),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppDimensions.space24),
                    Text(
                      'Create your account',
                      style: AppTextStyles.headlineLarge(color: AppColors.textLight).copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.space8),
                    Text(
                      'Sign up with Google to get started',
                      style: AppTextStyles.bodyMedium(color: AppColors.textSecondaryLight),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.space32),

                    // Approved IndiRun Logo
                    const IndiRunLogo(size: 72),
                    const SizedBox(height: AppDimensions.space32),

                    // Continue with Google Button
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () => _handleGoogleSignUp(context, ref),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.outlineLight, width: 1.2),
                          shape: const StadiumBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const _GoogleBrandIcon(),
                            const SizedBox(width: AppDimensions.space10),
                            Text(
                              'Continue with Google',
                              style: AppTextStyles.labelLarge(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // Privacy Note Callout Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.space16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.space12),
                          Expanded(
                            child: Text(
                              'Google is only used to verify you. Your Google name is never shown.',
                              style: AppTextStyles.bodySmall(color: AppColors.textLight).copyWith(
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // Terms Footnote
                    Text(
                      'By continuing you agree to Terms and Privacy Policy',
                      style: AppTextStyles.caption(color: AppColors.textSecondaryLight),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.space72),

                    // Footer: Already registered? Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already registered? ',
                          style: AppTextStyles.bodyMedium(color: AppColors.textSecondaryLight),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.login),
                          child: Text(
                            'Login',
                            style: AppTextStyles.bodyMedium(color: AppColors.primary).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared Auth Presentation Widgets
// ---------------------------------------------------------------------------

class _AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  const _AuthInputField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.autocorrect = false,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      autocorrect: autocorrect,
      textCapitalization: textCapitalization,
      onSubmitted: onSubmitted,
      style: AppTextStyles.bodyLarge(color: AppColors.textLight),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium(color: AppColors.textMutedLight),
        prefixIcon: Icon(prefixIcon, color: AppColors.textSecondaryLight, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.outlineLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.outlineLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.outlineLight.withValues(alpha: 0.4)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
    );
  }
}

class _GoogleBrandIcon extends StatelessWidget {
  const _GoogleBrandIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outlineLight, width: 1.0),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
