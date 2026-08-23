import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/game_notifier.dart';
import '../models/level.dart';
import '../services/audio_service.dart';
import '../theme/level_theme.dart';
import '../widgets/grid_widget.dart';
import 'victory_overlay.dart';

/// The main game screen — shows the puzzle grid with top bar, fluid propagation,
/// interactive sound effects, and victory admiration lock.
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
  bool _showVictoryOverlay = false;
  Timer? _victoryTimer;

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait during gameplay for optimal pipe puzzle view
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Start game after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGame();
    });
  }

  @override
  void dispose() {
    // Restore free orientation rotation when leaving the game screen
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _victoryTimer?.cancel();
    super.dispose();
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
      case CreatureTheme.crystal_caves:
        return LevelTheme.crystalCaves;
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
    _victoryTimer?.cancel();
    setState(() => _showVictoryOverlay = false);
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

  void _handlePlayAgain() {
    _victoryTimer?.cancel();
    setState(() => _showVictoryOverlay = false);
    ref.read(gameProvider.notifier).resetLevel();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for victory to trigger sound and 3-second admiration delay
    ref.listen<GameState>(gameProvider, (previous, next) {
      if ((previous == null || !previous.isComplete) && next.isComplete) {
        AudioService.playVictoryFanfare();
        _victoryTimer?.cancel();
        setState(() => _showVictoryOverlay = false);
        _victoryTimer = Timer(const Duration(milliseconds: 2800), () {
          if (mounted) {
            setState(() => _showVictoryOverlay = true);
          }
        });
      } else if (previous != null && previous.isComplete && !next.isComplete) {
        _victoryTimer?.cancel();
        if (_showVictoryOverlay) {
          setState(() => _showVictoryOverlay = false);
        }
      }
    });

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
                              connectionDepths: gameState.connectionDepths,
                              isVictoryCelebrating: gameState.isComplete,
                              theme: levelTheme,
                              creatureTheme: _getCreatureThemeString(gameState),
                              onTileTap: (pos) {
                                // Locked if level is complete
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

              // Floating Admiration Banner during the 3-second celebration window
              if (gameState.isComplete && !_showVictoryOverlay)
                Positioned(
                  top: 70,
                  left: 24,
                  right: 24,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: levelTheme.flowColor.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars_rounded, color: levelTheme.flowColor, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'ALL PIPES CONNECTED! 🌊✨',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: levelTheme.flowColorDark,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Victory overlay (appears after 2.8s admiration window)
              if (gameState.isComplete && _showVictoryOverlay)
                VictoryOverlay(
                  moveCount: gameState.moveCount,
                  onNextLevel: _handleNextLevel,
                  onPlayAgain: _handlePlayAgain,
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
          const SizedBox(width: 4),
          // Audio mute toggle
          IconButton(
            onPressed: () {
              setState(() {
                AudioService.toggleMute();
              });
            },
            icon: Icon(
              AudioService.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: AudioService.isMuted ? Colors.grey.shade400 : theme.flowColorDark,
              size: 22,
            ),
            tooltip: AudioService.isMuted ? 'Unmute Sound' : 'Mute Sound',
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
          // Hint button
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
