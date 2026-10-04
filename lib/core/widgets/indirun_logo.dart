import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class IndiRunLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double textSize;
  final Color? color;
  final Color? iconColor;

  const IndiRunLogo({
    super.key,
    this.size = 80,
    this.showText = false,
    this.textSize = 28,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final logoBadge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.35, size * 0.35),
          painter: _PlayTrianglePainter(iconColor ?? Colors.white),
        ),
      ),
    );

    if (!showText) {
      return logoBadge;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoBadge,
        const SizedBox(height: 16),
        Text(
          'INDIRUN',
          style: GoogleFonts.poppins(
            fontSize: textSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: color ?? (Theme.of(context).brightness == Brightness.dark ? AppColors.textDark : AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _PlayTrianglePainter extends CustomPainter {
  final Color color;

  _PlayTrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.1)
      ..lineTo(size.width * 0.95, size.height * 0.5)
      ..lineTo(size.width * 0.15, size.height * 0.9)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PlayTrianglePainter oldDelegate) => oldDelegate.color != color;
}
