import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../application/auth_controller.dart';

/// S05 Forgot Password Screen & S05b Reset Link Sent Screen
///
/// Implements:
/// - "Reset password" top bar
/// - Username entry with masked email hint
/// - Security rule: never reveals whether an unknown username exists
/// - S05b: "Check your inbox. Link expires in 30 minutes." green banner
/// - Resend countdown button: "Resend in 42s" counting down until enabled
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _usernameCtrl = TextEditingController();
  bool _isSent = false;
  bool _isLoading = false;
  String? _maskedEmail;

  Timer? _countdownTimer;
  int _countdownSeconds = 60;

  @override
  void initState() {
    super.initState();
    _usernameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _usernameCtrl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdownSeconds = 60);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleSendResetLink() async {
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final masked = await ref
          .read(authControllerProvider.notifier)
          .sendPasswordReset(username);

      if (!mounted) return;
      setState(() {
        _isSent = true;
        _isLoading = false;
        _maskedEmail = masked ?? 'r***@gmail.com';
      });
      _startCountdown();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSent = true;
        _isLoading = false;
        _maskedEmail = 'r***@gmail.com';
      });
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSend = _usernameCtrl.text.trim().isNotEmpty && !_isLoading;

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
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
                    tooltip: 'Back',
                  ),
                  Text(
                    'Reset password',
                    style: AppTextStyles.titleLarge(color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingWide),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimensions.space16),

                    if (!_isSent) ...[
                      // S05: Initial input state
                      Text(
                        'Enter your username',
                        style: AppTextStyles.headlineSmall(color: AppColors.textLight).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space8),
                      Text(
                        'We will email a reset link to the address linked with your Google account.',
                        style: AppTextStyles.bodyMedium(color: AppColors.textSecondaryLight).copyWith(
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space24),

                      // Username field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: AppColors.outlineLight, width: 1.2),
                        ),
                        child: TextField(
                          controller: _usernameCtrl,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleSendResetLink(),
                          style: AppTextStyles.bodyLarge(color: AppColors.textLight),
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: AppTextStyles.bodyMedium(color: AppColors.textMutedLight),
                            prefixIcon: const Icon(
                              Icons.alternate_email_rounded,
                              color: AppColors.textSecondaryLight,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),

                      // Send reset link button
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: FilledButton(
                          onPressed: canSend ? _handleSendResetLink : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.outlineLight.withValues(alpha: 0.5),
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Send reset link',
                                  style: AppTextStyles.buttonLarge(
                                    color: canSend ? Colors.white : AppColors.textMutedLight,
                                  ),
                                ),
                        ),
                      ),
                    ] else ...[
                      // S05b: Reset link sent state
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space16,
                          vertical: AppDimensions.space16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successContainer,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                        ),
                        child: Text(
                          'Check your inbox. Link expires in 30 minutes.',
                          style: AppTextStyles.bodyMedium(color: AppColors.success).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space12),

                      if (_maskedEmail != null) ...[
                        Text(
                          'Link sent to $_maskedEmail',
                          style: AppTextStyles.bodySmall(color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: AppDimensions.space16),
                      ],

                      // Resend countdown button
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: FilledButton(
                          onPressed: _countdownSeconds == 0 && !_isLoading
                              ? _handleSendResetLink
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: const Color(0xFFC4D0D2),
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _countdownSeconds > 0
                                      ? 'Resend in ${_countdownSeconds}s'
                                      : 'Resend link',
                                  style: AppTextStyles.buttonLarge(
                                    color: _countdownSeconds == 0
                                        ? Colors.white
                                        : AppColors.textLight.withValues(alpha: 0.7),
                                  ),
                                ),
                        ),
                      ),
                    ],
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
