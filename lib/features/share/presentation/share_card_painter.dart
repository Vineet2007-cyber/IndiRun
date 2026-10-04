import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Run data passed to the share card renderer.
class ShareCardData {
  const ShareCardData({
    required this.distanceKm,
    required this.durationSeconds,
    required this.avgPaceSec,
    required this.startedAt,
    required this.username,
    this.elevGainM,
    this.routePoints = const [],
    this.blurEnds = true,
    this.voiceOn = false,
  });

  final double distanceKm;
  final int durationSeconds;
  final int avgPaceSec;
  final DateTime startedAt;
  final String username;
  final double? elevGainM;
  final List<Map<String, double>> routePoints;
  final bool blurEnds;
  final bool voiceOn;

  // ── Formatted helpers ───────────────────────────────────────────────────────

  String get distanceFormatted => distanceKm.toStringAsFixed(2);
  String get durationFormatted {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get paceFormatted {
    if (avgPaceSec == 0) return '--:--';
    final m = avgPaceSec ~/ 60;
    final s = avgPaceSec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get dateLabel {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[startedAt.weekday - 1]}, '
        '${startedAt.day} ${months[startedAt.month - 1]} '
        '${startedAt.year}';
  }

  String get timeLabel {
    final h = startedAt.hour;
    final m = startedAt.minute.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final hh = (h % 12 == 0 ? 12 : h % 12).toString().padLeft(2, '0');
    return '$hh:$m $ampm';
  }

  String get elevLabel {
    if (elevGainM == null) return '';
    return '${elevGainM!.round()} m';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Renderer — converts a painter to PNG bytes
// ─────────────────────────────────────────────────────────────────────────────

/// Renders a [CustomPainter] to raw PNG bytes at the given logical size
/// multiplied by the device pixel ratio.
///
/// This is deterministic: same data → same pixels.
Future<Uint8List> renderShareCard({
  required CustomPainter painter,
  required Size size,
  double pixelRatio = 1.0,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, size.width * pixelRatio, size.height * pixelRatio),
  );
  canvas.scale(pixelRatio);
  painter.paint(canvas, size);
  final picture = recorder.endRecording();
  final image = await picture.toImage(
    (size.width * pixelRatio).round(),
    (size.height * pixelRatio).round(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

// ─────────────────────────────────────────────────────────────────────────────
// Template enum
// ─────────────────────────────────────────────────────────────────────────────

enum ShareTemplate { classic, routeFocus, statsFocus, story }

extension ShareTemplateExt on ShareTemplate {
  String get label => switch (this) {
        ShareTemplate.classic => 'Classic',
        ShareTemplate.routeFocus => 'Route',
        ShareTemplate.statsFocus => 'Stats',
        ShareTemplate.story => 'Story',
      };

  /// Output canvas size in logical pixels (1px = 1px for share rendering).
  Size get canvasSize => switch (this) {
        ShareTemplate.classic => const Size(1080, 1080),
        ShareTemplate.routeFocus => const Size(1080, 1350),
        ShareTemplate.statsFocus => const Size(1080, 1350),
        ShareTemplate.story => const Size(1080, 1920),
      };

  String get aspectRatioLabel => switch (this) {
        ShareTemplate.classic => '1:1',
        ShareTemplate.routeFocus => '4:5',
        ShareTemplate.statsFocus => '4:5',
        ShareTemplate.story => '9:16',
      };

  CustomPainter painter(ShareCardData data) => switch (this) {
        ShareTemplate.classic => ClassicCardPainter(data),
        ShareTemplate.routeFocus => RouteFocusCardPainter(data),
        ShareTemplate.statsFocus => StatsFocusCardPainter(data),
        ShareTemplate.story => StoryCardPainter(data),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared drawing utilities
// ─────────────────────────────────────────────────────────────────────────────

abstract class _BaseCardPainter extends CustomPainter {
  const _BaseCardPainter(this.data);
  final ShareCardData data;

  // Primary teal brand colour (same as AppColors.primary)
  static const Color _teal = Color(0xFF006874);
  static const Color _tealLight = Color(0xFFF2FAFA);
  static const Color _ink = Color(0xFF0B2B30);
  static const Color _mutedText = Color(0xFF4F6B70);
  static const Color _routeColor = Color(0xFFC2185B);
  static const Color _startDot = Color(0xFF2E7D32);
  static const Color _endDot = Color(0xFFBA1A1A);
  static const Color _mapBg = Color(0xFFDCEBE4);

  // ── Route drawing ─────────────────────────────────────────────────────────

  /// Returns normalised route Offsets from GPS points, trimming the first/last
  /// [trimFraction] of the route when [blurEnds] is true.
  List<Offset> _buildRouteOffsets(
    List<Map<String, double>> points,
    Rect rect,
  ) {
    if (points.isEmpty) return _fallbackRoute(rect);

    double minLat = points.first['lat']!;
    double maxLat = minLat;
    double minLng = points.first['lng']!;
    double maxLng = minLng;

    for (final p in points) {
      if (p['lat']! < minLat) minLat = p['lat']!;
      if (p['lat']! > maxLat) maxLat = p['lat']!;
      if (p['lng']! < minLng) minLng = p['lng']!;
      if (p['lng']! > maxLng) maxLng = p['lng']!;
    }

    final latRange = (maxLat - minLat).abs();
    final lngRange = (maxLng - minLng).abs();
    const pad = 80.0;

    Offset toCanvas(Map<String, double> p) {
      final x = lngRange == 0
          ? rect.center.dx
          : rect.left + pad + (p['lng']! - minLng) / lngRange * (rect.width - pad * 2);
      final y = latRange == 0
          ? rect.center.dy
          : rect.bottom -
              pad -
              (p['lat']! - minLat) / latRange * (rect.height - pad * 2);
      return Offset(x, y);
    }

    return points.map(toCanvas).toList();
  }

  List<Offset> _fallbackRoute(Rect rect) {
    // Static fallback when no real GPS data
    return [
      Offset(rect.left + rect.width * 0.12, rect.top + rect.height * 0.85),
      Offset(rect.left + rect.width * 0.25, rect.top + rect.height * 0.65),
      Offset(rect.left + rect.width * 0.40, rect.top + rect.height * 0.50),
      Offset(rect.left + rect.width * 0.58, rect.top + rect.height * 0.38),
      Offset(rect.left + rect.width * 0.75, rect.top + rect.height * 0.25),
      Offset(rect.left + rect.width * 0.88, rect.top + rect.height * 0.15),
    ];
  }

  void _drawMap(Canvas canvas, Rect rect, {double routeWidth = 6.0}) {
    // Map background
    canvas.drawRect(rect, Paint()..color = _mapBg);

    // Light grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    for (double x = rect.left; x < rect.right; x += 80) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gridPaint);
    }
    for (double y = rect.top; y < rect.bottom; y += 80) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridPaint);
    }

    final offsets = _buildRouteOffsets(data.routePoints, rect);

    // Privacy trim — remove first/last ~200m equivalent points
    List<Offset> visibleOffsets = offsets;
    if (data.blurEnds && offsets.length > 6) {
      const trimCount = 2;
      visibleOffsets = offsets.sublist(
        trimCount.clamp(0, offsets.length - 2),
        (offsets.length - trimCount).clamp(2, offsets.length),
      );
    }

    // Route line
    if (visibleOffsets.length >= 2) {
      final routePaint = Paint()
        ..color = _routeColor
        ..strokeWidth = routeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(visibleOffsets.first.dx, visibleOffsets.first.dy);
      for (int i = 1; i < visibleOffsets.length; i++) {
        path.lineTo(visibleOffsets[i].dx, visibleOffsets[i].dy);
      }
      canvas.drawPath(path, routePaint);
    }

    // Start/end dots (only when not blurred)
    if (!data.blurEnds && offsets.length >= 2) {
      _drawDot(canvas, offsets.first, _startDot, radius: routeWidth * 1.5);
      _drawDot(canvas, offsets.last, _endDot, radius: routeWidth * 1.5);
    } else if (visibleOffsets.length >= 2) {
      // Show trimmed endpoints as neutral
      _drawDot(canvas, visibleOffsets.first, _teal, radius: routeWidth * 1.2);
      _drawDot(canvas, visibleOffsets.last, _teal, radius: routeWidth * 1.2);
    }
  }

  void _drawDot(Canvas canvas, Offset center, Color color,
      {double radius = 10}) {
    canvas.drawCircle(center, radius + 3, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius, Paint()..color = color);
  }

  // ── Text helpers ──────────────────────────────────────────────────────────

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y, {
    double fontSize = 40,
    Color color = const Color(0xFF0B2B30),
    FontWeight weight = FontWeight.w400,
    TextAlign align = TextAlign.left,
    double maxWidth = 1080,
  }) {
    final builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: align,
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: weight,
      ),
    )
      ..pushStyle(ui.TextStyle(color: color, fontFamily: 'Inter'))
      ..addText(text);

    final para = builder.build()
      ..layout(ui.ParagraphConstraints(width: maxWidth));

    canvas.drawParagraph(para, Offset(x, y));
  }

  /// IndiRun wordmark
  void _drawBranding(Canvas canvas, double x, double y, double fontSize) {
    _drawText(
      canvas,
      'IndiRun',
      x,
      y,
      fontSize: fontSize,
      color: _teal,
      weight: FontWeight.w800,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// T1 Classic 1080 × 1080
// ─────────────────────────────────────────────────────────────────────────────

class ClassicCardPainter extends _BaseCardPainter {
  const ClassicCardPainter(super.data);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = _BaseCardPainter._tealLight,
    );

    // Top accent bar
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, 12),
      Paint()..color = _BaseCardPainter._teal,
    );

    // Branding
    _drawBranding(canvas, 80, 60, 72);

    // Hero distance
    _drawText(
      canvas,
      '${data.distanceFormatted} km',
      80,
      200,
      fontSize: 220,
      color: _BaseCardPainter._ink,
      weight: FontWeight.w900,
    );

    // Secondary metrics row
    const metricY = 500.0;
    _drawText(canvas, 'DURATION', 80, metricY,
        fontSize: 32, color: _BaseCardPainter._mutedText, weight: FontWeight.w600);
    _drawText(canvas, data.durationFormatted, 80, metricY + 44,
        fontSize: 80, color: _BaseCardPainter._ink, weight: FontWeight.w800);

    _drawText(canvas, 'AVG PACE / km', 420, metricY,
        fontSize: 32, color: _BaseCardPainter._mutedText, weight: FontWeight.w600);
    _drawText(canvas, '${data.paceFormatted} /km', 420, metricY + 44,
        fontSize: 80, color: _BaseCardPainter._ink, weight: FontWeight.w800);

    // Map strip
    const mapTop = 740.0;
    _drawMap(canvas, Rect.fromLTWH(80, mapTop, w - 160, 220), routeWidth: 5);

    // Footer
    final footerY = mapTop + 240;
    _drawText(
      canvas,
      '@${data.username}  •  ${data.dateLabel}',
      80,
      footerY,
      fontSize: 36,
      color: _BaseCardPainter._mutedText,
    );

    // Bottom accent bar
    canvas.drawRect(
      Rect.fromLTWH(0, h - 12, w, 12),
      Paint()..color = _BaseCardPainter._teal,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// T2 Route Focus 1080 × 1350
// ─────────────────────────────────────────────────────────────────────────────

class RouteFocusCardPainter extends _BaseCardPainter {
  const RouteFocusCardPainter(super.data);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = _BaseCardPainter._tealLight,
    );

    // Map — top 70%
    const mapH = 0.70;
    final mapRect = Rect.fromLTWH(0, 0, w, h * mapH);
    _drawMap(canvas, mapRect, routeWidth: 7);

    // Frosted bottom panel
    final panelTop = h * mapH;
    final panelRect = Rect.fromLTWH(0, panelTop, w, h * (1 - mapH));
    canvas.drawRect(panelRect, Paint()..color = Colors.white);

    // Teal top border on panel
    canvas.drawRect(
      Rect.fromLTWH(0, panelTop, w, 6),
      Paint()..color = _BaseCardPainter._teal,
    );

    final py = panelTop + 56;

    // Branding
    _drawBranding(canvas, 60, py, 52);

    // Distance hero
    _drawText(canvas, '${data.distanceFormatted} km', 60, py + 80,
        fontSize: 140, color: _BaseCardPainter._ink, weight: FontWeight.w900);

    // Metrics
    const col2 = 560.0;
    _drawText(canvas, 'TIME', 60, py + 240,
        fontSize: 28, color: _BaseCardPainter._mutedText, weight: FontWeight.w600);
    _drawText(canvas, data.durationFormatted, 60, py + 276,
        fontSize: 64, color: _BaseCardPainter._ink, weight: FontWeight.w800);

    _drawText(canvas, 'PACE / km', col2, py + 240,
        fontSize: 28, color: _BaseCardPainter._mutedText, weight: FontWeight.w600);
    _drawText(canvas, data.paceFormatted, col2, py + 276,
        fontSize: 64, color: _BaseCardPainter._ink, weight: FontWeight.w800);

    // Footer
    _drawText(
      canvas,
      '@${data.username}  •  ${data.dateLabel}',
      60,
      h - 80,
      fontSize: 30,
      color: _BaseCardPainter._mutedText,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// T3 Stats Focus 1080 × 1350
// ─────────────────────────────────────────────────────────────────────────────

class StatsFocusCardPainter extends _BaseCardPainter {
  const StatsFocusCardPainter(super.data);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = _BaseCardPainter._ink,
    );

    // Top teal bar
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, 16),
      Paint()..color = _BaseCardPainter._teal,
    );

    // Branding
    _drawText(canvas, 'IndiRun', 80, 60,
        fontSize: 64, color: _BaseCardPainter._teal, weight: FontWeight.w800);

    _drawText(canvas, data.dateLabel, 80, 150,
        fontSize: 36, color: Colors.white70, weight: FontWeight.w400);

    // Divider
    canvas.drawRect(
      Rect.fromLTWH(80, 220, w - 160, 2),
      Paint()..color = Colors.white12,
    );

    // Distance — hero metric
    _drawText(canvas, 'DISTANCE', 80, 260,
        fontSize: 32, color: Colors.white54, weight: FontWeight.w600);
    _drawText(canvas, '${data.distanceFormatted} km', 80, 300,
        fontSize: 200, color: Colors.white, weight: FontWeight.w900);

    // Stats grid
    const gridTop = 560.0;
    const colW = 460.0;

    _statCell(canvas, 'DURATION', data.durationFormatted, 80, gridTop);
    _statCell(canvas, 'AVG PACE / km', data.paceFormatted, 80 + colW, gridTop);

    if (data.elevGainM != null) {
      _statCell(canvas, 'ELEVATION GAIN', data.elevLabel, 80, gridTop + 200);
    }

    // Map strip at bottom
    const mapTop = 900.0;
    _drawMap(canvas, Rect.fromLTWH(80, mapTop, w - 160, 320), routeWidth: 6);

    // Footer
    _drawText(
      canvas,
      '@${data.username}',
      80,
      h - 80,
      fontSize: 36,
      color: _BaseCardPainter._teal,
      weight: FontWeight.w600,
    );

    // Bottom bar
    canvas.drawRect(
      Rect.fromLTWH(0, h - 16, w, 16),
      Paint()..color = _BaseCardPainter._teal,
    );
  }

