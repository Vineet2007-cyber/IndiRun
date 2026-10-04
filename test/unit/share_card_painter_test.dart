import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indirun/features/share/presentation/share_card_painter.dart';

void main() {
  group('ShareCardData formatting', () {
    final started = DateTime(2026, 10, 4, 7, 15);
    final data = ShareCardData(
      distanceKm: 5.02,
      durationSeconds: 29 * 60 + 40, // 29:40
      avgPaceSec: 5 * 60 + 55, // 5:55
      startedAt: started,
      username: 'vineet',
      elevGainM: 42.0,
      voiceOn: true,
      routePoints: const [
        {'lat': 19.0760, 'lng': 72.8777},
        {'lat': 19.0765, 'lng': 72.8780},
        {'lat': 19.0770, 'lng': 72.8785},
        {'lat': 19.0775, 'lng': 72.8790},
        {'lat': 19.0780, 'lng': 72.8795},
      ],
    );

    test('formats distance correctly', () {
      expect(data.distanceFormatted, '5.02');
    });

    test('formats duration correctly', () {
      expect(data.durationFormatted, '29:40');
    });

    test('formats pace correctly', () {
      expect(data.paceFormatted, '5:55');
    });

    test('formats zero pace as placeholder', () {
      final zeroPace = ShareCardData(
        distanceKm: 0,
        durationSeconds: 0,
        avgPaceSec: 0,
        startedAt: started,
        username: 'runner',
      );
      expect(zeroPace.paceFormatted, '--:--');
    });

    test('formats date label correctly', () {
      expect(data.dateLabel, contains('Oct'));
      expect(data.dateLabel, contains('2026'));
    });

    test('formats time label correctly', () {
      expect(data.timeLabel, '07:15 AM');
    });

    test('formats elevation gain label correctly', () {
      expect(data.elevLabel, '42 m');
    });
  });

  group('ShareTemplate dimensions & aspect ratios', () {
    test('T1 Classic is 1080x1080 (1:1)', () {
      expect(ShareTemplate.classic.canvasSize, const Size(1080, 1080));
      expect(ShareTemplate.classic.aspectRatioLabel, '1:1');
    });

    test('T2 Route Focus is 1080x1350 (4:5)', () {
      expect(ShareTemplate.routeFocus.canvasSize, const Size(1080, 1350));
      expect(ShareTemplate.routeFocus.aspectRatioLabel, '4:5');
    });

    test('T3 Stats Focus is 1080x1350 (4:5)', () {
      expect(ShareTemplate.statsFocus.canvasSize, const Size(1080, 1350));
      expect(ShareTemplate.statsFocus.aspectRatioLabel, '4:5');
    });

    test('T4 Story is 1080x1920 (9:16)', () {
      expect(ShareTemplate.story.canvasSize, const Size(1080, 1920));
      expect(ShareTemplate.story.aspectRatioLabel, '9:16');
    });
  });

  group('renderShareCard', () {
    testWidgets('renders all 4 templates to PNG bytes without crashing', (tester) async {
      await tester.runAsync(() async {
        final data = ShareCardData(
          distanceKm: 5.02,
          durationSeconds: 1780,
          avgPaceSec: 355,
          startedAt: DateTime(2026, 10, 4, 7, 0),
          username: 'runner',
          elevGainM: 35,
          blurEnds: true,
          routePoints: const [
            {'lat': 19.0760, 'lng': 72.8777},
            {'lat': 19.0780, 'lng': 72.8790},
            {'lat': 19.0800, 'lng': 72.8800},
          ],
        );

        for (final template in ShareTemplate.values) {
          final painter = template.painter(data);
          final bytes = await renderShareCard(
            painter: painter,
            size: template.canvasSize,
          );
          expect(bytes, isNotNull);
          expect(bytes.isNotEmpty, isTrue);
        }
      });
    });

    testWidgets('renders template without blurEnds without crashing', (tester) async {
      await tester.runAsync(() async {
        final data = ShareCardData(
          distanceKm: 2.5,
          durationSeconds: 900,
          avgPaceSec: 360,
          startedAt: DateTime.now(),
          username: 'runner',
          blurEnds: false,
          routePoints: const [
            {'lat': 19.0760, 'lng': 72.8777},
            {'lat': 19.0780, 'lng': 72.8790},
          ],
        );

        final bytes = await renderShareCard(
          painter: ShareTemplate.classic.painter(data),
          size: ShareTemplate.classic.canvasSize,
        );
        expect(bytes, isNotNull);
        expect(bytes.isNotEmpty, isTrue);
      });
    });
  });
}
