import 'package:flutter/material.dart';
import '../models/voice_entry.dart';
import '../services/audio_service.dart';

/// Interactive Audio & Voice Soundboard Debug Panel.
/// Allows instant playback of all procedural sound effects and character voice lines.
class AudioDebugDialog extends StatelessWidget {
  const AudioDebugDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AudioDebugDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goodVoices = VoiceCatalog.allVoices.where((v) => v.isGood).toList();
    final badVoices = VoiceCatalog.allVoices.where((v) => v.isBad).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Title bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.campaign_rounded, color: Color(0xFF38BDF8), size: 28),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUDIO & VOICE SOUNDBOARD 🧪',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Tap any button to test audio & Ermete speech animation',
                        style: TextStyle(fontSize: 12, color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          // Scrollable soundboard list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // SECTION 1: PROCEDURAL SOUND EFFECTS
                _buildSectionHeader('PROCEDURAL GAME SFX', Icons.music_note_rounded, const Color(0xFF38BDF8)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSfxChip(
                      label: '🔧 Click Ratchet',
                      onTap: () => AudioService.playTileClick(),
                      color: const Color(0xFF64748B),
                    ),
                    _buildSfxChip(
                      label: '🌊 Water Flow (1)',
                      onTap: () => AudioService.playWaterFlow(chainLength: 1),
                      color: const Color(0xFF0284C7),
                    ),
                    _buildSfxChip(
                      label: '🌊 Water Flow (4)',
                      onTap: () => AudioService.playWaterFlow(chainLength: 4),
                      color: const Color(0xFF0284C7),
                    ),
                    _buildSfxChip(
                      label: '🧪 Ampolla Glub-Glub',
                      onTap: () => AudioService.playAmpollaGlub(),
                      color: const Color(0xFF8B5CF6),
                    ),
                    _buildSfxChip(
                      label: '🎺 Victory Fanfare',
                      onTap: () => AudioService.playVictoryFanfare(),
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // SECTION 2: GOOD / VICTORY VOICES
                _buildSectionHeader('GOOD VOICES (VICTORY & EASTER EGGS) 🏆', Icons.celebration_rounded, const Color(0xFF4ADE80)),
                const SizedBox(height: 10),
                ...goodVoices.map((voice) => _buildVoiceTile(context, voice)),

                const SizedBox(height: 24),

                // SECTION 3: BAD / FAILURE VOICES
                _buildSectionHeader('BAD VOICES (RESET & GAME OVER) 💥', Icons.warning_rounded, const Color(0xFFF87171)),
                const SizedBox(height: 10),
                ...badVoices.map((voice) => _buildVoiceTile(context, voice)),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildSfxChip({required String label, required VoidCallback onTap, required Color color}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.play_arrow_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceTile(BuildContext context, VoiceEntry voice) {
    final accentColor = voice.isEasterEgg
        ? const Color(0xFFFFD700)
        : (voice.isGood ? const Color(0xFF4ADE80) : const Color(0xFFF87171));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: accentColor.withValues(alpha: 0.2),
          radius: 20,
          child: Icon(
            voice.isEasterEgg
                ? Icons.egg_rounded
                : (voice.isGood ? Icons.thumb_up_rounded : Icons.thumb_down_rounded),
            color: accentColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '« ${voice.displayName} »',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (voice.isEasterEgg)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '2 AMPOLLE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            '${voice.meaningIt} • [${voice.id}]',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.65),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.play_circle_fill_rounded, color: accentColor, size: 34),
          onPressed: () {
            AudioService.onVoiceStarted?.call(voice);
            if (!AudioService.isMuted) {
              AudioService.playVictoryVoice(ampollaCount: voice.requiredAmpollaCount ?? 0);
            }
          },
          tooltip: 'Play voice',
        ),
      ),
    );
  }
}
