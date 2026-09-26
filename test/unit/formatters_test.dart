import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/core/utils/formatters.dart';

void main() {
  group('Formatters - Distance', () {
    test('formats standard distances in kilometers', () {
      expect(Formatters.formatDistanceKm(0), '0.00 km');
      expect(Formatters.formatDistanceKm(450), '0.45 km');
      expect(Formatters.formatDistanceKm(1000), '1.00 km');
      expect(Formatters.formatDistanceKm(5240), '5.24 km');
      expect(Formatters.formatDistanceKm(10000), '10.00 km');
      expect(Formatters.formatDistanceKm(42195), '42.20 km');
    });

    test('supports formatting without unit', () {
      expect(Formatters.formatDistanceKm(5240, includeUnit: false), '5.24');
    });

    test('safely handles negative, NaN, and infinity', () {
      expect(Formatters.formatDistanceKm(-100), '0.00 km');
      expect(Formatters.formatDistanceKm(double.nan), '0.00 km');
      expect(Formatters.formatDistanceKm(double.infinity), '0.00 km');
    });
  });

  group('Formatters - Duration', () {
    test('formats durations under 1 hour in mm:ss', () {
      expect(Formatters.formatDuration(Duration.zero), '00:00');
      expect(Formatters.formatDuration(const Duration(seconds: 45)), '00:45');
      expect(Formatters.formatDuration(const Duration(minutes: 5, seconds: 24)), '05:24');
      expect(Formatters.formatDuration(const Duration(minutes: 59, seconds: 59)), '59:59');
    });

    test('formats durations of 1 hour or more in h:mm:ss', () {
      expect(Formatters.formatDuration(const Duration(hours: 1, seconds: 5)), '1:00:05');
      expect(Formatters.formatDuration(const Duration(hours: 1, minutes: 25, seconds: 30)), '1:25:30');
      expect(Formatters.formatDuration(const Duration(hours: 3, minutes: 45, seconds: 12)), '3:45:12');
    });

    test('safely handles negative duration', () {
      expect(Formatters.formatDuration(const Duration(seconds: -10)), '00:00');
    });
  });

  group('Formatters - Pace', () {
    test('formats valid running speeds to pace min/km', () {
      // 3.333 m/s = 12 km/h -> 300 sec/km -> 5:00 /km
      expect(Formatters.formatPace(3.333333), '5:00 /km');
      // 2.777778 m/s = 10 km/h -> 360 sec/km -> 6:00 /km
      expect(Formatters.formatPace(2.777778), '6:00 /km');
      // 3.0 m/s -> 333.33 sec/km -> 5:33 /km
      expect(Formatters.formatPace(3.0), '5:33 /km');
    });

    test('supports formatting pace without unit', () {
      expect(Formatters.formatPace(3.333333, includeUnit: false), '5:00');
    });

    test('returns fallback for stationary or near-stationary speeds', () {
      expect(Formatters.formatPace(0.0), '--:-- /km');
      expect(Formatters.formatPace(0.1), '--:-- /km');
      expect(Formatters.formatPace(-1.0), '--:-- /km');
      expect(Formatters.formatPace(double.nan), '--:-- /km');
      expect(Formatters.formatPace(double.infinity), '--:-- /km');
    });
  });
}