  void _statCell(Canvas canvas, String label, String value, double x, double y) {
    _drawText(canvas, label, x, y,
        fontSize: 28, color: Colors.white54, weight: FontWeight.w600);
    _drawText(canvas, value, x, y + 40,
        fontSize: 80, color: Colors.white, weight: FontWeight.w800);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// T4 Story 1080 × 1920
// ─────────────────────────────────────────────────────────────────────────────

class StoryCardPainter extends _BaseCardPainter {
  const StoryCardPainter(super.data);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background: dark gradient feel
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = _BaseCardPainter._ink,
    );

    // ── Top "Instagram UI" reserved zone — 250px ─────────────────────────────
    const topReserve = 250.0;
    const bottomReserve = 250.0;

    // Subtle top gradient overlay
    final topGrad = ui.Gradient.linear(
      Offset(0, 0),
      Offset(0, topReserve),
      [Colors.black.withValues(alpha: 0.4), Colors.transparent],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, topReserve),
      Paint()..shader = topGrad,
    );

    // ── Map fills the active area ─────────────────────────────────────────────
    final mapRect = Rect.fromLTWH(0, topReserve, w, h - topReserve - bottomReserve);
    _drawMap(canvas, mapRect, routeWidth: 8);

    // ── Dark overlay on map for readability ───────────────────────────────────
    canvas.drawRect(
      mapRect,
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );

