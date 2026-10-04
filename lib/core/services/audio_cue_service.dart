import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Audio and voice cue service for countdown beeps and run announcements.
class AudioCueService {
  AudioCueService._();
  static final AudioCueService instance = AudioCueService._();

  /// Plays a countdown tick sound / haptic.
  Future<void> playCountdownTick(int count, {required bool voiceEnabled}) async {
    // Trigger haptic feedback
    if (count > 0) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.heavyImpact();
    }

    if (!voiceEnabled) return;

    try {
      if (count > 0) {
        // System sound click/alert
        SystemSound.play(SystemSoundType.click);
      } else {
        // GO sound
        SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      debugPrint('AudioCueService error: $e');
    }
  }

  /// Announces run paused / resumed / milestone.
  Future<void> announce(String message, {required bool voiceEnabled}) async {
    if (!voiceEnabled) return;
    debugPrint('VoiceCue announcement: "$message"');
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }
}
