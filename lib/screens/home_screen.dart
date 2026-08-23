import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level.dart';
import '../version.dart';
import 'game_screen.dart';

/// Home screen — Epic D&D Dungeon Plumber theme.
///
/// Features:
/// - Rich fantasy background art with magical crystal pipes and baby dragon
/// - Responsive glassmorphic panel that scales gracefully on mobile, tablet, and desktop
/// - 2x2 large finger-friendly difficulty cards
/// - Hero PLAY and TUTORIAL buttons
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Difficulty? _selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > size.height && size.width > 700;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fantasy Dungeon Plumber Background Artwork
          Image.asset(
            isWide
                ? 'assets/images/home_background_wide.jpg'
                : 'assets/images/home_background.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E2D2F), Color(0xFF0F171A)],
                ),
              ),
            ),
          ),

          // 2. Ambient dark gradient for text legibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
            ),
          ),

          // 3. Responsive Foreground UI
          SafeArea(
            child: Align(
              alignment: isWide ? Alignment.centerRight : Alignment.center,
              child: SingleChildScrollView(
                padding: isWide
                    ? const EdgeInsets.symmetric(horizontal: 48, vertical: 24)
                    : const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161F28).withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Game Title
                            const Center(
                              child: Text(
                                'TUBATURE',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFFD54F),
                                  letterSpacing: 4,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFFFF8F00),
                                      blurRadius: 16,
                                      offset: Offset(0, 2),
                                    ),
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Center(
                              child: Text(
                                'THE DUNGEON PLUMBER',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF80DEEA),
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Center(
                              child: Text(
                                '🐲 Quest for the Crystal Springs 💎',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFB0BEC5),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Difficulty header
                            const Center(
                              child: Text(
                                'SELECT DIFFICULTY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFFD54F),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 2x2 Difficulty Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _FantasyDifficultyCard(
                                    label: 'Auto ⚡',
                                    subLabel: 'Ramps up',
                                    isSelected: _selectedDifficulty == null,
                                    activeColor: const Color(0xFF1976D2),
                                    onTap: () => setState(() => _selectedDifficulty = null),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _FantasyDifficultyCard(
                                    label: 'Easy 🟢',
                                    subLabel: '6×6 grid',
                                    isSelected: _selectedDifficulty == Difficulty.easy,
                                    activeColor: const Color(0xFF2E7D32),
                                    onTap: () => setState(() => _selectedDifficulty = Difficulty.easy),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _FantasyDifficultyCard(
                                    label: 'Medium 🟡',
                                    subLabel: '7-8 grid',
                                    isSelected: _selectedDifficulty == Difficulty.medium,
                                    activeColor: const Color(0xFFE65100),
                                    onTap: () => setState(() => _selectedDifficulty = Difficulty.medium),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _FantasyDifficultyCard(
                                    label: 'Hard 🔴',
                                    subLabel: '9-10 grid',
                                    isSelected: _selectedDifficulty == Difficulty.hard,
                                    activeColor: const Color(0xFFC2185B),
                                    onTap: () => setState(() => _selectedDifficulty = Difficulty.hard),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Hero PLAY button
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
                                  elevation: 8,
                                  shadowColor: _getPlayButtonColor().withValues(alpha: 0.6),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow_rounded, size: 38),
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
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFCFD8DC),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Tutorial Button
                            SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: _startTutorial,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF80DEEA),
                                  side: const BorderSide(
                                    color: Color(0xFF00ACC1),
                                    width: 2,
                                  ),
                                  backgroundColor: const Color(0xFF006064).withValues(alpha: 0.35),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
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
                            const SizedBox(height: 24),

                            // Footer Version
                            Center(
                              child: Text(
                                'v$appVersion • The Dungeon Plumber',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
    if (_selectedDifficulty == null) return const Color(0xFF1E88E5);
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

class _FantasyDifficultyCard extends StatelessWidget {
  final String label;
  final String subLabel;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _FantasyDifficultyCard({
    required this.label,
    required this.subLabel,
    required this.isSelected,
    required this.activeColor,
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
          color: isSelected
              ? activeColor
              : const Color(0xFF243442).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD54F) : Colors.white.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.6),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFFECEFF1),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subLabel,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.95)
                    : const Color(0xFF90A4AE),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
