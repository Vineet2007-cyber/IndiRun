import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/gps_status.dart';

/// S14 GPS states banner — shown inside the map area at the bottom-left.
class GpsStatusBanner extends StatelessWidget {
  const GpsStatusBanner({
    super.key,
    required this.status,
    this.onTapGpsOff,
    this.onTapPermission,
  });

  final GpsStatus status;
  final VoidCallback? onTapGpsOff;
  final VoidCallback? onTapPermission;

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, icon, label) = _config(status);

    return GestureDetector(
      onTap: _tapHandler(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 13, color: color),
            ],
          ],
        ),
      ),
    );
  }

  VoidCallback? _tapHandler(GpsStatus s) {
    if (s == GpsStatus.gpsOff) return onTapGpsOff;
    if (s == GpsStatus.permissionDenied) return onTapPermission;
    return null;
  }

  static (Color, Color, IconData?, String) _config(GpsStatus s) {
    switch (s) {
      case GpsStatus.searching:
        return (
          AppColors.warning,
          AppColors.warningContainer,
          null,
          'Searching GPS...',
        );
      case GpsStatus.weak:
        return (
          AppColors.warning,
          AppColors.warningContainer,
          null,
          'Weak signal. Move to open sky',
        );
      case GpsStatus.gpsOff:
        return (
          AppColors.error,
          AppColors.errorContainer,
          Icons.settings,
          'GPS is off. Tap to turn on',
        );
      case GpsStatus.permissionDenied:
        return (
          AppColors.error,
          AppColors.errorContainer,
          Icons.settings,
          'Location permission denied. Open settings',
        );
      case GpsStatus.ready:
        return (
          AppColors.success,
          AppColors.successContainer,
          null,
          'GPS ready',
        );
    }
  }
}
