import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/run_model.dart';
import '../../../core/services/audio_cue_service.dart';
import '../../../core/services/location_tracking_service.dart';
import '../../../core/services/screen_service.dart';
import '../../../core/services/tracking_notification_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// Tracks the live run state during an active session.
class ActiveRunState {
  const ActiveRunState({
    this.isActive = false,
    this.isPaused = false,
    this.distanceKm = 0.0,
    this.durationSeconds = 0,
    this.currentPaceSec = 0,
    this.avgPaceSec = 0,
    this.voiceOn = false,
    this.routePoints = const [],
    this.gpsStatus = GpsStatus.searching,
    this.currentLat,
    this.currentLng,
    this.permissionDenied = false,
  });

  final bool isActive;
  final bool isPaused;
  final double distanceKm;
  final int durationSeconds;
  final int currentPaceSec;
  final int avgPaceSec;
  final bool voiceOn;
  final List<Map<String, double>> routePoints;
  final GpsStatus gpsStatus;
  final double? currentLat;
  final double? currentLng;
  final bool permissionDenied;

  /// True if the run is too short to be saved (< 0.1 km and < 60 s)
  bool get isTooShort => distanceKm < 0.1 && durationSeconds < 60;

  String get durationFormatted {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get paceFormatted {
    if (currentPaceSec == 0) return '--:--';
    final m = currentPaceSec ~/ 60;
    final s = currentPaceSec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get avgPaceFormatted {
    if (avgPaceSec == 0) return '--:--';
    final m = avgPaceSec ~/ 60;
    final s = avgPaceSec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get distanceFormatted => distanceKm.toStringAsFixed(2);

  ActiveRunState copyWith({
    bool? isActive,
    bool? isPaused,
    double? distanceKm,
    int? durationSeconds,
    int? currentPaceSec,
    int? avgPaceSec,
    bool? voiceOn,
    List<Map<String, double>>? routePoints,
    GpsStatus? gpsStatus,
    double? currentLat,
    double? currentLng,
    bool? permissionDenied,
  }) {
    return ActiveRunState(
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      distanceKm: distanceKm ?? this.distanceKm,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      currentPaceSec: currentPaceSec ?? this.currentPaceSec,
      avgPaceSec: avgPaceSec ?? this.avgPaceSec,
      voiceOn: voiceOn ?? this.voiceOn,
      routePoints: routePoints ?? this.routePoints,
      gpsStatus: gpsStatus ?? this.gpsStatus,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Notifier for the active run session.
///
/// Integrates:
/// - [LocationTrackingService] — real GPS, Haversine distance, rolling pace
/// - [ScreenService] — wake-lock so the screen stays on
/// - [TrackingNotificationService] — foreground notification with live metrics
/// - [AudioCueService] — haptic + voice cues
class ActiveRunNotifier extends Notifier<ActiveRunState> {
  LocationTrackingService? _tracker;
  StreamSubscription<TrackingUpdate>? _trackingSub;

  @override
  ActiveRunState build() => const ActiveRunState();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Called from CountdownScreen when countdown reaches GO.
  Future<void> startRun({bool voiceOn = false}) async {
    state = ActiveRunState(isActive: true, voiceOn: voiceOn);

    // Wake lock — screen must stay on
    await ScreenService.instance.keepOn();

    // Foreground notification
    await TrackingNotificationService.instance.startForegroundService(
      time: '00:00',
      distance: '0.00 km',
    );

    // Start GPS tracker
    _tracker = LocationTrackingService();
    final ok = await _tracker!.start();
    if (!ok) {
      state = state.copyWith(permissionDenied: true);
      return;
    }

    // Voice cue
    if (voiceOn) {
      await AudioCueService.instance.announce(
        'Run started. Good luck!',
        voiceEnabled: true,
      );
    }

    // Subscribe to updates
    _trackingSub = _tracker!.updates.listen(_onUpdate);
  }

  void _onUpdate(TrackingUpdate update) {
    if (!state.isActive || state.isPaused) return;

    final pts = update.currentSample != null
        ? [
            ...state.routePoints,
            {
              'lat': update.currentSample!.lat,
              'lng': update.currentSample!.lng,
            }
          ]
        : state.routePoints;

    state = state.copyWith(
      distanceKm: update.distanceKm,
      durationSeconds: update.elapsedSeconds,
      currentPaceSec: update.currentPaceSec,
      avgPaceSec: update.avgPaceSec,
      routePoints: pts,
      gpsStatus: update.gpsStatus,
      currentLat: update.currentSample?.lat,
      currentLng: update.currentSample?.lng,
    );

    // Update foreground notification every 5 seconds
    if (update.elapsedSeconds % 5 == 0) {
      TrackingNotificationService.instance.updateNotification(
        time: state.durationFormatted,
        distance: '${state.distanceFormatted} km',
        isPaused: false,
      );
    }

    // Kilometre milestone voice cue
    if (state.voiceOn) {
      final prevKm = (update.distanceKm - 0.001).floor();
      final currKm = update.distanceKm.floor();
      if (currKm > prevKm && currKm > 0) {
        AudioCueService.instance.announce(
          '$currKm kilometre. Pace: ${state.avgPaceFormatted} per km.',
          voiceEnabled: true,
        );
      }
    }
  }

  void pauseRun() {
    if (!state.isActive || state.isPaused) return;
    _tracker?.pause();
    state = state.copyWith(isPaused: true);
    ScreenService.instance.allowSleep();
    TrackingNotificationService.instance.updateNotification(
      time: state.durationFormatted,
      distance: '${state.distanceFormatted} km',
      isPaused: true,
    );
    if (state.voiceOn) {
      AudioCueService.instance
          .announce('Run paused.', voiceEnabled: true);
    }
  }

  void resumeRun() {
    if (!state.isActive || !state.isPaused) return;
    _tracker?.resume();
    state = state.copyWith(isPaused: false);
    ScreenService.instance.keepOn();
    TrackingNotificationService.instance.updateNotification(
      time: state.durationFormatted,
      distance: '${state.distanceFormatted} km',
      isPaused: false,
    );
    if (state.voiceOn) {
      AudioCueService.instance
          .announce('Run resumed.', voiceEnabled: true);
    }
  }

  Future<void> endRun() async {
    await _trackingSub?.cancel();
    _trackingSub = null;
    await _tracker?.stop();
    _tracker = null;
    await ScreenService.instance.allowSleep();
    await TrackingNotificationService.instance.stopForegroundService();
    state = const ActiveRunState();
  }

  // ── Legacy tick helper (kept for backward-compat / tests) ─────────────────
  void tick(int seconds, double km, int paceSec, int avgPaceSec) {
    if (!state.isActive || state.isPaused) return;
    state = state.copyWith(
      durationSeconds: seconds,
      distanceKm: km,
      currentPaceSec: paceSec,
      avgPaceSec: avgPaceSec,
    );
  }

  void addPoint(double lat, double lng) {
    final pts = [...state.routePoints, {'lat': lat, 'lng': lng}];
    state = state.copyWith(routePoints: pts);
  }
}

final activeRunProvider =
    NotifierProvider<ActiveRunNotifier, ActiveRunState>(ActiveRunNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Run history controller
// ─────────────────────────────────────────────────────────────────────────────

class RunController extends AsyncNotifier<List<RunModel>> {
  // In-memory store – replace with repository calls in M4
  final List<RunModel> _runs = [];

  @override
  Future<List<RunModel>> build() async {
    // Seed with sample data so the Home screen shows the returning-user UI
    if (_runs.isEmpty) {
      final now = DateTime.now();
      _runs.addAll([
        RunModel(
          id: 'run-1',
          startedAt: now.subtract(const Duration(days: 5, hours: 1)),
          endedAt: now.subtract(const Duration(days: 5)),
          distanceKm: 5.02,
          durationSeconds: 29 * 60 + 40,
          routePoints: [],
          label: 'Tue, 29 Sep',
          avgPaceSec: 5 * 60 + 55,
          elevGainM: 12,
          isSynced: true,
        ),
        RunModel(
          id: 'run-2',
          startedAt: now.subtract(const Duration(days: 7, hours: 1)),
          endedAt: now.subtract(const Duration(days: 7)),
          distanceKm: 7.10,
          durationSeconds: 41 * 60 + 12,
          routePoints: [],
          label: 'Sun, 27 Sep',
          avgPaceSec: 5 * 60 + 48,
          isSynced: true,
        ),
        RunModel(
          id: 'run-3',
          startedAt: now.subtract(const Duration(days: 9, hours: 1)),
          endedAt: now.subtract(const Duration(days: 9)),
          distanceKm: 3.21,
          durationSeconds: 19 * 60 + 2,
          routePoints: [],
          label: 'Fri, 25 Sep',
          avgPaceSec: 5 * 60 + 56,
          isSynced: true,
        ),
        RunModel(
          id: 'run-4',
          startedAt: now.subtract(const Duration(days: 11, hours: 1)),
          endedAt: now.subtract(const Duration(days: 11)),
          distanceKm: 6.00,
          durationSeconds: 35 * 60 + 10,
          routePoints: [],
          label: 'Wed, 23 Sep',
          avgPaceSec: 5 * 60 + 51,
          isSynced: true,
        ),
      ]);
    }
    return List.unmodifiable(_runs);
  }

  Future<void> saveRun(RunModel run) async {
    _runs.insert(0, run);
    state = AsyncData(List.unmodifiable(_runs));
  }

  Future<void> deleteRun(String id) async {
    _runs.removeWhere((r) => r.id == id);
    state = AsyncData(List.unmodifiable(_runs));
  }

  RunModel? getById(String id) {
    try {
      return _runs.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}

final runControllerProvider =
    AsyncNotifierProvider<RunController, List<RunModel>>(RunController.new);
