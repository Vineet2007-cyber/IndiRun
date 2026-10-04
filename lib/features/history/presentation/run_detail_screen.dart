import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../run/application/run_controller.dart';

/// S23 Run Detail – full run breakdown with splits
class RunDetailScreen extends ConsumerWidget {
  const RunDetailScreen({super.key, required this.runId});
  final String runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final run = ref.read(runControllerProvider.notifier).getById(runId);

    if (run == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Run detail')),
        body: const Center(child: Text('Run not found')),
      );
    }

    // Simulate splits (1 km each)
    final splits = <int>[];
    final kmCount = run.distanceKm.floor();
    for (int i = 0; i < kmCount; i++) {
      final variance = (i % 3 == 0 ? -6 : (i % 2 == 0 ? 3 : 9));
      splits.add((run.avgPaceSec ?? 5 * 60 + 55) + variance);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Run detail',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.more_vert, color: AppColors.textSecondary),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  // Map
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 200,
                      color: AppColors.mapLand,
                      child: CustomPaint(
                        painter: _DetailMapPainter(),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Run name + date
                  Text(
                    run.label ?? 'Morning Run',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${run.dateLabel}  •  06:12',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  // Primary metric grid
                  Row(
                    children: [
                      _DetailStat('DISTANCE',
                          '${run.distanceKm.toStringAsFixed(2)} km'),
                      const SizedBox(width: 28),
                      _DetailStat('DURATION', run.durationFormatted),
                      const SizedBox(width: 28),
                      _DetailStat('AVG PACE', '${run.avgPaceFormatted} /km'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _DetailStat('ELEV GAIN', '12 m'),
                      const SizedBox(width: 28),
                      _DetailStat('BEST KM', '5:41'),
                      const SizedBox(width: 28),
                      _DetailStat('CALORIES', '312'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Splits
                  Text('Splits',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ...splits.asMap().entries.map((e) {
                    final km = e.key + 1;
                    final secs = e.value;
                    final m = secs ~/ 60;
                    final s = secs % 60;
                    final barFrac = 0.6 + (km / splits.length) * 0.3;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            child: Text('$km',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: barFrac,
                                minHeight: 8,
                                backgroundColor: AppColors.surfaceContainer,
                                valueColor: const AlwaysStoppedAnimation(
                                    AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('$m:${s.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            // Share button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => context.push(AppRoutes.share,
                      extra: {'distanceKm': run.distanceKm}),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Share',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Synced 29 Sep, 06:44',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary, letterSpacing: 0.5)),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _DetailMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.mapRoad.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 90) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final route = Paint()
      ..color = AppColors.routeAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.82)
      ..lineTo(size.width * 0.30, size.height * 0.58)
      ..lineTo(size.width * 0.50, size.height * 0.44)
      ..lineTo(size.width * 0.72, size.height * 0.30)
      ..lineTo(size.width * 0.88, size.height * 0.16);

    canvas.drawPath(path, route);

    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.82),
      7,
      Paint()..color = AppColors.success,
    );
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.16),
      7,
      Paint()..color = AppColors.error,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
