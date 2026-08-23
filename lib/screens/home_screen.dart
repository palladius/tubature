import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level.dart';
import '../version.dart';
import 'game_screen.dart';

/// Home screen — Epic D&D Dungeon Plumber theme starring Riccardo & Baby Dragon.
///
/// Responsive Design:
/// - Landscape (Mobile/Tablet/Desktop rotated): Full panoramic artwork on left,
///   interactive controls panel on right.
/// - Portrait (Mobile/Pixel 10): Balanced title at top, spacious character artwork,
///   and generous, comfortable touch controls at bottom.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Difficulty? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    // Allow all orientations on the Home Screen
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape || size.width > size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF161F28),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fantasy Dungeon Plumber Background Artwork
          Image.asset(
            isLandscape
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

          // 2. Ambient subtle gradient for text contrast
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isLandscape
                    ? [
                        Colors.black.withValues(alpha: 0.25),
                        Colors.black.withValues(alpha: 0.55),
                      ]
                    : [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.70),
                      ],
                stops: isLandscape ? null : const [0.0, 0.40, 1.0],
              ),
            ),
          ),

          // 3. Foreground Content
          SafeArea(
            child: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
          ),
        ],
      ),
    );
  }

  /// Mobile Portrait Layout (Pixel 10 / Phone): Beautifully balanced & spacious
  Widget _buildPortraitLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Header Banner
                    _buildHeader(),
                    
                    // Center Art Breathing Space (shows Riccardo, Ale, Seby & Dragon)
                    const Spacer(),

                    // Bottom Glassmorphic Control Panel (Spacious & Comfortable)
                    _buildGlassmorphicPanel(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDifficultySelector(),
                          const SizedBox(height: 14),
                          _buildPlayButton(),
                          const SizedBox(height: 8),
                          _buildDifficultyDescriptionText(),
                          const SizedBox(height: 12),
                          _buildTutorialButton(),
                          const SizedBox(height: 10),
                          _buildVersionFooter(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Tablet/Desktop/Rotated Phone Landscape Layout: Side-by-side with right-aligned card
  Widget _buildLandscapeLayout() {
    return Align(
      alignment: Alignment.centerRight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: _buildGlassmorphicPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 14),
                _buildDifficultySelector(),
                const SizedBox(height: 14),
                _buildPlayButton(),
                const SizedBox(height: 6),
                _buildDifficultyDescriptionText(),
                const SizedBox(height: 12),
                _buildTutorialButton(),
                const SizedBox(height: 8),
                _buildVersionFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicPanel({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF161F28).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFD54F).withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'TUBATURE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFD54F),
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: Color(0xFFFF8F00),
                blurRadius: 18,
                offset: Offset(0, 2),
              ),
              Shadow(
                color: Colors.black,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'THE DUNGEON PLUMBER',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF80DEEA),
            letterSpacing: 3,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '🐲 Quest for the Crystal Springs 💎',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFFCFD8DC),
            fontStyle: FontStyle.italic,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      children: [
        const Text(
          'SELECT DIFFICULTY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFFFFD54F),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
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
            const SizedBox(width: 8),
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
        const SizedBox(height: 8),
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
            const SizedBox(width: 8),
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
      ],
    );
  }

  Widget _buildPlayButton() {
    return SizedBox(
      height: 62,
      child: ElevatedButton(
        onPressed: _startPlay,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getPlayButtonColor(),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
          shadowColor: _getPlayButtonColor().withValues(alpha: 0.6),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: 36),
            SizedBox(width: 6),
            Text(
              'PLAY!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyDescriptionText() {
    return Center(
      child: Text(
        _getDifficultyDescription(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFCFD8DC),
        ),
      ),
    );
  }

  Widget _buildTutorialButton() {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: _startTutorial,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF80DEEA),
          side: const BorderSide(
            color: Color(0xFF00ACC1),
            width: 1.8,
          ),
          backgroundColor: const Color(0xFF006064).withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '📖  TUTORIAL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionFooter() {
    return Center(
      child: Text(
        'v$appVersion • The Dungeon Plumber',
        style: TextStyle(
          fontSize: 11,
          color: Colors.white.withValues(alpha: 0.45),
          letterSpacing: 1,
          fontWeight: FontWeight.w500,
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
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : const Color(0xFF243442).withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD54F) : Colors.white.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.6),
                    blurRadius: 10,
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
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFFECEFF1),
              ),
            ),
            const SizedBox(height: 2),
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
