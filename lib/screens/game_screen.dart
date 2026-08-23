import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/game_notifier.dart';
import '../models/level.dart';
import '../theme/level_theme.dart';
import '../widgets/grid_widget.dart';
import 'victory_overlay.dart';

/// The main game screen — shows the puzzle grid with top bar and hint button.
///
/// Supports two modes:
/// - **Progressive** (default): difficulty increases as you beat levels.
///   Easy (1-3) → Medium (4-7) → Hard (8+)
/// - **Tutorial**: hand-crafted levels 1-10.
class GameScreen extends ConsumerStatefulWidget {
  final Difficulty? difficulty;
  final int? tutorialLevel;

  const GameScreen({
    super.key,
    this.difficulty,
    this.tutorialLevel,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int _currentTutorialLevel = 1;

  @override
  void initState() {
    super.initState();
    // Start game after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGame();
    });
  }

  void _startGame() {
    final notifier = ref.read(gameProvider.notifier);
    if (widget.tutorialLevel != null) {
      _currentTutorialLevel = widget.tutorialLevel!;
      notifier.startTutorial(_currentTutorialLevel);
    } else if (widget.difficulty != null) {
      notifier.startNewGame(widget.difficulty!);
    } else {
      // Start progressive mode
      notifier.startProgressive();
    }
  }

  LevelTheme _getTheme(GameState gameState) {
    if (gameState.currentLevel == null) return LevelTheme.dragonGems;
    switch (gameState.currentLevel!.theme) {
      case CreatureTheme.dragon_gems:
        return LevelTheme.dragonGems;
      case CreatureTheme.wizard_dungeon:
        return LevelTheme.wizardDungeon;
      case CreatureTheme.space_wars:
        return LevelTheme.spaceWars;
    }
  }

  String _getCreatureThemeString(GameState gameState) {
    if (gameState.currentLevel == null) return 'dragon_gems';
    return gameState.currentLevel!.theme.name;
  }

  String _getLevelTitle(GameState gameState) {
    if (widget.tutorialLevel != null) {
      return 'Tutorial $_currentTutorialLevel';
    }
    return 'Level ${gameState.currentLevelNumber}  •  ${gameState.difficultyLabel}';
  }

  void _handleNextLevel() {
    final notifier = ref.read(gameProvider.notifier);
    if (widget.tutorialLevel != null) {
      _currentTutorialLevel++;
      if (_currentTutorialLevel > 10) _currentTutorialLevel = 1;
      notifier.startTutorial(_currentTutorialLevel);
    } else {
      // Progressive: auto-escalate difficulty
      notifier.nextLevel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final levelTheme = _getTheme(gameState);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              levelTheme.backgroundColor,
              levelTheme.backgroundGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main game content
              Column(
                children: [
                  // Top bar
                  _buildTopBar(gameState, levelTheme),
                  // Grid
                  Expanded(
                    child: gameState.grid != null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GridWidget(
                              grid: gameState.grid!,
                              connectedTiles: gameState.connectedTiles,
                              theme: levelTheme,
                              creatureTheme: _getCreatureThemeString(gameState),
                              onTileTap: (pos) {
                                if (!gameState.isComplete) {
                                  ref
                                      .read(gameProvider.notifier)
                                      .rotateTile(pos);
                                }
                              },
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                  // Bottom bar
                  _buildBottomBar(gameState, levelTheme),
                ],
              ),

              // Victory overlay
              if (gameState.isComplete)
                VictoryOverlay(
                  moveCount: gameState.moveCount,
                  onNextLevel: _handleNextLevel,
                  onPlayAgain: () {
                    ref.read(gameProvider.notifier).resetLevel();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(GameState gameState, LevelTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            iconSize: 28,
            color: const Color(0xFF333333),
          ),
          // Level title
          Expanded(
            child: Text(
              _getLevelTitle(gameState),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Move counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, size: 18, color: theme.flowColor),
                const SizedBox(width: 4),
                Text(
                  '${gameState.moveCount}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.flowColorDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Progress indicator: connected/total tiles
          if (gameState.grid != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.water_drop, size: 16, color: theme.flowColor),
                  const SizedBox(width: 4),
                  Text(
                    '${gameState.connectedTiles.length}/${gameState.grid!.rows * gameState.grid!.cols}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.flowColorDark,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(GameState gameState, LevelTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hint button (placeholder)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✨ Hints coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.auto_fix_high),
              iconSize: 28,
              color: theme.flowColor,
              tooltip: 'Hint',
            ),
          ),
          const SizedBox(width: 16),
          // Reset button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                ref.read(gameProvider.notifier).resetLevel();
              },
              icon: const Icon(Icons.refresh_rounded),
              iconSize: 28,
              color: const Color(0xFF888888),
              tooltip: 'Reset',
            ),
          ),
        ],
      ),
    );
  }
}
