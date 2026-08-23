import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level.dart';
import '../theme/level_theme.dart';
import '../version.dart';
import 'game_screen.dart';

/// Home screen — responsive, bold, kid-friendly mobile-first UI.
///
/// Features:
/// - 2x2 large finger-friendly difficulty selector cards
/// - Full-width prominent PLAY button with dynamic theme color
/// - Full-width TUTORIAL button
/// - Medieval fantasy creature icon banner
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    // Game logo icon
                    const Center(
                      child: Text(
                        '🚰',
                        style: TextStyle(fontSize: 68),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Title
                    const Center(
                      child: Text(
                        'TUBATURE',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2C3E50),
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Center(
                      child: Text(
                        'The Magic Plumber',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7F8C8D),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Creature icons row (Fantasy Medieval D&D)
                    const Center(
                      child: Text(
                        '🐉   🧙   💎',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Difficulty selector title
                    const Center(
                      child: Text(
                        'SELECT DIFFICULTY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7F8C8D),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2x2 Grid of Large Difficulty Cards
                    Row(
                      children: [
                        Expanded(
                          child: _DifficultyCard(
                            label: 'Auto ⚡',
                            subLabel: 'Ramps up',
                            isSelected: _selectedDifficulty == null,
                            color: const Color(0xFF1976D2),
                            onTap: () => setState(() => _selectedDifficulty = null),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DifficultyCard(
                            label: 'Easy 🟢',
                            subLabel: '6×6 grid',
                            isSelected: _selectedDifficulty == Difficulty.easy,
                            color: const Color(0xFF2E7D32),
                            onTap: () => setState(() => _selectedDifficulty = Difficulty.easy),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _DifficultyCard(
                            label: 'Medium 🟡',
                            subLabel: '7-8 grid',
                            isSelected: _selectedDifficulty == Difficulty.medium,
                            color: const Color(0xFFE65100),
                            onTap: () => setState(() => _selectedDifficulty = Difficulty.medium),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DifficultyCard(
                            label: 'Hard 🔴',
                            subLabel: '9-10 grid',
                            isSelected: _selectedDifficulty == Difficulty.hard,
                            color: const Color(0xFFC2185B),
                            onTap: () => setState(() => _selectedDifficulty = Difficulty.hard),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Main PLAY button
                    SizedBox(
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
                          shadowColor: _getPlayButtonColor().withValues(alpha: 0.45),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 36),
                            SizedBox(width: 8),
                            Text(
                              'PLAY!',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _getDifficultyDescription(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tutorial button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _startTutorial,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LevelTheme.crystalCaves.flowColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: LevelTheme.crystalCaves.flowColor.withValues(alpha: 0.4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '📖  TUTORIAL',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Version footer
                    Center(
                      child: Text(
                        'v$appVersion',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
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

class _DifficultyCard extends StatelessWidget {
  final String label;
  final String subLabel;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyCard({
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
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subLabel,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white.withValues(alpha: 0.9) : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
