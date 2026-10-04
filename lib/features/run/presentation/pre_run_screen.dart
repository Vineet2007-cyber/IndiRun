import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../application/pre_run_controller.dart';
import '../application/run_controller.dart';
import '../domain/gps_status.dart';
import '../domain/location_result.dart';
import '../domain/pre_run_state.dart';
import 'gps_status_banner.dart';
import 'location_search_screen.dart';
import 'map_layers_sheet.dart';

/// S09/S10 Pre-run screen
class PreRunScreen extends ConsumerWidget {
  const PreRunScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(preRunProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text('Start Run',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const _RouteLabel('Start:', 'My location'),
                  const SizedBox(width: 24),
                  _RouteLabel('End:', state.destination?.name ?? 'Not set',
                      highlight: state.hasRoute),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Row(
                children: [
                  _RouteLabel('Distance:',
                      state.hasDistanceInfo ? '${state.routeDistanceKm!.toStringAsFixed(1)} km' : '-'),
                  const SizedBox(width: 24),
                  _RouteLabel('Time:',
                      state.hasDistanceInfo ? '~${state.estimatedMinutes} min (est.)' : '-'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _MapBackground(isDark: state.mapLayer.name == 'satellite'),
                    ),
                    if (state.hasRoute)
                      const Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          child: _RoutePolyline(),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 64,
                      child: _SearchBar(
                        destination: state.destination,
                        isOffline: state.isOffline,
                        onTap: () => _openSearch(context, ref, state.isOffline),
                        onClear: () => ref.read(preRunProvider.notifier).clearDestination(),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 56,
                      child: Column(
                        children: [
                          _MapFab(icon: Icons.diamond_outlined, onTap: () => MapLayersSheet.show(context), tooltip: 'Map layers'),
                          const SizedBox(height: 8),
                          _MapFab(icon: Icons.layers_outlined, onTap: () => MapLayersSheet.show(context), tooltip: 'Map layers'),
                          const SizedBox(height: 8),
                          _MapFab(icon: Icons.my_location, onTap: () {}, tooltip: 'Recenter'),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: GpsStatusBanner(
                        status: state.gpsStatus,
                        onTapGpsOff: () => _showGpsOffDialog(context),
                        onTapPermission: () => _showPermissionDialog(context),
                      ),
                    ),
                    const Center(child: _GpsDot()),
                    const Positioned(bottom: 60, left: 60, child: _MarkerDot(color: AppColors.success)),
                    if (state.hasRoute)
                      const Positioned(top: 30, right: 80, child: _MarkerDot(color: AppColors.error)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _VoiceCuesCard(state: state),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: _StartRunButton(gpsStatus: state.gpsStatus),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Center(
                child: Text('Setup is locked once the run starts',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textMutedOf(context))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSearch(BuildContext context, WidgetRef ref, bool isOffline) async {
    final result = await Navigator.of(context).push<LocationResult>(
      MaterialPageRoute(builder: (_) => LocationSearchScreen(isOffline: isOffline)),
    );
    if (result != null) {
      ref.read(preRunProvider.notifier).setDestination(result);
    }
  }

  void _showGpsOffDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('GPS is off'),
        content: const Text('Please enable GPS in your device settings to track your run.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Open Settings')),
        ],
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Location permission'),
        content: const Text('IndiRun needs location access to track your runs.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Open Settings')),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Start Run button
// ---------------------------------------------------------------------------

class _StartRunButton extends ConsumerWidget {
  const _StartRunButton({required this.gpsStatus});
  final GpsStatus gpsStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = gpsStatus.isBlocked;
    final needsConfirm = gpsStatus.needsConfirmation;
    final preRunState = ref.watch(preRunProvider);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: blocked
            ? null
            : () async {
                if (needsConfirm) {
                  final ok = await _confirmWeakGps(context);
                  if (!ok) return;
                }
                if (context.mounted) {
                  ref.read(activeRunProvider.notifier).startRun(voiceOn: preRunState.voiceEnabled);
                  context.go(AppRoutes.countdown);
                }
              },
        style: FilledButton.styleFrom(
          backgroundColor: blocked ? AppColors.outlineLight : AppColors.primary,
          shape: const StadiumBorder(),
        ),
        icon: Icon(Icons.play_arrow_rounded,
            color: blocked ? AppColors.textSecondaryLight : Colors.white, size: 22),
        label: Text(
          blocked ? _blockedLabel : 'Start Run',
          style: TextStyle(
            color: blocked ? AppColors.textSecondaryLight : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String get _blockedLabel {
    return switch (gpsStatus) {
      GpsStatus.searching => 'Start disabled',
      GpsStatus.gpsOff || GpsStatus.permissionDenied => 'Start blocked',
      _ => 'Start disabled',
    };
  }

  Future<bool> _confirmWeakGps(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Weak GPS signal'),
            content: const Text('GPS signal is weak. Tracking may be less accurate. Start anyway?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Start anyway')),
            ],
          ),
        ) ??
        false;
  }
}

// ---------------------------------------------------------------------------
// Voice cues card
// ---------------------------------------------------------------------------

class _VoiceCuesCard extends ConsumerWidget {
  const _VoiceCuesCard({required this.state});
  final PreRunState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Voice-cues',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      state.hasRoute
                          ? (state.voiceEnabled ? 'Left / right prompts in earphones' : 'Tap to enable')
                          : 'Pick a route to enable',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textMutedOf(context)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: state.voiceEnabled,
                onChanged: state.hasRoute
                    ? (v) => ref.read(preRunProvider.notifier).setVoiceEnabled(v)
                    : null,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
          if (state.voiceEnabled && state.hasRoute) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.successContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: AppColors.success, size: 8),
                      const SizedBox(width: 6),
                      const Text('TWS connected',
                          style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.outline),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: const Text('Test voice', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _RouteLabel extends StatelessWidget {
  const _RouteLabel(this.label, this.value, {this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall,
        children: [
          TextSpan(text: label, style: const TextStyle(color: AppColors.textSecondary)),
          const TextSpan(text: ' '),
          TextSpan(
            text: value,
            style: TextStyle(
              color: highlight ? AppColors.primary : AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.destination,
    required this.isOffline,
    required this.onTap,
    required this.onClear,
  });
  final LocationResult? destination;
  final bool isOffline;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDestination = destination != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.circle_outlined, color: AppColors.textSecondary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasDestination ? destination!.name : 'Search by location',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: hasDestination ? AppColors.text : AppColors.textSecondary,
                  fontWeight: hasDestination ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasDestination)
              GestureDetector(
                onTap: onClear,
                child: const Padding(padding: EdgeInsets.all(8),
                    child: Icon(Icons.close, size: 16, color: AppColors.textSecondary)),
              )
            else
              const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF3A5040) : AppColors.mapLand;
    final lineColor = isDark ? const Color(0xFF2A3C30) : AppColors.mapRoad;
    return Container(
      width: double.infinity,
      color: bgColor,
      child: CustomPaint(painter: _GridPainter(lineColor), child: const SizedBox.expand()),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter(this.lineColor);
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = lineColor.withValues(alpha: 0.5)..strokeWidth = 1;
    const cw = 90.0;
    const ch = 80.0;
    for (double x = 0; x < size.width; x += cw) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += ch) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _RoutePolyline extends StatelessWidget {
  const _RoutePolyline();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _RoutePainter(), child: const SizedBox.expand());
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.routeAccent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final pts = [
      Offset(size.width * 0.15, size.height * 0.75),
      Offset(size.width * 0.3, size.height * 0.55),
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.7, size.height * 0.28),
      Offset(size.width * 0.85, size.height * 0.18),
    ];
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) { path.lineTo(pts[i].dx, pts[i].dy); }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _MapFab extends StatelessWidget {
  const _MapFab({required this.icon, required this.onTap, required this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)],
          ),
          child: Icon(icon, size: 18, color: AppColors.text),
        ),
      ),
    );
  }
}

class _GpsDot extends StatelessWidget {
  const _GpsDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.gpsDot,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: AppColors.gpsDotOuter.withValues(alpha: 0.6), blurRadius: 12)],
      ),
    );
  }
}

class _MarkerDot extends StatelessWidget {
  const _MarkerDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
