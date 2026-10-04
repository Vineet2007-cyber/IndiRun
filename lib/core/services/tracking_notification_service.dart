import 'package:flutter/foundation.dart';

/// Data class representing the foreground notification state for an active run.
class TrackingNotificationState {
  const TrackingNotificationState({
    required this.isRunning,
    required this.isPaused,
    required this.formattedTime,
    required this.formattedDistance,
  });

  final bool isRunning;
  final bool isPaused;
  final String formattedTime;
  final String formattedDistance;

  String get title => isPaused ? 'IndiRun • Paused' : 'IndiRun • Tracking Run';
  String get content => '$formattedDistance • $formattedTime';
  String get actionLabel => isPaused ? 'Resume' : 'Pause';
}

/// Manages the foreground notification displaying elapsed moving time, distance,
/// and Pause/Resume action controls so run tracking continues seamlessly when
/// the screen is locked.
class TrackingNotificationService {
  TrackingNotificationService._();
  static final TrackingNotificationService instance = TrackingNotificationService._();

  TrackingNotificationState? _currentState;
  TrackingNotificationState? get currentState => _currentState;

  bool _isForegroundActive = false;
  bool get isForegroundActive => _isForegroundActive;

  /// Starts the foreground service and initial notification.
  Future<void> startForegroundService({
    required String time,
    required String distance,
    bool isPaused = false,
  }) async {
    _isForegroundActive = true;
    updateNotification(
      time: time,
      distance: distance,
      isPaused: isPaused,
    );
  }

  /// Updates the running foreground notification with new time & distance metrics.
  void updateNotification({
    required String time,
    required String distance,
    required bool isPaused,
  }) {
    if (!_isForegroundActive) return;
    _currentState = TrackingNotificationState(
      isRunning: !isPaused,
      isPaused: isPaused,
      formattedTime: time,
      formattedDistance: distance,
    );
    debugPrint('ForegroundNotification: ${_currentState?.title} - ${_currentState?.content} [${_currentState?.actionLabel}]');
  }

  /// Stops the foreground service when the run ends.
  Future<void> stopForegroundService() async {
    _isForegroundActive = false;
    _currentState = null;
    debugPrint('ForegroundNotification: Stopped');
  }
}
