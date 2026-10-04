import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class IndiRunTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final bool isSuccess;
  final String? errorText;
  final String? helperText;
  final Color? helperColor;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  final bool autofocus;
  final int? passwordStrength; // 0 to 3

  const IndiRunTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.isSuccess = false,
    this.errorText,
    this.helperText,
    this.helperColor,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.autofocus = false,
    this.passwordStrength,
  });

  @override
  State<IndiRunTextField> createState() => _IndiRunTextFieldState();
}

class _IndiRunTextFieldState extends State<IndiRunTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color borderColor = isDark ? AppColors.outlineDark : AppColors.outline;
    if (widget.errorText != null) {
      borderColor = AppColors.error;
    } else if (widget.isSuccess) {
      borderColor = AppColors.success;
    }

    Widget? suffix;
    if (widget.isPassword) {
      suffix = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: isDark ? AppColors.textMutedDark : AppColors.mutedText,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.isSuccess) {
      suffix = const Icon(Icons.check, color: AppColors.success, size: 20);
    } else if (widget.suffixIcon != null) {
      suffix = widget.suffixIcon;
    }

    Widget? prefix;
    if (widget.prefixText != null) {
      prefix = Padding(
        padding: const EdgeInsets.only(left: 14, right: 8),
        child: Text(
          widget.prefixText!,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      );
    } else if (widget.prefixIcon != null) {
      prefix = widget.prefixIcon;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textDark : AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: borderColor,
              width: widget.isSuccess || widget.errorText != null ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              ?prefix,
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  autofocus: widget.autofocus,
                  obscureText: widget.isPassword && _obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: prefix == null ? 14 : 4,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              if (suffix != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: suffix,
                ),
            ],
          ),
        ),
        if (widget.passwordStrength != null) ...[
          const SizedBox(height: 8),
          Row(
            children: List.generate(3, (index) {
              final active = index < (widget.passwordStrength ?? 0);
              Color barColor = isDark ? AppColors.outlineDark : AppColors.outline;
              if (active) {
                if (widget.passwordStrength == 1) {
                  barColor = AppColors.error;
                } else if (widget.passwordStrength == 2) {
                  barColor = AppColors.warning;
                } else {
                  barColor = AppColors.success;
                }
              }
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: widget.helperColor ??
                  (widget.isSuccess
                      ? AppColors.success
                      : (isDark ? AppColors.textMutedDark : AppColors.mutedText)),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
