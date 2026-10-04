import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../application/auth_controller.dart';
import '../domain/username_validator.dart';

/// S04 Choose Username Screen
///
/// Implements:
/// - Step indicator: "Step 2 of 2"
/// - Title: "Pick your runner name" + "This is how you appear in IndiRun."
/// - Debounced username availability validation (3–20 chars, a-z 0-9 _ ., no start/end dot, reserved check)
/// - Create password with 3-segment strength meter
/// - Confirm password with match validation
/// - Continue button enabled only when valid
/// - Transitions to Home / Permission on success
class ChooseUsernameScreen extends ConsumerStatefulWidget {
  const ChooseUsernameScreen({super.key});

  @override
  ConsumerState<ChooseUsernameScreen> createState() =>
      _ChooseUsernameScreenState();
}

class _ChooseUsernameScreenState extends ConsumerState<ChooseUsernameScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Timer? _debounceTimer;
  bool _isCheckingAvailability = false;
  bool _isUsernameAvailable = false;
  String? _usernameValidationError;

  int _passwordStrength = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl.addListener(_onUsernameChanged);
    _passwordCtrl.addListener(_onPasswordChanged);
    _confirmCtrl.addListener(_onConfirmChanged);
  }

  void _onUsernameChanged() {
    _debounceTimer?.cancel();
    final input = _usernameCtrl.text.trim();

    if (input.isEmpty) {
      setState(() {
        _isCheckingAvailability = false;
        _isUsernameAvailable = false;
        _usernameValidationError = null;
      });
      return;
    }

    final validationError = UsernameValidator.validate(input);
    if (validationError != null) {
      setState(() {
        _isCheckingAvailability = false;
        _isUsernameAvailable = false;
        _usernameValidationError = validationError;
      });
      return;
    }

    // Debounce availability check by 350ms
    setState(() {
      _isCheckingAvailability = true;
      _usernameValidationError = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      final available = await ref
          .read(authControllerProvider.notifier)
          .isUsernameAvailable(input);

      if (!mounted) return;
      setState(() {
        _isCheckingAvailability = false;
        _isUsernameAvailable = available;
        _usernameValidationError =
            available ? null : 'Username is already taken';
      });
    });
  }

  void _onPasswordChanged() {
    final password = _passwordCtrl.text;
    setState(() {
      _passwordStrength = UsernameValidator.calculatePasswordStrength(password);
    });
  }

  void _onConfirmChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _isPasswordValid =>
      _passwordCtrl.text.length >= 8 &&
      _passwordCtrl.text.contains(RegExp(r'[0-9]'));

  bool get _doPasswordsMatch =>
      _passwordCtrl.text.isNotEmpty &&
      _passwordCtrl.text == _confirmCtrl.text;

  bool get _isFormValid =>
      _isUsernameAvailable &&
      _isPasswordValid &&
      _doPasswordsMatch &&
      !_isLoading;

  Future<void> _handleContinue() async {
    if (!_isFormValid) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final username = _usernameCtrl.text.trim();
      final password = _passwordCtrl.text;

      await ref.read(authControllerProvider.notifier).completeSignUp(
            username: username,
            password: password,
          );

      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingWide),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.space32),
              // Step indicator
              Text(
                'Step 2 of 2',
                style: AppTextStyles.caption(color: AppColors.textSecondaryLight).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppDimensions.space8),
              // Title
              Text(
                'Pick your runner name',
                style: AppTextStyles.headlineLarge(color: AppColors.textLight).copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimensions.space6),
              // Subtitle
              Text(
                'This is how you appear in IndiRun.',
                style: AppTextStyles.bodyMedium(color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: AppDimensions.space28),

              // Username input
              _buildUsernameField(),
              const SizedBox(height: AppDimensions.space6),

              // Username status / helper text
              _buildUsernameHelper(),
              const SizedBox(height: AppDimensions.space20),

              // Create password input
              _buildPasswordField(
                controller: _passwordCtrl,
                hint: 'Create password',
                obscure: _obscurePassword,
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: AppDimensions.space10),

              // Password strength meter (3 segments)
              _buildPasswordStrengthBar(),
              const SizedBox(height: AppDimensions.space6),
              Text(
                UsernameValidator.passwordStrengthLabel(_passwordStrength),
                style: AppTextStyles.caption(color: _getStrengthColor()).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppDimensions.space20),

              // Confirm password input
              _buildPasswordField(
                controller: _confirmCtrl,
                hint: 'Confirm password',
                obscure: _obscureConfirm,
                onToggleVisibility: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
              ),
              if (_confirmCtrl.text.isNotEmpty && !_doPasswordsMatch) ...[
                const SizedBox(height: AppDimensions.space4),
                Text(
                  'Passwords do not match',
                  style: AppTextStyles.caption(color: AppColors.error),
                ),
              ],

              const SizedBox(height: AppDimensions.space64),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: FilledButton(
                  onPressed: _isFormValid ? _handleContinue : null,
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
                          'Continue',
                          style: AppTextStyles.buttonLarge(
                            color: _isFormValid ? Colors.white : AppColors.textMutedLight,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    Color borderColor = AppColors.outlineLight;
    if (_isUsernameAvailable) {
      borderColor = AppColors.primary;
    } else if (_usernameValidationError != null) {
      borderColor = AppColors.error;
    }

    Widget? suffix;
    if (_isCheckingAvailability) {
      suffix = const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      );
    } else if (_isUsernameAvailable) {
      suffix = const Padding(
        padding: EdgeInsets.all(12),
        child: Icon(Icons.check_rounded, color: AppColors.success, size: 22),
      );
    } else if (_usernameValidationError != null) {
      suffix = const Padding(
        padding: EdgeInsets.all(12),
        child: Icon(Icons.close_rounded, color: AppColors.error, size: 20),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: borderColor, width: _isUsernameAvailable ? 2.0 : 1.2),
      ),
      child: TextField(
        controller: _usernameCtrl,
        autocorrect: false,
        textCapitalization: TextCapitalization.none,
        textInputAction: TextInputAction.next,
        style: AppTextStyles.bodyLarge(color: AppColors.textLight),
        decoration: InputDecoration(
          hintText: 'cool_runner_07',
          hintStyle: AppTextStyles.bodyMedium(color: AppColors.textMutedLight),
          prefixIcon: const Icon(
            Icons.alternate_email_rounded,
            color: AppColors.textSecondaryLight,
            size: 20,
          ),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildUsernameHelper() {
    if (_isUsernameAvailable) {
      return Text(
        'Available. 3-20 characters: a-z 0-9 _ .',
        style: AppTextStyles.caption(color: AppColors.success).copyWith(
          fontWeight: FontWeight.w600,
        ),
      );
    }
    if (_usernameValidationError != null) {
      return Text(
        _usernameValidationError!,
        style: AppTextStyles.caption(color: AppColors.error),
      );
    }
    return Text(
      '3-20 characters: a-z 0-9 _ .',
      style: AppTextStyles.caption(color: AppColors.textSecondaryLight),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.outlineLight, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textInputAction: TextInputAction.next,
        style: AppTextStyles.bodyLarge(color: AppColors.textLight),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium(color: AppColors.textMutedLight),
          prefixIcon: const Icon(
            Icons.square_rounded,
            color: AppColors.textSecondaryLight,
            size: 18,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondaryLight,
              size: 20,
            ),
            onPressed: onToggleVisibility,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthBar() {
    return Row(
      children: [
        Expanded(child: _buildStrengthSegment(index: 1)),
        const SizedBox(width: AppDimensions.space6),
        Expanded(child: _buildStrengthSegment(index: 2)),
        const SizedBox(width: AppDimensions.space6),
        Expanded(child: _buildStrengthSegment(index: 3)),
      ],
    );
  }

  Widget _buildStrengthSegment({required int index}) {
    final bool isFilled = _passwordStrength >= index;
    Color segmentColor = AppColors.outlineLight.withValues(alpha: 0.5);

    if (isFilled) {
      segmentColor = _getStrengthColor();
    }

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: segmentColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
      ),
    );
  }

  Color _getStrengthColor() {
    switch (_passwordStrength) {
      case 1:
        return AppColors.warning;
      case 2:
        return const Color(0xFFB26A00); // Amber
      case 3:
        return AppColors.success;
      default:
        return AppColors.textSecondaryLight;
    }
  }
}
