import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

enum IndiRunBannerType {
  searchingGps,
  gpsReady,
  gpsOff,
  weakGps,
  offline,
  syncFailed,
  info,
  success,
}

class IndiRunBanner extends StatelessWidget {
  final String message;
  final IndiRunBannerType type;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const IndiRunBanner({
    super.key,
    required this.message,
    this.type = IndiRunBannerType.info,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case IndiRunBannerType.searchingGps:
      case IndiRunBannerType.weakGps:
      case IndiRunBannerType.offline:
        backgroundColor = AppColors.warningContainer;
        textColor = AppColors.warning;
        break;
      case IndiRunBannerType.gpsReady:
      case IndiRunBannerType.success:
        backgroundColor = AppColors.successContainer;
        textColor = AppColors.success;
        break;
      case IndiRunBannerType.gpsOff:
        backgroundColor = AppColors.errorContainer;
        textColor = AppColors.error;
        break;
      case IndiRunBannerType.syncFailed:
        backgroundColor = const Color(0xFF313033);
        textColor = Colors.white;
        break;
      case IndiRunBannerType.info:
        backgroundColor = AppColors.primaryContainer;
        textColor = AppColors.onPrimaryContainer;
        break;
    }

    Widget content = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