    // ── Bottom info panel ─────────────────────────────────────────────────────
    final panelTop = h - bottomReserve - 100;
    final botGrad = ui.Gradient.linear(
      Offset(0, panelTop.toDouble()),
      Offset(0, h.toDouble()),
      [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, panelTop, w, h - panelTop),
      Paint()..shader = botGrad,
    );

    // Branding (top-left)
    _drawText(canvas, 'IndiRun', 80, 80,
        fontSize: 64, color: _BaseCardPainter._teal, weight: FontWeight.w900);

    // Distance hero (bottom panel)
    const distY = 1580.0;
    _drawText(canvas, '${data.distanceFormatted} km', 80, distY,
        fontSize: 180, color: Colors.white, weight: FontWeight.w900);

    // Metrics row
    const metricsY = 1790.0;
    _drawText(canvas, data.durationFormatted, 80, metricsY,
        fontSize: 60, color: Colors.white70, weight: FontWeight.w700);
    _drawText(canvas, '${data.paceFormatted} /km', 480, metricsY,
        fontSize: 60, color: Colors.white70, weight: FontWeight.w700);

    // Footer
    _drawText(
      canvas,
      '@${data.username}  •  ${data.dateLabel}',
      80,
      h - 64,
      fontSize: 32,
      color: _BaseCardPainter._teal,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preview thumbnail painter (scaled-down version for the UI picker)
// ─────────────────────────────────────────────────────────────────────────────

/// Draws a scaled-down preview of [template] inside the given [Size].
class TemplateThumbPainter extends CustomPainter {
  const TemplateThumbPainter({
    required this.template,
    required this.data,
    required this.selected,
  });

  final ShareTemplate template;
  final ShareCardData data;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final full = template.canvasSize;
    final scale = math.min(size.width / full.width, size.height / full.height);

    canvas.save();
    canvas.scale(scale);
    template.painter(data).paint(canvas, full);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TemplateThumbPainter old) =>
      old.template != template || old.selected != selected;
}
