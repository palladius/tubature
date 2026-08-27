import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/// Pre-loads and caches the 4 Google-colored cross tile icons.
/// These appear only on the very rare cross tile (all 4 directions connected).
class CrossImageService {
  static final Map<String, ui.Image> _cache = {};
  static bool _loaded = false;

  static const _assets = {
    'nw': 'assets/cross/cross_nw_ruby.png',
    'ne': 'assets/cross/cross_ne_sun.png',
    'sw': 'assets/cross/cross_sw_droplet.png',
    'se': 'assets/cross/cross_se_basil.png',
  };

  /// Pre-load all 4 cross icons. Safe to call multiple times.
  static Future<void> preload() async {
    if (_loaded) return;
    for (final entry in _assets.entries) {
      try {
        final data = await rootBundle.load(entry.value);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _cache[entry.key] = frame.image;
      } catch (_) {
        // Asset may not exist in tests — that's ok
      }
    }
    _loaded = true;
  }

  /// Get a cached cross icon by quadrant key (nw, ne, sw, se).
  static ui.Image? getImage(String quadrant) => _cache[quadrant];

  /// Get all 4 images as a list [NW, NE, SW, SE] (may contain nulls if not loaded).
  static List<ui.Image?> get allImages => [
    _cache['nw'],
    _cache['ne'],
    _cache['sw'],
    _cache['se'],
  ];

  static bool get isLoaded => _loaded;
}
