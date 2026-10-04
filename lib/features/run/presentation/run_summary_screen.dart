import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../auth/application/auth_controller.dart';
import '../../profile/application/profile_controller.dart';
import '../application/run_controller.dart';
import '../domain/run_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Default title helper
// ─────────────────────────────────────────────────────────────────────────────

String _defaultRunTitle(DateTime at) {
  final h = at.hour;
  if (h >= 5 && h < 12) return 'Morning Run';
  if (h >= 12 && h < 17) return 'Afternoon Run';
  if (h >= 17 && h < 21) return 'Evening Run';
  return 'Night Run';
}

// ─────────────────────────────────────────────────────────────────────────────
// S19 Run Summary Screen
// ─────────────────────────────────────────────────────────────────────────────

/// The post-run recap screen.
///
/// Navigation contract (via GoRouter `extra`):
/// - `distanceKm` (double)
/// - `durationSeconds` (int)
/// - `avgPaceSec` (int)
/// - `voiceOn` (bool)
/// - `routePoints` (`List<Map<String, double>>`) — GPS trail
/// - `elevGainM` (double?) — optional
/// - `startedAt` (DateTime?) — run start time
///
/// The run has already been persisted as a draft in [activeRunProvider] data.
/// Saving commits it to [RunController]; Discard discards without saving.
class RunSummaryScreen extends ConsumerStatefulWidget {
  const RunSummaryScreen({super.key, this.extra});
  final Map<String, dynamic>? extra;

  @override
  ConsumerState<RunSummaryScreen> createState() => _RunSummaryScreenState();
}

class _RunSummaryScreenState extends ConsumerState<RunSummaryScreen> {
  late final TextEditingController _titleCtrl;
  bool _saving = false;
  bool _saved = false;

  // ── Extracted run data ─────────────────────────────────────────────────────
  late final double _distKm;
  late final int _durSec;
  late final int _avgPaceSec;
  late final bool _voiceOn;
  late final List<Map<String, double>> _routePoints;
  late final double? _elevGainM;
  late final DateTime _startedAt;
  late final DateTime _endedAt;

