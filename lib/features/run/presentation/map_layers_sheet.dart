import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../application/pre_run_controller.dart';
import '../domain/map_layer.dart';

/// S13 Map layers sheet — shown via showModalBottomSheet.
class MapLayersSheet extends ConsumerWidget {
  const MapLayersSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const MapLayersSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(preRunProvider).mapLayer;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineOf(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Map style',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: MapLayer.values.map((layer) {
              final selected = layer == current;
              return _LayerOption(
                layer: layer,
                selected: selected,
                onTap: () {
                  ref.read(preRunProvider.notifier).setMapLayer(layer);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'Your choice is remembered for next time',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMutedOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerOption extends StatelessWidget {
  const _LayerOption({
    required this.layer,
    required this.selected,
    required this.onTap,
  });

  final MapLayer layer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 88,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.outlineOf(context),
                width: selected ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: _LayerThumbnail(layer: layer),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            layer.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w400,
              color: selected
                  ? AppColors.primary
                  : AppColors.textOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerThumbnail extends StatelessWidget {
  const _LayerThumbnail({required this.layer});
  final MapLayer layer;

  @override
  Widget build(BuildContext context) {
    switch (layer) {
      case MapLayer.defaultLayer:
        return Container(
          color: AppColors.mapLand,
          child: CustomPaint(
            painter: _GridPainter(AppColors.mapRoad),
            child: const SizedBox.expand(),
          ),
        );
      case MapLayer.satellite:
        return Container(
          color: const Color(0xFF3A5040),
          child: CustomPaint(
            painter: _GridPainter(const Color(0xFF2A3C30)),
            child: const SizedBox.expand(),
          ),
        );
      case MapLayer.publicTransport:
        return Container(
          color: AppColors.mapLand,
          child: CustomPaint(
            painter: _TransitPainter(),
            child: const SizedBox.expand(),
          ),
        );
    }
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter(this.lineColor);
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = lineColor.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += size.width / 3) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += size.height / 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _TransitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Grid
    final grid = Paint()
      ..color = AppColors.mapRoad.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += size.width / 3) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += size.height / 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    // Metro line
    final metro = Paint()
      ..color = AppColors.routeAccent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      metro,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
