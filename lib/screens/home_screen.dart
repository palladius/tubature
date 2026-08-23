import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level.dart';
import '../theme/level_theme.dart';
import '../version.dart';
import 'game_screen.dart';

/// Home screen — the first thing kids see. Big, colorful, one-tap-to-play.
///
/// Features:
/// - Difficulty selector: Progressive ⚡ / Easy 🟢 / Medium 🟡 / Hard 🔴
/// - Big prominent PLAY button
/// - Tutorial mode (10 intro levels)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // null = Progressive mode, or Difficulty.easy / medium / hard
  Difficulty? _selectedDifficulty;

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // Game title
                  const Text(
                    '🚰',
                    style: TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'TUBATURE',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'The Magic Plumber',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF888888),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Creature icons row (Fantasy Medieval D&D)
                  const Text(
                    '🐉  🧙  💎',
                    style: TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 28),

                  // Difficulty selector chips
                  const Text(
                    'SELECT DIFFICULTY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF777777),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _DifficultyChip(
                        label: 'Auto ⚡',
                        subLabel: 'Ramps up',
                        isSelected: _selectedDifficulty == null,
                        color: const Color(0xFF1976D2), // high-contrast blue
                        onTap: () => setState(() => _selectedDifficulty = null),
                      ),
                      _DifficultyChip(
                        label: 'Easy 🟢',
                        subLabel: '6×6',
                        isSelected: _selectedDifficulty == Difficulty.easy,
                        color: const Color(0xFF2E7D32), // rich deep green
                        onTap: () => setState(() => _selectedDifficulty = Difficulty.easy),
                      ),
                      _DifficultyChip(
                        label: 'Medium 🟡',
                        subLabel: '7-8',
                        isSelected: _selectedDifficulty == Difficulty.medium,
                        color: const Color(0xFFE65100), // rich deep amber
                        onTap: () => setState(() => _selectedDifficulty = Difficulty.medium),
                      ),
                      _DifficultyChip(
                        label: 'Hard 🔴',
                        subLabel: '9-10',
                        isSelected: _selectedDifficulty == Difficulty.hard,
                        color: const Color(0xFFC2185B), // rich deep berry
                        onTap: () => setState(() => _selectedDifficulty = Difficulty.hard),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Main PLAY button
                  SizedBox(
                    width: 280,
                    height: 68,
                    child: ElevatedButton(
                      onPressed: _startPlay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getPlayButtonColor(),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 6,
                        shadowColor: _getPlayButtonColor().withValues(alpha: 0.4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _getPlayButtonText(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getDifficultyDescription(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tutorial button
                  _PlayButton(
                    label: '📖  TUTORIAL',
                    color: LevelTheme.crystalCaves.flowColor,
                    onTap: _startTutorial,
                  ),
                  const SizedBox(height: 36),

                  // Version footer
                  Text(
                    'v$appVersion',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDifficultyDescription() {
    if (_selectedDifficulty == null) return '⚡ Progressive mode (difficulty increases)';
    switch (_selectedDifficulty!) {
      case Difficulty.easy:
        return '🟢 Fixed Easy mode (6×6 grid)';
      case Difficulty.medium:
        return '🟡 Fixed Medium mode (7-8 grid)';
      case Difficulty.hard:
        return '🔴 Fixed Hard mode (9-10 grid)';
    }
  }

  Color _getPlayButtonColor() {
    if (_selectedDifficulty == null) return const Color(0xFF1976D2);
    switch (_selectedDifficulty!) {
      case Difficulty.easy:
        return const Color(0xFF2E7D32);
      case Difficulty.medium:
        return const Color(0xFFE65100);
      case Difficulty.hard:
        return const Color(0xFFC2185B);
    }
  }

  String _getPlayButtonText() {
    return '▶  PLAY!';
  }

  void _startPlay() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          difficulty: _selectedDifficulty,
        ),
      ),
    );
  }

  void _startTutorial() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GameScreen(
          tutorialLevel: 1,
        ),
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String label;
  final String subLabel;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.label,
    required this.subLabel,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subLabel,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
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
      height: 52,
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
