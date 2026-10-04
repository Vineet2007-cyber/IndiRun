import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// A GPS sample captured during a run.
class GpsSample {
  const GpsSample({
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.accuracy = 0.0,
    this.speedMps = 0.0,
  });

  final double lat;
  final double lng;
  final DateTime timestamp;
  final double accuracy; // metres
  final double speedMps;
}

/// GPS accuracy / fix quality reported to the UI.
enum GpsStatus { searching, poor, good, excellent }

/// Result emitted on every location update tick.
class TrackingUpdate {
  const TrackingUpdate({
    required this.distanceKm,
    required this.elapsedSeconds,
    required this.currentPaceSec,
    required this.avgPaceSec,
    required this.samples,
    required this.gpsStatus,
    this.currentSample,
  });

  final double distanceKm;
  final int elapsedSeconds;
  final int currentPaceSec; // rolling ~10 s window; 0 = insufficient data
  final int avgPaceSec; // total distance / total time
  final List<GpsSample> samples;
  final GpsStatus gpsStatus;
  final GpsSample? currentSample;
}

/// Encapsulates the GPS stream and all distance / pace calculations for a run.
///
/// One instance per active run session.  Call [start] when the run begins and
/// [stop] when it ends.  All data stays local — no network calls.
class LocationTrackingService {
  LocationTrackingService();

  StreamSubscription<Position>? _sub;
  final List<GpsSample> _samples = [];
  double _totalDistanceKm = 0.0;
  int _elapsedSeconds = 0;
  Timer? _ticker;
  bool _running = false;

  final _controller = StreamController<TrackingUpdate>.broadcast();

  /// Stream of tracking updates, emitted every second.
  Stream<TrackingUpdate> get updates => _controller.stream;

  bool get isRunning => _running;

  /// Request location permissions and start tracking.
  /// Returns true on success, false if permission denied.
  Future<bool> start() async {
    if (_running) return true;

    // ── Permission check ────────────────────────────────────────────────────
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return false;
    }

    _running = true;

    // ── Location stream ─────────────────────────────────────────────────────
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 3, // metres – suppress micro-jitter
    );

    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
      _onPosition,
      onError: (e) => debugPrint('LocationTrackingService stream error: $e'),
    );

    // ── 1-second elapsed ticker ─────────────────────────────────────────────
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      _emitUpdate();
    });

    return true;
  }

  /// Pause tracking (timer stops, GPS stream continues for position updates).
  void pause() {
    _running = false;
    _ticker?.cancel();
  }

  /// Resume from a paused state.
  void resume() {
    if (_running) return;
    _running = true;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      _emitUpdate();
    });
  }

  /// Stop tracking and release all resources.
  Future<void> stop() async {
    _running = false;
    _ticker?.cancel();
    await _sub?.cancel();
    _sub = null;
  }

  /// Dispose the stream controller.
  void dispose() {
    stop();
    _controller.close();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _onPosition(Position pos) {
    final sample = GpsSample(
      lat: pos.latitude,
      lng: pos.longitude,
      timestamp: pos.timestamp,
      accuracy: pos.accuracy,
      speedMps: pos.speed,
    );

    if (_samples.isNotEmpty && _running) {
      // Only count distance when accuracy is reasonable (< 30 m)
      if (pos.accuracy <= 30) {
        final prev = _samples.last;
        final d = _haversineKm(prev.lat, prev.lng, sample.lat, sample.lng);
        // Sanity-cap: ignore jumps > 0.1 km per update (GPS glitch)
        if (d < 0.1) {
          _totalDistanceKm += d;
        }
      }
    }
    _samples.add(sample);
  }

  void _emitUpdate() {
    if (_controller.isClosed) return;
    _controller.add(
      TrackingUpdate(
        distanceKm: _totalDistanceKm,
        elapsedSeconds: _elapsedSeconds,
        currentPaceSec: _rollingPaceSec(),
        avgPaceSec: _avgPaceSec(),
        samples: List.unmodifiable(_samples),
        gpsStatus: _gpsStatus(),
        currentSample: _samples.isNotEmpty ? _samples.last : null,
      ),
    );
  }

  /// Rolling ~10-second pace window based on last N samples with timestamps.
  int _rollingPaceSec() {
    if (_samples.length < 2) return 0;
    final now = _samples.last.timestamp;
    final windowStart = now.subtract(const Duration(seconds: 10));
    final window = _samples
        .where((s) => s.timestamp.isAfter(windowStart))
        .toList();
    if (window.length < 2) return 0;
    double dist = 0;
    for (int i = 1; i < window.length; i++) {
      dist += _haversineKm(
        window[i - 1].lat,
        window[i - 1].lng,
        window[i].lat,
        window[i].lng,
      );
    }
    if (dist == 0) return 0;
    final secs = window.last.timestamp
        .difference(window.first.timestamp)
        .inSeconds;
    if (secs == 0) return 0;
    return (secs / dist).round(); // seconds per km
  }

  int _avgPaceSec() {
    if (_totalDistanceKm == 0 || _elapsedSeconds == 0) return 0;
    return (_elapsedSeconds / _totalDistanceKm).round();
  }

  GpsStatus _gpsStatus() {
    if (_samples.isEmpty) return GpsStatus.searching;
    final acc = _samples.last.accuracy;
    if (acc <= 5) return GpsStatus.excellent;
    if (acc <= 15) return GpsStatus.good;
    if (acc <= 30) return GpsStatus.poor;
    return GpsStatus.searching;
  }

  /// Haversine great-circle distance in kilometres.
  static double _haversineKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const r = 6371.0; // Earth radius km
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double deg) => deg * math.pi / 180;
}
