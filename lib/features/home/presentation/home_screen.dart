import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../auth/application/auth_controller.dart';
import '../../profile/application/profile_controller.dart';
import '../../run/application/run_controller.dart';
import '../../run/domain/run_model.dart';

/// S07 Home (returning user) / S08 Home (new user)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final profileAsync = ref.watch(profileControllerProvider);
    final runAsync = ref.watch(runControllerProvider);
    final activeRun = ref.watch(activeRunProvider);

    final username =
        profileAsync.value?.displayName ?? authState.user?.displayName ?? 'Runner';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'R';

    final runs = runAsync.value ?? [];

    // This-week filter (Mon–Sun)
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartMidnight =
        DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekRuns =
        runs.where((r) => r.startedAt.isAfter(weekStartMidnight)).toList();
    final hasRuns = runs.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasRuns ? 'Hi, $username' : 'Welcome, $username',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textOf(context),
                          ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.profile),
                    child: _AvatarBubble(initial: initial),
                  ),
                ],
              ),
            ),

            // ── Unfinished-run recovery banner ───────────────────────────────
            if (activeRun.isActive)
              _RecoveryBanner(
                onResume: () => context.go(AppRoutes.activeRun),
              ),

            // ── Scrollable body ───────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => ref.refresh(runControllerProvider.future),
                child: runAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _ErrorBody(error: e.toString()),
                  data: (_) => hasRuns
                      ? _ReturningUserBody(
                          allRuns: runs, weekRuns: weekRuns)
                      : const _NewUserBody(),
                ),
              ),
            ),

            // ── Bottom CTA(s) ─────────────────────────────────────────────────
            _BottomActions(hasRuns: hasRuns),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar bubble
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarBubble extends StatelessWidget {
  const _AvatarBubble({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Unfinished-run recovery banner
// ─────────────────────────────────────────────────────────────────────────────

class _RecoveryBanner extends StatelessWidget {
  const _RecoveryBanner({required this.onResume});
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Material(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onResume,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You have an unfinished run. Tap to continue.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.warning, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Returning user body
// ─────────────────────────────────────────────────────────────────────────────

class _ReturningUserBody extends StatelessWidget {
  const _ReturningUserBody({
    required this.allRuns,
    required this.weekRuns,
  });

  final List<RunModel> allRuns;
  final List<RunModel> weekRuns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double weekKm =
        weekRuns.fold(0.0, (s, r) => s + r.distanceKm);
    final int weekRunCount = weekRuns.length;
    final int weekSecs = weekRuns.fold(0, (s, r) => s + r.durationSeconds);
    final totalH = weekSecs ~/ 3600;
    final totalM = (weekSecs % 3600) ~/ 60;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      children: [
        _WeekSummaryChip(
          km: weekKm,
          runCount: weekRunCount,
          totalH: totalH,
          totalM: totalM,
        ),
        const SizedBox(height: 16),
        Text(
          'Past runs',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...allRuns.map((run) => _RunCard(run: run)),
      ],
    );
  }
}

class _WeekSummaryChip extends StatelessWidget {
  const _WeekSummaryChip({
    required this.km,
    required this.runCount,
    required this.totalH,
    required this.totalM,
  });
  final double km;
  final int runCount;
  final int totalH;
  final int totalM;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            'This week',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${km.toStringAsFixed(1)} km  •  '
              '$runCount ${runCount == 1 ? 'run' : 'runs'}  •  '
              '${totalH}h ${totalM.toString().padLeft(2, '0')}m',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RunCard extends StatelessWidget {
  const _RunCard({required this.run});
  final RunModel run;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final km = run.distanceKm.toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push(AppRoutes.runDetailPath(run.id)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.mapLand,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.routeAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        run.label ?? run.dateLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMutedOf(context),
                        ),
                      ),
                      Text(
                        '$km km',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      run.durationFormatted,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${run.avgPaceFormatted} /km',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMutedOf(context),
                      ),
                    ),
                    if (run.isSynced)
                      Text(
                        'Synced',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// New user empty state
// ─────────────────────────────────────────────────────────────────────────────

class _NewUserBody extends StatelessWidget {
  const _NewUserBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.primary,
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No runs yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOf(context),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your first run is one tap away.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMutedOf(context),
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error body
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              'Could not load runs',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom actions
// ─────────────────────────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.hasRuns});
  final bool hasRuns;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => context.push(AppRoutes.preRun),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 22),
              label: Text(
                'Start Run',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (hasRuns) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.push(AppRoutes.history),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.outlineOf(context)),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'All history',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
