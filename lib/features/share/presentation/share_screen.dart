import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/gallery_saver_service.dart';
import 'share_card_painter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// S20 Share Sheet
// ─────────────────────────────────────────────────────────────────────────────

/// Template picker + blur toggle + share/save actions.
///
/// Navigation contract (via GoRouter `extra`):
/// - `distanceKm` (double)
/// - `durationSeconds` (int)
/// - `avgPaceSec` (int)
/// - `voiceOn` (bool)
/// - `routePoints` (`List<Map<String, double>>`)
/// - `elevGainM` (double?)
/// - `startedAt` (DateTime?)
/// - `username` (String)
class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key, this.extra});
  final Map<String, dynamic>? extra;

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  ShareTemplate _selected = ShareTemplate.classic;
  bool _blurEnds = true;
  bool _generating = false;
  bool _saving = false;

  late final ShareCardData _cardData;

  @override
  void initState() {
    super.initState();
    final e = widget.extra ?? {};

    final rawPts = e['routePoints'];
    final List<Map<String, double>> pts;
    if (rawPts is List) {
      pts = rawPts
          .whereType<Map>()
          .map((m) => {
                'lat': (m['lat'] as num?)?.toDouble() ?? 0.0,
                'lng': (m['lng'] as num?)?.toDouble() ?? 0.0,
              })
          .toList();
    } else {
      pts = [];
    }

    _cardData = ShareCardData(
      distanceKm: (e['distanceKm'] as double?) ?? 5.02,
      durationSeconds: (e['durationSeconds'] as int?) ?? 1780,
      avgPaceSec: (e['avgPaceSec'] as int?) ?? 355,
      startedAt: (e['startedAt'] as DateTime?) ?? DateTime.now(),
      username: (e['username'] as String?) ?? 'runner',
      elevGainM: e['elevGainM'] as double?,
      routePoints: pts,
      voiceOn: (e['voiceOn'] as bool?) ?? false,
      blurEnds: _blurEnds,
    );
  }

  /// Returns the effective card data with the current blur setting.
  ShareCardData get _effectiveData => ShareCardData(
        distanceKm: _cardData.distanceKm,
        durationSeconds: _cardData.durationSeconds,
        avgPaceSec: _cardData.avgPaceSec,
        startedAt: _cardData.startedAt,
        username: _cardData.username,
        elevGainM: _cardData.elevGainM,
        routePoints: _cardData.routePoints,
        voiceOn: _cardData.voiceOn,
        blurEnds: _blurEnds,
      );

  Future<Uint8List> _renderCard() async {
    final template = _selected;
    final data = _effectiveData;
    final size = template.canvasSize;
    return renderShareCard(
      painter: template.painter(data),
      size: size,
      pixelRatio: 1.0, // canvas size IS the output size (1080px)
    );
  }

  String _filename() {
    final now = DateTime.now();
    final ts =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
        '_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return 'indirun_${_selected.name}_$ts.png';
  }

  Future<void> _shareCard() async {
    if (_generating) return;
    setState(() => _generating = true);

    try {
      final bytes = await _renderCard();
      final tmp = await getTemporaryDirectory();
      final file = File('${tmp.path}/${_filename()}');
      await file.writeAsBytes(bytes);

      if (!mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: 'I just ran ${_cardData.distanceFormatted} km with IndiRun! 🏃',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _saveToGallery() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final bytes = await _renderCard();
      final uri = await GallerySaverService.instance.savePng(
        pngBytes: bytes,
        filename: _filename(),
      );

      if (!mounted) return;

      if (uri != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery ✓')),
        );
      } else {
        // Non-Android: save to temp and show info
        final tmp = await getTemporaryDirectory();
        final file = File('${tmp.path}/${_filename()}');
        await file.writeAsBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to ${file.path}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // ── Preview area (full bleed, dark) ───────────────────────────────
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // Full-bleed template preview
                  Center(
                    child: AspectRatio(
                      aspectRatio: _selected == ShareTemplate.classic
                          ? 1.0
                          : _selected == ShareTemplate.story
                              ? 9 / 16
                              : 4 / 5,
                      child: CustomPaint(
                        painter: TemplateThumbPainter(
                          template: _selected,
                          data: _effectiveData,
                          selected: true,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),

                  // Back button
                  Positioned(
                    top: 12,
                    left: 12,
                    child: SafeArea(
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom sheet ───────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share your run',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 14),

                      // Template picker
                      SizedBox(
                        height: 104,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: ShareTemplate.values.length,
                          separatorBuilder: (_, index) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final tpl = ShareTemplate.values[i];
                            final sel = _selected == tpl;
                            return _TemplateThumbnail(
                              template: tpl,
                              data: _effectiveData,
                              selected: sel,
                              onTap: () =>
                                  setState(() => _selected = tpl),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Blur toggle
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hide start & end location',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Protects your home/work address',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _blurEnds,
                            onChanged: (v) => setState(() => _blurEnds = v),
                            activeThumbColor: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Share to... button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          onPressed: _generating ? null : _shareCard,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: const StadiumBorder(),
                          ),
                          child: _generating
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  'Share to...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Save to gallery button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _saving ? null : _saveToGallery,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.outline),
                            shape: const StadiumBorder(),
                          ),
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary),
                                )
                              : const Icon(Icons.download_outlined,
                                  size: 16, color: AppColors.primary),
                          label: const Text(
                            'Save to gallery',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      // Bottom safe area spacer
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Template thumbnail widget
// ─────────────────────────────────────────────────────────────────────────────

class _TemplateThumbnail extends StatelessWidget {
  const _TemplateThumbnail({
    required this.template,
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final ShareTemplate template;
  final ShareCardData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Aspect ratio of the template
    final full = template.canvasSize;
    const w = 54.0;
    final h = (full.height / full.width * w).clamp(54.0, 78.0);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.outline,
                width: selected ? 2.5 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomPaint(
              painter: TemplateThumbPainter(
                template: template,
                data: data,
                selected: selected,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            template.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
