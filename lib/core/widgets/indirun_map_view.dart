
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class IndiRunMapView extends StatelessWidget {
  final List<Offset>? routePoints;
  final bool showGrid;
  final bool showStartDot;
  final bool showEndPin;
  final bool showGpsDot;
  final Offset? gpsPosition;
  final bool showCenterPin;
  final bool blurEndpoints;
  final double borderRadius;
  final Widget? overlayBadge;
  final List<Widget>? floatingControls;

  const IndiRunMapView({
    super.key,
    this.routePoints,
    this.showGrid = true,
    this.showStartDot = true,
    this.showEndPin = true,
    this.showGpsDot = false,
    this.gpsPosition,
    this.showCenterPin = false,
    this.blurEndpoints = false,
    this.borderRadius = AppDimensions.radiusCard,
    this.overlayBadge,
    this.floatingControls,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _IndiRunMapPainter(
                routePoints: routePoints,
                showGrid: showGrid,
                showStartDot: showStartDot,
                showEndPin: showEndPin,
                showGpsDot: showGpsDot,
                gpsPosition: gpsPosition,
                showCenterPin: showCenterPin,
                blurEndpoints: blurEndpoints,
                isDark: isDark,
              ),
            ),
          ),
          if (overlayBadge != null)
            Positioned(
              left: 12,
              bottom: 12,
              child: overlayBadge!,
            ),
          if (floatingControls != null && floatingControls!.isNotEmpty)
            Positioned(
              right: 12,
              top: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: floatingControls!,
              ),
            ),
        ],
      ),
    );
  }
}

class _IndiRunMapPainter extends CustomPainter {
  final List<Offset>? routePoints;
  final bool showGrid;
  final bool showStartDot;
  final bool showEndPin;
  final bool showGpsDot;
  final Offset? gpsPosition;
  final bool showCenterPin;
  final bool blurEndpoints;
  final bool isDark;

  _IndiRunMapPainter({
    this.routePoints,
    required this.showGrid,
    required this.showStartDot,
    required this.showEndPin,
    required this.showGpsDot,
    this.gpsPosition,
    required this.showCenterPin,
    required this.blurEndpoints,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final landColor = isDark ? const Color(0xFF1E2E28) : AppColors.mapLand;
    final roadColor = isDark ? const Color(0xFF2C3D36) : AppColors.mapRoad;

    // Draw background (roads grid)
    final bgPaint = Paint()..color = roadColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    if (showGrid) {
      // Draw 3x3 rounded land blocks exactly like approved SVGs
      final landPaint = Paint()..color = landColor;
      const cols = 3;
      const rows = 3;
      const gap = 8.0;
      final blockW = (size.width - (gap * (cols + 1))) / cols;
      final blockH = (size.height - (gap * (rows + 1))) / rows;

      for (int c = 0; c < cols; c++) {
        for (int r = 0; r < rows; r++) {
          final x = gap + c * (blockW + gap);
          final y = gap + r * (blockH + gap);
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, blockW, blockH),
            const Radius.circular(8),
          );
          canvas.drawRRect(rect, landPaint);
        }
      }
    }

    // Default route points if not provided or empty (standard SVG route curve)
    final points = (routePoints != null && routePoints!.length >= 2)
        ? routePoints!
        : [
            Offset(size.width * 0.18, size.height * 0.78),
            Offset(size.width * 0.32, size.height * 0.52),
            Offset(size.width * 0.43, size.height * 0.62),
            Offset(size.width * 0.58, size.height * 0.37),
            Offset(size.width * 0.70, size.height * 0.45),
            Offset(size.width * 0.82, size.height * 0.22),
          ];

    // Draw polyline
    final routePaint = Paint()
      ..color = AppColors.routeAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, routePaint);

    // Endpoint privacy blur circles if enabled
    if (blurEndpoints) {
      final blurPaint = Paint()
        ..color = AppColors.routeAccent.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawCircle(points.first, 24, blurPaint);
      canvas.drawCircle(points.last, 24, blurPaint);
    }

    // Draw Start Dot (Green)
    if (showStartDot && points.isNotEmpty) {
      final startCenter = points.first;
      final whiteRing = Paint()..color = Colors.white;
      final greenDot = Paint()..color = AppColors.success;

      canvas.drawCircle(startCenter, 7, whiteRing);
      canvas.drawCircle(startCenter, 5, greenDot);
    }

    // Draw End Pin (Red)
    if (showEndPin && points.length > 1) {
      final endCenter = points.last;
      final whiteRing = Paint()..color = Colors.white;
      final redDot = Paint()..color = AppColors.error;

      canvas.drawCircle(endCenter, 7, whiteRing);
      canvas.drawCircle(endCenter, 5, redDot);
    }

    // Draw GPS location dot (Blue)
    if (showGpsDot) {
      final center = gpsPosition ?? Offset(size.width * 0.5, size.height * 0.5);
      final outerRing = Paint()..color = AppColors.gpsDotOuter.withValues(alpha: 0.5);
      final whiteRing = Paint()..color = Colors.white;
      final blueDot = Paint()..color = AppColors.gpsDot;

      canvas.drawCircle(center, 12, outerRing);
      canvas.drawCircle(center, 6, whiteRing);
      canvas.drawCircle(center, 4.5, blueDot);
    }

    // Draw Center Inverted Triangle Pin (S12 Pin Drop)
    if (showCenterPin) {
      final cx = size.width / 2;
      final cy = size.height / 2;
      final pinPaint = Paint()
        ..color = AppColors.routeAccent
        ..style = PaintingStyle.fill;

      final pinPath = Path()
        ..moveTo(cx - 14, cy - 18)
        ..lineTo(cx + 14, cy - 18)
        ..lineTo(cx, cy + 8)
        ..close();

      canvas.drawPath(pinPath, pinPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _IndiRunMapPainter oldDelegate) {
    return oldDelegate.routePoints != routePoints ||
        oldDelegate.showGpsDot != showGpsDot ||
        oldDelegate.gpsPosition != gpsPosition ||
        oldDelegate.showCenterPin != showCenterPin ||
        oldDelegate.blurEndpoints != blurEndpoints ||
        oldDelegate.isDark != isDark;
  }
}
