import 'package:intl/intl.dart';

abstract final class Formatters {
  /// Formats distance in meters to kilometers string (e.g., "5.24 km" or "0.45 km").
  static String formatDistanceKm(double distanceInMeters, {bool includeUnit = true}) {
    if (distanceInMeters.isNaN || distanceInMeters.isInfinite || distanceInMeters < 0) {
      return includeUnit ? '0.00 km' : '0.00';
    }
    final km = distanceInMeters / 1000.0;
    final formatted = km.toStringAsFixed(2);
    return includeUnit ? '$formatted km' : formatted;
  }

  /// Formats a duration into standard running display:
  /// - Under 1 hour: "mm:ss" (e.g. "05:24", "45:10")
  /// - 1 hour or more: "h:mm:ss" (e.g. "1:05:24")
  static String formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '00:00';
    }
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$hours:$minutesStr:$secondsStr';
    }
    return '$minutesStr:$secondsStr';
  }

  /// Formats speed in meters per second into running pace (min:sec per km).
  /// E.g. 3.0 m/s -> 333.3 sec/km -> "5:33 /km"
  /// If speed is too slow (< 0.2 m/s), stationary, or invalid, returns "--:-- /km".
  static String formatPace(double metersPerSecond, {bool includeUnit = true}) {
    final unitSuffix = includeUnit ? ' /km' : '';
    if (metersPerSecond.isNaN || metersPerSecond.isInfinite || metersPerSecond < 0.2) {
      return '--:--$unitSuffix';
    }

    // seconds per km = 1000 / m_per_s
    final secondsPerKm = (1000.0 / metersPerSecond).round();

    // Cap at 59:59 to prevent absurd numbers when near standstill
    if (secondsPerKm > 3599) {
      return '--:--$unitSuffix';
    }

    final minutes = secondsPerKm ~/ 60;
    final seconds = secondsPerKm % 60;
    final formatted = '$minutes:${seconds.toString().padLeft(2, '0')}';
    return '$formatted$unitSuffix';
  }

  /// Formats date into readable string, e.g. "26 Sep 2026, 06:30 AM"
  static String formatDateTime(DateTime dateTime, {String? locale}) {
    return DateFormat('d MMM y, hh:mm a', locale).format(dateTime);
  }
}
