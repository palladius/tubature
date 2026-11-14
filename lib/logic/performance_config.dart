import 'package:flutter/foundation.dart';
import 'js_bridge_stub.dart'
    if (dart.library.js_interop) 'js_bridge_web.dart' as js_bridge;

/// Global performance configuration for Raspberry Pi 400 ("Sguisatazzo") and
/// low-end ARM / WebKit2GTK / VideoCore VI environments.
///
/// When [isRaspberryPiMode] is active:
/// - Connected tiles do NOT run 60 FPS infinite `_shimmerController.repeat()`
///   loops at idle (0% idle CPU after pipe fill completes).
/// - `BackdropFilter` (16px Gaussian blur) on HomeScreen is bypassed in favor
///   of a crisp high-contrast dark container.
/// - Heavy 1080p MP4 background video autoplay is paused by default on startup
///   (instant <0.5s HomeScreen load; manual play still available).
/// - `MaskFilter.blur` and `canvas.saveLayer` in `PipePainter` /
///   `CauldronRevealPainter` are replaced with fast single-pass primitives.
/// - Goodie 1024x1024 PNG textures are decoded at compact target dimensions
///   (128x128 in RPi mode, 256x256 in standard mode) to fit inside the
///   BCM2711 Cortex-A72 1 MB L2 cache and VideoCore VI texture cache.
class PerformanceConfig extends ChangeNotifier {
  PerformanceConfig._() {
    _isRaspberryPiMode = _detectInitialMode();
  }

  static final PerformanceConfig instance = PerformanceConfig._();

  bool _isRaspberryPiMode = false;

  /// True when Raspberry Pi / Sguisatazzo Turbo optimization mode is enabled.
  bool get isRaspberryPiMode => _isRaspberryPiMode;

  /// Convenience static getter.
  static bool get isLowEnd => instance._isRaspberryPiMode;

  /// Whether connected tiles should run continuous 60 FPS sinusoidal river shimmer.
  static bool get enableContinuousShimmer => !instance._isRaspberryPiMode;

  /// Whether HomeScreen glassmorphic panels should apply BackdropFilter Gaussian blur.
  static bool get enableBackdropBlur => !instance._isRaspberryPiMode;

  /// Whether HomeScreen background video should auto-initialize and autoplay on startup.
  static bool get enableBackgroundVideoAutoplay => !instance._isRaspberryPiMode;

  /// Whether Canvas painters should use MaskFilter.blur and multi-copy saveLayer.
  static bool get enableCanvasBlurAndSaveLayer => !instance._isRaspberryPiMode;

  /// Target decode width/height (px) for 1024x1024 CauldronGoodie PNG assets.
  /// - 128px in RPi mode (~64 KB RGBA per image vs 4 MB at 1024x1024 = 98.4% reduction)
  /// - 256px in standard mode (~256 KB RGBA per image = 93.7% reduction)
  static int get goodieDecodeTargetSize => instance._isRaspberryPiMode ? 128 : 256;

  /// Duration of ampolla dead-end fill animation (faster in RPi mode to reduce active frames).
  static Duration get ampollaFillDuration => instance._isRaspberryPiMode
      ? const Duration(milliseconds: 2400)
      : const Duration(milliseconds: 8500);

  /// Number of confetti particles on VictoryOverlay.
  static int get victoryConfettiCount => instance._isRaspberryPiMode ? 14 : 40;

  /// Detect initial mode from URL query parameters (`?rpi=1`, `?lowperf=1`, `?sguisatazzo=1`)
  /// or JS hardware heuristics (`window._tubatureLowEnd`).
  static bool detectFromUriAndEnvironment({
    Map<String, String>? queryParameters,
    bool? jsLowEndFlag,
  }) {
    final params = queryParameters ?? (kIsWeb ? Uri.base.queryParameters : const <String, String>{});
    for (final key in const ['rpi', 'raspberry', 'sguisatazzo', 'lowperf', 'lite']) {
      final raw = params[key]?.toLowerCase().trim();
      if (raw == '1' || raw == 'true' || raw == 'on' || raw == 'yes') {
        return true;
      }
      if (raw == '0' || raw == 'false' || raw == 'off' || raw == 'no') {
        return false;
      }
    }
    final jsFlag = jsLowEndFlag ?? (kIsWeb ? js_bridge.getJsTubatureLowEnd() : false);
    return jsFlag;
  }

  bool _detectInitialMode() {
    return detectFromUriAndEnvironment();
  }

  /// Re-evaluates environment detection (useful in tests or after URL changes).
  void refreshDetection({
    Map<String, String>? queryParameters,
    bool? jsLowEndFlag,
  }) {
    final detected = detectFromUriAndEnvironment(
      queryParameters: queryParameters,
      jsLowEndFlag: jsLowEndFlag,
    );
    setRaspberryPiMode(detected);
  }

  /// Explicitly enable or disable Raspberry Pi optimization mode.
  void setRaspberryPiMode(bool enabled) {
    if (_isRaspberryPiMode == enabled) return;
    _isRaspberryPiMode = enabled;
    if (kIsWeb) {
      js_bridge.setJsTubatureLowEnd(enabled);
    }
    notifyListeners();
  }

  /// Toggle Raspberry Pi optimization mode on/off.
  bool toggleRaspberryPiMode() {
    setRaspberryPiMode(!_isRaspberryPiMode);
    return _isRaspberryPiMode;
  }
}
