import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Saves PNG bytes to the Android photo gallery via MediaStore (API 29+).
///
/// Does NOT require WRITE_EXTERNAL_STORAGE on Android 10+.
/// Falls back gracefully on non-Android platforms (no-op with debug log).
class GallerySaverService {
  GallerySaverService._();
  static final GallerySaverService instance = GallerySaverService._();

  static const _channel = MethodChannel('com.indirun/gallery');

  /// Saves [pngBytes] to the Pictures/IndiRun folder in the gallery.
  /// Returns the saved file URI on Android, or null on other platforms.
  Future<String?> savePng({
    required Uint8List pngBytes,
    required String filename,
  }) async {
    if (!defaultTargetPlatform.isAndroid) {
      debugPrint('GallerySaverService: skipped on non-Android platform');
      return null;
    }

    try {
      final result = await _channel.invokeMethod<String>('savePng', {
        'bytes': pngBytes,
        'filename': filename,
        'album': 'IndiRun',
      });
      debugPrint('GallerySaverService: saved → $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint('GallerySaverService error: ${e.message}');
      return null;
    }
  }
}

extension on TargetPlatform {
  bool get isAndroid => this == TargetPlatform.android;
}
