import '../models/voice_entry.dart';
import 'audio_synth_stub.dart'
    if (dart.library.js_interop) 'audio_synth_web.dart' as synth;

/// Central Audio Service for Tubature.
/// Provides procedural audio effects for pipe clicks, water flow bubbling,
/// ampolla filling (glub glub), victory fanfare, and Ferrarese character voice reactions.
class AudioService {
  static bool isMuted = false;

  /// Active voice line callback (for talking avatar widget lip-sync)
  static void Function(VoiceEntry entry)? onVoiceStarted;
  static void Function()? onVoiceEnded;

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

  /// Play satisfying "glub glub glub" water filling sound when a dead-end ampolla flask fills.
  static void playAmpollaGlub() {
    if (isMuted) return;
    synth.playAmpollaGlub();
  }

  /// Play a joyful completion fanfare when the full puzzle is solved.
  static void playVictoryFanfare() {
    if (isMuted) return;
    synth.playVictoryFanfare();
  }

  /// Play character voice reaction for puzzle completion.
  /// If [ampollaCount] == 2, plays "Mayàl, ac du bàl!" easter egg.
  static VoiceEntry playVictoryVoice({int ampollaCount = 0}) {
    final entry = VoiceCatalog.pickVictoryVoice(ampollaCount: ampollaCount);
    _playVoice(entry);
    return entry;
  }

  /// Play character voice reaction for puzzle reset / mistake / give up.
  static VoiceEntry playFailureVoice() {
    final entry = VoiceCatalog.pickFailureVoice();
    _playVoice(entry);
    return entry;
  }

  static void _playVoice(VoiceEntry entry) {
    onVoiceStarted?.call(entry);
    if (!isMuted) {
      synth.playVoiceFile(entry.path);
    }
  }

  /// Toggle mute on/off.
  static void toggleMute() {
    isMuted = !isMuted;
  }
}
