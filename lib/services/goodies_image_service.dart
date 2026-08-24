import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../models/cauldron_goodie.dart';

/// Pre-loads and caches CauldronGoodie images for Canvas rendering.
class GoodiesImageService {
  static final Map<String, ui.Image> _cache = {};
  
  /// Pre-load images for assigned goodies at level start
  static Future<void> preloadImages(List<CauldronGoodie> goodies) async {
    for (final goodie in goodies) {
      if (!_cache.containsKey(goodie.id)) {
        try {
          final data = await rootBundle.load(goodie.assetPath);
          final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
          final frame = await codec.getNextFrame();
          _cache[goodie.id] = frame.image;
        } catch (e) {
          // If asset is missing in test or development, ignore it
          // In a real app we'd log this properly
        }
      }
    }
  }
  
  /// Get cached image for a goodie
  static ui.Image? getImage(String goodieId) => _cache[goodieId];
  
  /// Clear cache
  static void clearCache() => _cache.clear();
}