  @override
  void initState() {
    super.initState();
    final e = widget.extra ?? {};
    _distKm = (e['distanceKm'] as double?) ?? 5.02;
    _durSec = (e['durationSeconds'] as int?) ?? 29 * 60 + 40;
    _avgPaceSec = (e['avgPaceSec'] as int?) ?? 5 * 60 + 55;
    _voiceOn = (e['voiceOn'] as bool?) ?? false;
    _elevGainM = e['elevGainM'] as double?;
    _endedAt = DateTime.now();
    _startedAt = (e['startedAt'] as DateTime?) ??
        _endedAt.subtract(Duration(seconds: _durSec));

    // routePoints may come as List<dynamic> from go_router extra
    final rawPts = e['routePoints'];
    if (rawPts is List) {
      _routePoints = rawPts
          .whereType<Map>()
          .map((m) => {
                'lat': (m['lat'] as num?)?.toDouble() ?? 0.0,
                'lng': (m['lng'] as num?)?.toDouble() ?? 0.0,
              })
          .toList();
    } else {
      _routePoints = [];
    }

    _titleCtrl = TextEditingController(text: _defaultRunTitle(_startedAt));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  // ── Formatting helpers ─────────────────────────────────────────────────────

  String get _durFormatted {
    final m = _durSec ~/ 60;
    final s = _durSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _paceFormatted {
    if (_avgPaceSec == 0) return '--:--';
    final m = _avgPaceSec ~/ 60;
    final s = _avgPaceSec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get _timestampLabel {
    String fmt(DateTime dt) {
      final h = dt.hour;
      final ampm = h >= 12 ? 'PM' : 'AM';
      final hh = h % 12 == 0 ? 12 : h % 12;
      return '$hh:${dt.minute.toString().padLeft(2, '0')} $ampm';
    }

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Started ${fmt(_startedAt)}  •  '
        'Ended ${fmt(_endedAt)}  •  '
        '${_startedAt.day} ${months[_startedAt.month - 1]}';
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_saving || _saved) return;
    setState(() => _saving = true);

    final label = _titleCtrl.text.trim().isEmpty
        ? _defaultRunTitle(_startedAt)
        : _titleCtrl.text.trim();

    final run = RunModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startedAt: _startedAt,
      endedAt: _endedAt,
      distanceKm: _distKm,
      durationSeconds: _durSec,
      routePoints: _routePoints,
      label: label,
      avgPaceSec: _avgPaceSec,
      elevGainM: _elevGainM,
    );

    await ref.read(runControllerProvider.notifier).saveRun(run);
    setState(() {
      _saving = false;
      _saved = true;
    });
    if (mounted) context.go(AppRoutes.home);
  }

  void _discard() => context.go(AppRoutes.home);

  void _openShare() {
    final authUser = ref.read(authControllerProvider).user;
    final profile = ref.read(profileControllerProvider).value;
    final username =
        profile?.displayName ?? authUser?.displayName ?? 'Runner';

    context.push(AppRoutes.share, extra: {
      'distanceKm': _distKm,
      'durationSeconds': _durSec,
      'avgPaceSec': _avgPaceSec,
      'voiceOn': _voiceOn,
      'routePoints': _routePoints,
      'elevGainM': _elevGainM,
      'startedAt': _startedAt,
      'username': username,
    });
  }

  // ── Back (Android back button) ─────────────────────────────────────────────

  Future<bool> _onWillPop() async {
    if (_saved) return true;

    final result = await showDialog<String>(
      context: context,
      builder: (_) => _SaveDiscardDialog(
        onSave: () => Navigator.pop(context, 'save'),
        onDiscard: () => Navigator.pop(context, 'discard'),
        onCancel: () => Navigator.pop(context, 'cancel'),
      ),
    );

    if (result == 'save') {
      await _save();
      return false; // _save handles navigation
    } else if (result == 'discard') {
      return true;
    }
    return false;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: _saved,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _onWillPop();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────────
              _SummaryHeader(startedAt: _startedAt, distKm: _distKm),

              // ── Scrollable body ────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Editable title
                      TextField(
                        controller: _titleCtrl,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          suffixIcon: const Icon(Icons.edit_outlined,
                              color: AppColors.textSecondary, size: 18),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          hintText: 'Run name',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Route map
                      _RouteMap(
                        routePoints: _routePoints,
                        voiceOn: _voiceOn,
                        distKm: _distKm,
                      ),
                      const SizedBox(height: 20),

                      // Timestamp
                      Text(
                        _timestampLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Hero: distance
                      Text(
                        'DISTANCE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${_distKm.toStringAsFixed(2)} km',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Secondary metrics
                      _MetricsRow(
                        duration: _durFormatted,
                        pace: '$_paceFormatted /km',
                        elevGainM: _elevGainM,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Action buttons ─────────────────────────────────────────────
              _ActionBar(
                saving: _saving,
                saved: _saved,
                onSave: _save,
                onShare: _openShare,
                onDiscard: _discard,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.startedAt, required this.distKm});
  final DateTime startedAt;
  final double distKm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final dateLabel =
        '${days[startedAt.weekday - 1]}, ${startedAt.day} ${months[startedAt.month - 1]}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Run complete ✓',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            dateLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteMap extends StatelessWidget {
  const _RouteMap({
    required this.routePoints,
    required this.voiceOn,
    required this.distKm,
  });

  final List<Map<String, double>> routePoints;
  final bool voiceOn;
  final double distKm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 220,
        color: AppColors.mapLand,
        child: Stack(
          children: [
            CustomPaint(
              painter: _SummaryMapPainter(points: routePoints),
              child: const SizedBox.expand(),
            ),
            if (voiceOn)
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Voice-guided',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.duration,
    required this.pace,
    this.elevGainM,
  });

  final String duration;
  final String pace;
  final double? elevGainM;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 12,
      children: [
        _StatBlock('DURATION', duration),
        _StatBlock('AVG PACE', pace),
        if (elevGainM != null)
          _StatBlock('ELEV GAIN', '${elevGainM!.round()} m'),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.saving,
    required this.saved,
    required this.onSave,
    required this.onShare,
    required this.onDiscard,
  });

  final bool saving;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Save run (primary)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: (saving || saved) ? null : onSave,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                shape: const StadiumBorder(),
              ),
              child: saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Save run',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          // Share + Discard row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onShare,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.outline),
                    shape: const StadiumBorder(),
                    minimumSize: const Size(0, 48),
                  ),
                  icon: const Icon(Icons.share_outlined,
                      size: 16, color: AppColors.primary),
                  label: const Text(
                    'Share',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDiscard,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: const StadiumBorder(),
                    minimumSize: const Size(0, 48),
                  ),
                  child: const Text(
                    'Discard',
                    style: TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.w600),
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

// ─────────────────────────────────────────────────────────────────────────────
// Save / Discard dialog (back-button handler)
// ─────────────────────────────────────────────────────────────────────────────

class _SaveDiscardDialog extends StatelessWidget {
  const _SaveDiscardDialog({
    required this.onSave,
    required this.onDiscard,
    required this.onCancel,
  });

  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final VoidCallback onCancel;

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
            Text(
              'Save this run?',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Your run will be lost if you discard it.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: onDiscard,
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Discard',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onCancel,
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Save',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
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
// Summary map painter
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryMapPainter extends CustomPainter {
  const _SummaryMapPainter({required this.points});
  final List<Map<String, double>> points;

  @override
  void paint(Canvas canvas, Size size) {
    // Grid
    final grid = Paint()
      ..color = AppColors.mapRoad.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Build offsets
    List<Offset> offsets;
    if (points.length < 2) {
      // Fallback static route
      offsets = [
        Offset(size.width * 0.12, size.height * 0.85),
        Offset(size.width * 0.28, size.height * 0.60),
        Offset(size.width * 0.48, size.height * 0.48),
        Offset(size.width * 0.68, size.height * 0.32),
        Offset(size.width * 0.88, size.height * 0.14),
      ];
    } else {
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
      const pad = 24.0;
      offsets = points.map((p) {
        final x = lngRange == 0
            ? size.width / 2
            : pad + (p['lng']! - minLng) / lngRange * (size.width - pad * 2);
        final y = latRange == 0
            ? size.height / 2
            : size.height -
                pad -
                (p['lat']! - minLat) / latRange * (size.height - pad * 2);
        return Offset(x, y);
      }).toList();
    }

    // Route line
    final route = Paint()
      ..color = AppColors.routeAccent
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
    }
    canvas.drawPath(path, route);

    // Start dot (green)
    canvas.drawCircle(offsets.first, 7, Paint()..color = AppColors.success);
    canvas.drawCircle(
      offsets.first,
      7,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // End dot (red)
    canvas.drawCircle(offsets.last, 7, Paint()..color = AppColors.error);
    canvas.drawCircle(
      offsets.last,
      7,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SummaryMapPainter old) =>
      old.points.length != points.length;
}

// Keep dart:math import used
// ignore: unused_element
double _pi = math.pi;
