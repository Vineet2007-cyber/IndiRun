import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/location_tracking_service.dart';
import '../application/run_controller.dart';

/// S16 Active Run / S17 Paused screens
///
/// All metrics are driven entirely by [activeRunProvider] state which is
/// updated by [LocationTrackingService] in [ActiveRunNotifier].
/// No direct API or network calls from this widget.
class ActiveRunScreen extends ConsumerStatefulWidget {
  const ActiveRunScreen({super.key});

  @override
  ConsumerState<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends ConsumerState<ActiveRunScreen>
    with SingleTickerProviderStateMixin {
  // Paused-banner pulse animation
  late AnimationController _pausePulse;

  @override
  void initState() {
    super.initState();
    _pausePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pausePulse.dispose();
    super.dispose();
  }

  // ── End run flow ───────────────────────────────────────────────────────────

  void _showEndDialog() {
    final run = ref.read(activeRunProvider);
    if (run.isTooShort) {
      _showVeryShortRunDialog(run);
    } else {
      _showStandardEndDialog(run);
    }
  }

  void _showStandardEndDialog(ActiveRunState run) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => _EndRunDialog(
        distanceKm: run.distanceKm,
        durationSeconds: run.durationSeconds,
        onKeepRunning: () => Navigator.pop(context),
        onEndRun: () {
          Navigator.pop(context);
          _endRun(run);
        },
      ),
    );
  }

  /// S18b – Very short run dialog (< 0.1 km and < 60 s)
  void _showVeryShortRunDialog(ActiveRunState run) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => _VeryShortRunDialog(
        onKeepRunning: () => Navigator.pop(context),
        onDiscard: () {
          Navigator.pop(context);
          _discardRun();
        },
      ),
    );
  }

  void _endRun(ActiveRunState run) async {
    final data = {
      'distanceKm': run.distanceKm,
      'durationSeconds': run.durationSeconds,
      'avgPaceSec': run.avgPaceSec,
      'voiceOn': run.voiceOn,
      'routePoints': run.routePoints,
    };
    await ref.read(activeRunProvider.notifier).endRun();
    if (mounted) context.go(AppRoutes.runSummary, extra: data);
  }

  void _discardRun() async {
    await ref.read(activeRunProvider.notifier).endRun();
    if (mounted) context.go(AppRoutes.home);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(activeRunProvider);
    final isPaused = run.isPaused;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false, // Prevent back-button during run
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Paused banner ─────────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isPaused
                    ? _PausedBanner(pulse: _pausePulse)
                    : const SizedBox.shrink(),
              ),

              // ── GPS status ────────────────────────────────────────────────
              _GpsStatusRow(gpsStatus: run.gpsStatus),

              // ── Metrics panel ─────────────────────────────────────────────
              _MetricsPanel(run: run, theme: theme),

              const SizedBox(height: 8),

              // ── Live map ──────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Map background + polyline
                        Container(
                          color: AppColors.mapLand,
                          child: _RunMap(run: run),
                        ),
                        // Map controls (right side)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Column(
                            children: [
                              _MapFab(
                                icon: Icons.layers_rounded,
                                onTap: () {}, // layers sheet
                              ),
                              const SizedBox(height: 8),
                              _MapFab(
                                icon: Icons.my_location_rounded,
                                onTap: () {}, // recenter
                              ),
                            ],
                          ),
                        ),
                        // Voice chip (bottom-left)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: _VoiceChip(on: run.voiceOn, paused: isPaused),
                        ),
                        // Elapsed badge (bottom-right)
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: _ElapsedBadge(
                            formatted: run.durationFormatted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Action buttons ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    // Pause / Resume
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: isPaused
                              ? () => ref
                                    .read(activeRunProvider.notifier)
                                    .resumeRun()
                              : () => ref
                                    .read(activeRunProvider.notifier)
                                    .pauseRun(),
                          style: FilledButton.styleFrom(
                            backgroundColor: isPaused
                                ? AppColors.success
                                : AppColors.primary,
                            shape: const StadiumBorder(),
                          ),
                          icon: Icon(
                            isPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          label: Text(
                            isPaused ? 'Resume Run' : 'Pause Run',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // End run
                    SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _showEndDialog,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.error,
                            width: 1.5,
                          ),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                        ),
                        child: const Text(
                          'End',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GPS status row
// ─────────────────────────────────────────────────────────────────────────────

class _GpsStatusRow extends StatelessWidget {
  const _GpsStatusRow({required this.gpsStatus});
  final GpsStatus gpsStatus;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (gpsStatus) {
      GpsStatus.searching => (AppColors.warning, 'GPS searching…'),
      GpsStatus.poor => (AppColors.warning, 'GPS: weak signal'),
      GpsStatus.good => (AppColors.success, 'GPS: good'),
      GpsStatus.excellent => (AppColors.success, 'GPS: excellent'),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          if (gpsStatus == GpsStatus.searching)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
            )
          else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metrics panel
// ─────────────────────────────────────────────────────────────────────────────

class _MetricsPanel extends StatelessWidget {
  const _MetricsPanel({required this.run, required this.theme});
  final ActiveRunState run;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Current pace (large) | Distance (large)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'PACE / km',
                  value: run.paceFormatted,
                  large: true,
                ),
              ),
              Expanded(
                child: _MetricBlock(
                  label: 'DISTANCE',
                  value: '${run.distanceFormatted} km',
                  large: true,
                  crossAlignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 2: Elapsed time (large) | Avg pace
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _MetricBlock(
                  label: 'TIME',
                  value: run.durationFormatted,
                  large: true,
                ),
              ),
              Expanded(
                child: _MetricBlock(
                  label: 'AVG PACE / km',
                  value: run.avgPaceFormatted,
                  large: false,
                  crossAlignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.value,
    this.large = false,
    this.crossAlignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final bool large;
  final CrossAxisAlignment crossAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAlignment,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.textSecondary, letterSpacing: 0.6),
        ),
        Text(
          value,
          style: large
              ? Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  height: 1.1,
                )
              : Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Live run map
// ─────────────────────────────────────────────────────────────────────────────

class _RunMap extends StatelessWidget {
  const _RunMap({required this.run});
  final ActiveRunState run;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RoutePainter(
        points: run.routePoints,
        lat: run.currentLat,
        lng: run.currentLng,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({required this.points, this.lat, this.lng});

  final List<Map<String, double>> points;
  final double? lat;
  final double? lng;

  @override
  void paint(Canvas canvas, Size size) {
    // ── Grid ──────────────────────────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = AppColors.mapRoad.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.isEmpty) {
      // Placeholder: show a center GPS dot
      _drawGpsDot(canvas, Offset(size.width / 2, size.height / 2));
      return;
    }

    // ── Normalise GPS coords to canvas space ─────────────────────────────────
    double minLat = points.first['lat']!;
    double maxLat = minLat;
    double minLng = points.first['lng']!;
    double maxLng = minLng;

    for (final p in points) {
      if (p['lat']! < minLat) minLat = p['lat']!;
      if (p['lat']! > maxLat) maxLat = p['lat']!;
      if (p['lng']! < minLng) minLng = p['lng']!;
      if (p['lng']! > maxLng) maxLng = p['lng']!;
    }

    final latRange = (maxLat - minLat).abs();
    final lngRange = (maxLng - minLng).abs();

    Offset toCanvas(double ptLat, double ptLng) {
      const pad = 40.0;
      final x = lngRange == 0
          ? size.width / 2
          : pad + (ptLng - minLng) / lngRange * (size.width - pad * 2);
      final y = latRange == 0
          ? size.height / 2
          : size.height -
                pad -
                (ptLat - minLat) / latRange * (size.height - pad * 2);
      return Offset(x, y);
    }

    // ── Route polyline ────────────────────────────────────────────────────────
    final routePaint = Paint()
      ..color = AppColors.routeAccent
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final pt = toCanvas(points[i]['lat']!, points[i]['lng']!);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(path, routePaint);

    // ── Start dot (green) ─────────────────────────────────────────────────────
    final start = toCanvas(points.first['lat']!, points.first['lng']!);
    canvas.drawCircle(start, 7, Paint()..color = AppColors.success);
    canvas.drawCircle(
      start,
      7,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // ── Current position dot (blue pulsing)  ──────────────────────────────────
    final current = toCanvas(points.last['lat']!, points.last['lng']!);
    _drawGpsDot(canvas, current);
  }

  void _drawGpsDot(Canvas canvas, Offset center) {
    // Outer halo
    canvas.drawCircle(
      center,
      18,
      Paint()..color = AppColors.gpsDotOuter.withValues(alpha: 0.3),
    );
    // Inner dot
    canvas.drawCircle(center, 8, Paint()..color = AppColors.gpsDot);
    canvas.drawCircle(
      center,
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) =>
      old.points.length != points.length || old.lat != lat || old.lng != lng;
}

// ─────────────────────────────────────────────────────────────────────────────
// Map FAB
// ─────────────────────────────────────────────────────────────────────────────

class _MapFab extends StatelessWidget {
  const _MapFab({required this.icon, required this.onTap});
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
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.text),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Voice chip
// ─────────────────────────────────────────────────────────────────────────────

class _VoiceChip extends StatelessWidget {
  const _VoiceChip({required this.on, required this.paused});
  final bool on;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final color = paused
        ? AppColors.warning
        : (on ? AppColors.success : AppColors.outline);
    final label = paused ? 'Voice paused' : (on ? 'Voice on' : 'Voice off');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.text, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Elapsed time badge (overlay on map)
// ─────────────────────────────────────────────────────────────────────────────

class _ElapsedBadge extends StatelessWidget {
  const _ElapsedBadge({required this.formatted});
  final String formatted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            formatted,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.text),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Paused banner (animated pulse)
// ─────────────────────────────────────────────────────────────────────────────

class _PausedBanner extends StatelessWidget {
  const _PausedBanner({required this.pulse});
  final AnimationController pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) => Container(
        width: double.infinity,
        color: AppColors.warningContainer.withValues(
          alpha: 0.8 + pulse.value * 0.2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(
                  alpha: 0.5 + pulse.value * 0.5,
                ),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'RUN PAUSED',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Standard end-run confirmation dialog (S18)
// ─────────────────────────────────────────────────────────────────────────────

class _EndRunDialog extends StatelessWidget {
  const _EndRunDialog({
    required this.distanceKm,
    required this.durationSeconds,
    required this.onKeepRunning,
    required this.onEndRun,
  });

  final double distanceKm;
  final int durationSeconds;
  final VoidCallback onKeepRunning;
  final VoidCallback onEndRun;

  @override
  Widget build(BuildContext context) {
    final km = distanceKm.toStringAsFixed(2);
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    final dur =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'End this run?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$km km  •  $dur',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your run will be saved when you confirm.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onKeepRunning,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Keep running'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onEndRun,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'End run',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// S18b Very short run dialog
// ─────────────────────────────────────────────────────────────────────────────

class _VeryShortRunDialog extends StatelessWidget {
  const _VeryShortRunDialog({
    required this.onKeepRunning,
    required this.onDiscard,
  });

  final VoidCallback onKeepRunning;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Run too short',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This run is very short. It won't be saved.\n"
              'Keep running to record your activity.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDiscard,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: const StadiumBorder(),
                      minimumSize: const Size(0, 44),
                    ),
                    child: const Text(
                      'Discard',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onKeepRunning,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                      minimumSize: const Size(0, 44),
                    ),
                    child: const Text(
                      'Keep running',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
double _unused = math.pi; // keep dart:math import used
