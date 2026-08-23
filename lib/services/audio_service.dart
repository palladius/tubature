import 'audio_synth_stub.dart'
    if (dart.library.js_interop) 'audio_synth_web.dart' as synth;

/// Central Audio Service for Tubature.
/// Provides procedural audio effects for pipe clicks, water flow bubbling, and victory fanfare.
class AudioService {
  static bool isMuted = false;

  /// Play a crisp mechanical ratchet/click sound when a pipe tile is tapped.
  static void playTileClick() {
    if (isMuted) return;
    synth.playTileClick();
  }

  /// Play organic water bubbling/whoosh sound when new pipes are connected to the flow.
  static void playWaterFlow({int chainLength = 1}) {
    if (isMuted) return;
    synth.playWaterFlow(chainLength);
  }

  /// Play a joyful completion fanfare when the full puzzle is solved.
  static void playVictoryFanfare() {
    if (isMuted) return;
    synth.playVictoryFanfare();
  }

  /// Toggle mute on/off.
  static void toggleMute() {
    isMuted = !isMuted;
  }
}
