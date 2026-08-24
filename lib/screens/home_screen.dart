import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level.dart';
import '../version.dart';
import '../widgets/audio_debug_dialog.dart';
import 'game_screen.dart';

/// Home screen — Epic D&D Dungeon Plumber theme starring Riccardo, Ale & Seby.
///
/// Responsive Design:
/// - Landscape (Desktop/Tablet/Rotated Phone): Panoramic background on left,
///   control panel on right.
/// - Portrait (Phones / Pixel 10): Prominent top title header, unobstructed
///   character art, and large, finger-friendly, comfortable bottom controls deck.
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
    // Allow all orientations on the Home Screen so phone rotation works freely
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
          // 1. Background Artwork (Wide or Portrait)
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

          // 2. Ambient contrast gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isLandscape
                    ? [
                        Colors.black.withValues(alpha: 0.20),
                        Colors.black.withValues(alpha: 0.55),
                      ]
                    : [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                stops: isLandscape ? null : const [0.0, 0.35, 1.0],
              ),
            ),
          ),

          // 3. Foreground Controls
          SafeArea(
            child: isLandscape
                ? _buildLandscapeLayout(size)
                : _buildPortraitLayout(size),
          ),
        ],
      ),
    );
  }

  /// Mobile Portrait Layout (Pixel 10): Spacious, bold, kid-friendly controls
  Widget _buildPortraitLayout(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Header Banner
          _buildHeader(isCompact: false),

          // 2. Generous middle space showing Riccardo, Ale, Seby & Dragon
          const Spacer(),

          // 3. Large, Comfortable Glassmorphic Bottom Deck
          _buildGlassmorphicContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                const SizedBox(height: 10),

                // 2x2 Difficulty Cards
                _buildGridDifficultySelector(isShort: false),
                const SizedBox(height: 12),

                // Large Juicy Play Button
                _buildPlayButton(height: 58, fontSize: 24),
                const SizedBox(height: 6),

                // Helper description
                _buildDifficultyDescriptionText(),
                const SizedBox(height: 10),

                // Tutorial Button
                _buildTutorialButton(height: 46, fontSize: 15),
                const SizedBox(height: 6),

                // Version
                _buildVersionFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Landscape Layout (Rotated Phone / Desktop / Tablet): Clean right-hand control card
  Widget _buildLandscapeLayout(Size size) {
    final isShort = size.height < 500;
    final cardWidth = size.width < 800 ? size.width * 0.44 : 420.0;

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width < 700 ? 12 : 32,
          vertical: isShort ? 6 : 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: cardWidth,
            maxHeight: size.height - (isShort ? 12 : 32),
          ),
          child: _buildGlassmorphicContainer(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: isShort ? 8 : 14,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(isCompact: isShort),
                  SizedBox(height: isShort ? 6 : 10),
                  _buildGridDifficultySelector(isShort: isShort),
                  SizedBox(height: isShort ? 6 : 12),
                  _buildPlayButton(
                    height: isShort ? 40 : 54,
                    fontSize: isShort ? 18 : 22,
                  ),
                  if (!isShort) ...[
                    const SizedBox(height: 3),
                    _buildDifficultyDescriptionText(),
                  ],
                  SizedBox(height: isShort ? 6 : 10),
                  _buildTutorialButton(
                    height: isShort ? 34 : 42,
                    fontSize: isShort ? 12 : 14,
                  ),
                  const SizedBox(height: 4),
                  _buildVersionFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicContainer({
    required Widget child,
    required EdgeInsets padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF161F28).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFD54F).withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isCompact}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isCompact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD54F).withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TUBATURE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 28 : 38,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFFFD54F),
              letterSpacing: isCompact ? 3 : 4,
              shadows: const [
                Shadow(
                  color: Color(0xFFFF8F00),
                  blurRadius: 16,
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
          Text(
            'THE DUNGEON PLUMBERS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 11 : 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF80DEEA),
              letterSpacing: isCompact ? 2 : 2.5,
              shadows: const [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(height: 2),
            const Text(
              '🐲 Quest for the Crystal Springs 💎',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFCFD8DC),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 2x2 grid selector for both portrait and landscape
  Widget _buildGridDifficultySelector({bool isShort = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _DifficultyCard(
                label: 'Auto ⚡',
                subLabel: 'Ramps up',
                isShort: isShort,
                isSelected: _selectedDifficulty == null,
                activeColor: const Color(0xFF1976D2),
                onTap: () => setState(() => _selectedDifficulty = null),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DifficultyCard(
                label: 'Easy 🟢',
                subLabel: '6×6 grid',
                isShort: isShort,
                isSelected: _selectedDifficulty == Difficulty.easy,
                activeColor: const Color(0xFF2E7D32),
                onTap: () => setState(() => _selectedDifficulty = Difficulty.easy),
              ),
            ),
          ],
        ),
        SizedBox(height: isShort ? 4 : 8),
        Row(
          children: [
            Expanded(
              child: _DifficultyCard(
                label: 'Med 🟡',
                subLabel: '7-8 grid',
                isShort: isShort,
                isSelected: _selectedDifficulty == Difficulty.medium,
                activeColor: const Color(0xFFE65100),
                onTap: () => setState(() => _selectedDifficulty = Difficulty.medium),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DifficultyCard(
                label: 'Hard 🔴',
                subLabel: '9-10 grid',
                isShort: isShort,
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

  Widget _buildPlayButton({required double height, required double fontSize}) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: _startPlay,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getPlayButtonColor(),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: _getPlayButtonColor().withValues(alpha: 0.6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, size: fontSize + 12),
            const SizedBox(width: 4),
            Text(
              'PLAY!',
              style: TextStyle(
                fontSize: fontSize,
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

  Widget _buildTutorialButton({required double height, required double fontSize}) {
    return SizedBox(
      height: height,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '📖  TUTORIAL',
              style: TextStyle(
                fontSize: fontSize,
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
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          Text(
            'v$appVersion • The Dungeon Plumbers',
            style: TextStyle(
              fontSize: 10.5,
              color: Colors.white.withValues(alpha: 0.45),
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => AudioDebugDialog.show(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.campaign_rounded, size: 11, color: Color(0xFF38BDF8)),
                    SizedBox(width: 3),
                    Text(
                      'SOUNDS 🧪',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                  ],
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

class _DifficultyCard extends StatelessWidget {
  final String label;
  final String subLabel;
  final bool isShort;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.label,
    required this.subLabel,
    this.isShort = false,
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
        padding: EdgeInsets.symmetric(
          horizontal: 6,
          vertical: isShort ? 6 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : const Color(0xFF243442).withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD54F) : Colors.white.withValues(alpha: 0.15),
            width: isSelected ? 2.0 : 1.0,
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isShort ? 13 : 15,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFFECEFF1),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              style: TextStyle(
                fontSize: isShort ? 10 : 11,
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
