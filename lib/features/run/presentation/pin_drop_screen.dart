import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/location_result.dart';

/// S12 Pin drop — user moves the map and identifies a location.
///
/// Pops with a [LocationResult] when they confirm.
class PinDropScreen extends StatefulWidget {
  const PinDropScreen({super.key});

  @override
  State<PinDropScreen> createState() => _PinDropScreenState();
}

class _PinDropScreenState extends State<PinDropScreen> {
  // In a real implementation, this would drive a map controller.
  // Here we keep a demo address string.
  final String _address = 'Riverfront Rd, Ahmedabad';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mapLand,
      body: Stack(
        children: [
          // Map placeholder with grid
          const Positioned.fill(child: _MapBackground()),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: _CircleButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),

          // "Drag map" hint
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Text(
                  'Drag map to move the pin',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Center pin
          const Center(child: _CenterPin()),

          // Bottom sheet with address + actions
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomConfirmSheet(
              address: _address,
              onSetStart: () => Navigator.of(context).pop(LocationResult(
                name: _address,
                subtitle: '',
                lat: 23.015,
                lng: 72.568,
              )),
              onSetEnd: () => Navigator.of(context).pop(LocationResult(
                name: _address,
                subtitle: '',
                lat: 23.015,
                lng: 72.568,
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.mapRoad.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    const cellW = 90.0;
    const cellH = 80.0;
    for (double x = 0; x < size.width; x += cellW) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += cellH) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    // Decorative route line
    final route = Paint()
      ..color = AppColors.routeAccent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final pts = [
      Offset(size.width * 0.1, size.height * 0.9),
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.35, size.height * 0.55),
      Offset(size.width * 0.5, size.height * 0.48),
      Offset(size.width * 0.6, size.height * 0.42),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.95, size.height * 0.05),
    ];
    for (int i = 0; i < pts.length - 1; i++) {
      canvas.drawLine(pts[i], pts[i + 1], route);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pin triangle (pointing down)
        CustomPaint(
          size: const Size(24, 20),
          painter: _PinPainter(),
        ),
      ],
    );
  }
}

class _PinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppColors.routeAccent;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.text),
      ),
    );
  }
}

class _BottomConfirmSheet extends StatelessWidget {
  const _BottomConfirmSheet({
    required this.address,
    required this.onSetStart,
    required this.onSetEnd,
  });

  final String address;
  final VoidCallback onSetStart;
  final VoidCallback onSetEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            address,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSetStart,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.outline),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Set as Start',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onSetEnd,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Set as End',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
