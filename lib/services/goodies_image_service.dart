import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../logic/performance_config.dart';
import '../models/cauldron_goodie.dart';

/// Pre-loads and caches CauldronGoodie images for Canvas rendering.
///
/// Decodes 1024x1024 PNGs at [PerformanceConfig.goodieDecodeTargetSize]
/// (128x128 in Raspberry Pi mode, 256x256 in standard mode) to reduce raw RGBA
/// texture memory by 94–98% and prevent L2 cache thrashing on ARM Cortex-A72.
class GoodiesImageService {
  static final Map<String, ui.Image> _cache = {};

  /// Pre-load images for assigned goodies at level start
  static Future<void> preloadImages(List<CauldronGoodie> goodies) async {
    final targetSize = PerformanceConfig.goodieDecodeTargetSize;
    for (final goodie in goodies) {
      if (!_cache.containsKey(goodie.id)) {
        try {
          final data = await rootBundle.load(goodie.assetPath);
          final codec = await ui.instantiateImageCodec(
            data.buffer.asUint8List(),
            targetWidth: targetSize,
            targetHeight: targetSize,
          );
          final frame = await codec.getNextFrame();
          _cache[goodie.id] = frame.image;
        } catch (e) {
          // If asset is missing in test or development, ignore it
        }
      }
    }
  }

  /// Get cached image for a goodie
  static ui.Image? getImage(String goodieId) => _cache[goodieId];

  /// Clear cache
  static void clearCache() => _cache.clear();
}
