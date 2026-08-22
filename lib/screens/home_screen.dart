import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/level_theme.dart';
import 'game_screen.dart';

/// Home screen — the first thing kids see. Big, colorful, one-tap-to-play.
///
/// Main "PLAY" button starts progressive mode (difficulty increases).
/// Tutorial button starts the 10 hand-crafted intro levels.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F0EB), // warm cream
              Color(0xFFE8DFD5), // slightly darker
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  // Game title
                  const Text(
                    '🚰',
                    style: TextStyle(fontSize: 72),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'TUBATURE',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'The Magic Plumber',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF888888),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Creature icons row
                  const Text(
                    '🐉  🧙  🚀',
                    style: TextStyle(fontSize: 36),
                  ),
                  const SizedBox(height: 48),

                  // Main PLAY button — progressive mode (difficulty increases)
                  SizedBox(
                    width: 280,
                    height: 72,
                    child: ElevatedButton(
                      onPressed: () => _startProgressive(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 6,
                        shadowColor: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                      ),
                      child: const Text(
                        '▶  PLAY!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Difficulty increases as you play!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tutorial button
                  _PlayButton(
                    label: '📖  TUTORIAL',
                    color: LevelTheme.spaceWars.flowColor,
                    onTap: () => _startTutorial(context),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startProgressive(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GameScreen(),
      ),
    );
  }

  void _startTutorial(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GameScreen(
          tutorialLevel: 1,
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PlayButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: color.withValues(alpha: 0.4),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
