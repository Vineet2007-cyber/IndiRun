import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/audio_cue_service.dart';
import '../application/run_controller.dart';

/// S15 Countdown screen (3 → 2 → 1 → GO)
///
/// Haptic feedback fires on every tick.  Voice cue fires if voiceOn.
/// Tapping the screen at any point cancels the run and returns to pre-run.
class CountdownScreen extends ConsumerStatefulWidget {
  const CountdownScreen({super.key});

  @override
  ConsumerState<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends ConsumerState<CountdownScreen>
    with TickerProviderStateMixin {
  // 3, 2, 1, then 0 = "GO"
  int _count = 3;
  bool _showGo = false;
  bool _cancelled = false;

  late Timer _timer;

  // Scale + fade for each number change
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  // Full-screen flash when GO fires
  late AnimationController _flashCtrl;
  late Animation<double> _flashOpacity;

  @override
  void initState() {
    super.initState();

    // Number animation
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 1.4, end: 1.0).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleCtrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Full-screen green flash
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flashOpacity = Tween<double>(begin: 0.0, end: 0.35).animate(
      CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut),
    );

    // Fire first tick immediately
    _tick();

    // Then repeat every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_cancelled || !mounted) return;

    final voiceOn = ref.read(activeRunProvider).voiceOn;

    // Haptic + audio
    AudioCueService.instance
        .playCountdownTick(_count, voiceEnabled: voiceOn);

    if (_count > 1) {
      setState(() {});
      _scaleCtrl.forward(from: 0);
      _count--;
    } else if (_count == 1) {
      // Show "GO"
      _timer.cancel();
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted || _cancelled) return;
        setState(() => _showGo = true);
        _scaleCtrl.forward(from: 0);
        _flashCtrl.forward().then((_) => _flashCtrl.reverse());
        AudioCueService.instance.playCountdownTick(0, voiceEnabled: voiceOn);
        // Start the run and navigate after brief "GO" display
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted || _cancelled) return;
          ref.read(activeRunProvider.notifier).startRun(voiceOn: voiceOn);
          context.go(AppRoutes.activeRun);
        });
      });
      _count--;
    }
  }

  void _cancel() {
    _cancelled = true;
    _timer.cancel();
    ref.read(activeRunProvider.notifier).endRun();
    if (mounted) context.go(AppRoutes.preRun);
  }

  @override
  void dispose() {
    _timer.cancel();
    _scaleCtrl.dispose();
    _flashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceOn = ref.read(activeRunProvider).voiceOn;
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF3A4A44), // muted forest map tint
      body: GestureDetector(
        onTap: _cancel,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background map-style tinted grid
            CustomPaint(
              size: size,
              painter: _MapGridPainter(),
            ),

            // Full-screen GO flash overlay
            AnimatedBuilder(
              animation: _flashOpacity,
              builder: (context, child) => Opacity(
                opacity: _flashOpacity.value,
                child: Container(
                  color: AppColors.success,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // ── Count / GO circle ──────────────────────────────────
                  AnimatedBuilder(
                    animation: _scaleCtrl,
                    builder: (_, child) => Transform.scale(
                      scale: _scaleAnim.value,
                      child: Opacity(
                        opacity: _opacityAnim.value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    ),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _showGo ? AppColors.success : AppColors.primary,
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_showGo ? AppColors.success : AppColors.primary)
                                .withValues(alpha: 0.3),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _showGo ? 'GO' : '$_count',
                          style: TextStyle(
                            fontSize: _showGo ? 64 : 96,
                            fontWeight: FontWeight.w900,
                            color: _showGo
                                ? AppColors.success
                                : AppColors.primary,
                            height: 1.0,
                            letterSpacing: _showGo ? 4 : 0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // GPS dot + status
                  _GpsDot(),
                  const SizedBox(height: 8),

                  Text(
                    _showGo ? 'Starting your run…' : 'Get ready',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    voiceOn ? 'Voice guidance is on' : 'Voice guidance is off',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),

                  const Spacer(),

                  // Cancel hint
                  if (!_showGo)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Text(
                        'Tap anywhere to cancel',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── GPS pulsing dot ─────────────────────────────────────────────────────────

class _GpsDot extends StatefulWidget {
  @override
  State<_GpsDot> createState() => _GpsDotState();
}

class _GpsDotState extends State<_GpsDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Container(
        width: 12 + _ctrl.value * 4,
        height: 12 + _ctrl.value * 4,
        decoration: BoxDecoration(
          color: AppColors.gpsDot.withValues(alpha: 0.8 + _ctrl.value * 0.2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.gpsDotOuter.withValues(alpha: 0.5),
              blurRadius: 8 + _ctrl.value * 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Background grid painter ─────────────────────────────────────────────────

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
