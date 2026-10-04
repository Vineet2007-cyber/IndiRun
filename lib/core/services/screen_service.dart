import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Service to keep the screen awake during an active run session.
///
/// Backed by `wakelock_plus` so the screen stays on even when the user
/// glances at their wrist. Called by [ActiveRunNotifier] on start/pause/end.
class ScreenService {
  ScreenService._();
  static final ScreenService instance = ScreenService._();

  bool _isKeptAwake = false;
  bool get isKeptAwake => _isKeptAwake;

  /// Request the screen to stay on while tracking.
  Future<void> keepOn() async {
    if (_isKeptAwake) return;
    try {
      await WakelockPlus.enable();
      _isKeptAwake = true;
    } catch (e) {
      debugPrint('ScreenService.keepOn error: $e');
    }
  }

  /// Allow the screen to sleep normally when run is paused or ended.
  Future<void> allowSleep() async {
    if (!_isKeptAwake) return;
    try {
      await WakelockPlus.disable();
      _isKeptAwake = false;
    } catch (e) {
      debugPrint('ScreenService.allowSleep error: $e');
    }
  }
}
