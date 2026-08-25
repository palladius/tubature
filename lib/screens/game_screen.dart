import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/game_notifier.dart';
import '../models/cauldron_goodie.dart';
import '../models/cauldron_goodies_catalog.dart';
import '../models/position.dart';
import '../models/tile.dart';
import '../models/level.dart';
import '../services/goodies_image_service.dart';
import '../services/audio_service.dart';
import '../theme/level_theme.dart';
import '../widgets/audio_debug_dialog.dart';
import '../widgets/grid_widget.dart';
import '../widgets/talking_avatar_widget.dart';
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

  // Keyboard navigation state
  final FocusNode _gameFocusNode = FocusNode();
  Position? _focusedTile;
  bool _keyboardActive = false;
  bool _zoomKeyHeld = false; // H key held → zoom goodie preview

  // Revealed goodies badges 🏅 (shown at full opacity for 15s)
  final List<CauldronGoodie> _activeBadges = [];
  final Map<String, Timer> _badgeTimers = {}; // keyed by goodie.id

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
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _victoryTimer?.cancel();
    _gameFocusNode.dispose();
    for (final t in _badgeTimers.values) {
      t.cancel();
    }
    super.dispose();
  }

  /// Called when a goodie finishes its reveal animation — show badge 🏅
  void _onGoodieRevealed(CauldronGoodie goodie, Position pos) {
    if (_activeBadges.any((g) => g.id == goodie.id)) return; // already shown

    // Delay badge appearance by 3s so the ampolla animation (8.5s total)
    // finishes before the badge shows. The reveal timer fires at 6s,
    // so badge appears at 6s + 3s = 9s — just after the full reveal.
    // BUG FIX (2026-08-25): badge was spoiling the surprise by appearing
    // before the ampolla image was fully visible.
    _badgeTimers[goodie.id] = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _activeBadges.add(goodie);
        });
      }
      _badgeTimers.remove(goodie.id);
    });
    // Badges are PERMANENT — stay visible until level change or replay.
    // _clearBadges() handles cleanup.
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

  /// Handle keyboard input for tile navigation, rotation, and zoom (H key).
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // Handle H key release (zoom off)
    if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyH) {
        setState(() => _zoomKeyHeld = false);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    // H key held → zoom preview on focused tile 🔍
    if (event.logicalKey == LogicalKeyboardKey.keyH) {
      setState(() {
        _zoomKeyHeld = true;
        _keyboardActive = true;
      });
      return KeyEventResult.handled;
    }

    final gameState = ref.read(gameProvider);
    final grid = gameState.grid;
    if (grid == null || gameState.isComplete) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // Navigation: arrows + WASD
    int dr = 0, dc = 0;
    if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
      dr = -1;
    } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
      dr = 1;
    } else if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      dc = -1;
    } else if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
      dc = 1;
    }

    if (dr != 0 || dc != 0) {
      setState(() {
        _keyboardActive = true;
        final cur = _focusedTile ?? const Position(0, 0);
        // Toroidal wrapping — Pac-Man style 🟡
        final newRow = (cur.row + dr) % grid.rows;
        final newCol = (cur.col + dc) % grid.cols;
        _focusedTile = Position(newRow, newCol);
      });
      return KeyEventResult.handled;
    }

    // Rotation: Space (CW), Shift+Space (CCW)
    if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.enter) {
      final pos = _focusedTile ?? const Position(0, 0);
      if (!_keyboardActive) {
        setState(() {
          _keyboardActive = true;
          _focusedTile = pos;
        });
        return KeyEventResult.handled;
      }
      final notifier = ref.read(gameProvider.notifier);
      if (HardwareKeyboard.instance.isShiftPressed) {
        // Counter-clockwise = 3 clockwise rotations
        notifier.rotateTile(pos);
        notifier.rotateTile(pos);
        notifier.rotateTile(pos);
      } else {
        notifier.rotateTile(pos);
      }
      return KeyEventResult.handled;
    }

    // R = reset
    if (key == LogicalKeyboardKey.keyR) {
      ref.read(gameProvider.notifier).resetLevel();
      return KeyEventResult.handled;
    }

    // Escape = go back
    if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  String _getLevelTitle(GameState gameState) {
    if (widget.tutorialLevel != null) {
      return 'Tutorial $_currentTutorialLevel';
    }
    return 'Level ${gameState.currentLevelNumber}  •  ${gameState.difficultyLabel}';
  }

  void _handleNextLevel() {
    _victoryTimer?.cancel();
    _clearBadges();
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
    _clearBadges();
    setState(() => _showVictoryOverlay = false);
    ref.read(gameProvider.notifier).resetLevel();
  }

  void _clearBadges() {
    for (final t in _badgeTimers.values) {
      t.cancel();
    }
    _badgeTimers.clear();
    _activeBadges.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for victory to trigger sound and 3-second admiration delay
    ref.listen<GameState>(gameProvider, (previous, next) {
      if ((previous == null || !previous.isComplete) && next.isComplete) {
        AudioService.playVictoryFanfare();
        final ampollaCount = next.grid?.tiles.expand((row) => row).where((t) => t.type == TileType.deadEnd).length ?? 0;
        AudioService.playVictoryVoice(ampollaCount: ampollaCount);

        _victoryTimer?.cancel();
        setState(() => _showVictoryOverlay = false);
        _victoryTimer = Timer(const Duration(milliseconds: 2800), () {
          if (mounted && next.isComplete) {
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

    return Focus(
      focusNode: _gameFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
      body: GestureDetector(
        // Hide keyboard focus on touch/pointer
        onTapDown: (_) {
          if (_keyboardActive) setState(() => _keyboardActive = false);
        },
        child: Container(
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
                              inflowDirections: gameState.inflowDirections,
                              ampolleGoodies: gameState.ampolleGoodies,
                              isVictoryCelebrating: gameState.isComplete,
                              theme: levelTheme,
                              creatureTheme: _getCreatureThemeString(gameState),
                              focusedTile: _keyboardActive ? _focusedTile : null,
                              isZoomKeyHeld: _zoomKeyHeld,
                              onGoodieRevealed: _onGoodieRevealed,
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

              // 🏅 Revealed goodies badges — full opacity, right side
              if (_activeBadges.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 56,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _activeBadges.map((goodie) {
                      final ui.Image? img = GoodiesImageService.getImage(goodie.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: goodie.isLegendary
                                  ? const Color(0xFFFFD700)
                                  : levelTheme.flowColor,
                              width: goodie.isLegendary ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (goodie.isLegendary
                                        ? const Color(0xFFFFD700)
                                        : levelTheme.flowColor)
                                    .withValues(alpha: 0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: img != null
                                ? RawImage(image: img, fit: BoxFit.cover)
                                : Center(
                                    child: Text(goodie.emoji,
                                        style: const TextStyle(fontSize: 28))),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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

              // Floating Talking Avatar Overlay (Ermete da Ferrara)
              const Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: TalkingAvatarWidget(),
                ),
              ),

              // Victory overlay (appears after 2.8s admiration window)
              if (gameState.isComplete && _showVictoryOverlay)
                VictoryOverlay(
                  moveCount: gameState.moveCount,
                  revealedGoodies: gameState.ampolleGoodies.values.toList(),
                  onNextLevel: _handleNextLevel,
                  onPlayAgain: _handlePlayAgain,
                ),
            ],
          ),
        ),
      ), // Container
      ), // GestureDetector
      ), // Scaffold
    ); // Focus
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
          // 🐞 DEBUG: Show all goodies catalog (LOCALHOST ONLY)
          if (_isLocalhost())
            IconButton(
              onPressed: () => _showGoodiesCatalogDebug(context),
              icon: const Icon(Icons.collections_bookmark, color: Colors.purple, size: 20),
              tooltip: '🐞 Goodies Catalog (Debug)',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          // Audio debug soundboard button
          IconButton(
            onPressed: () => AudioDebugDialog.show(context),
            icon: const Icon(Icons.campaign_rounded, color: Color(0xFF38BDF8), size: 22),
            tooltip: 'Audio Soundboard 🧪',
          ),
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

  /// Only true on localhost — debug features hidden in production.
  bool _isLocalhost() {
    if (!kIsWeb) return false;
    final host = Uri.base.host;
    return host == 'localhost' || host == '127.0.0.1' || host == '::1';
  }

  /// Debug dialog showing all goodies with rarity and probability.
  void _showGoodiesCatalogDebug(BuildContext context) {
    final allGoodies = CauldronGoodiesCatalog.all;
    final totalWeight = allGoodies.fold<int>(0, (s, g) => s + g.rarity.weight);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🐞 Goodies Catalog'),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total weight: $totalWeight',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                ...allGoodies.map((g) {
                  final pct = (g.rarity.weight / totalWeight * 100).toStringAsFixed(1);
                  final img = GoodiesImageService.getImage(g.id);
                  final rarityColor = switch (g.rarity) {
                    GoodieRarity.common => Colors.grey,
                    GoodieRarity.uncommon => Colors.green,
                    GoodieRarity.rare => Colors.blue,
                    GoodieRarity.legendary => const Color(0xFFFFD700),
                  };
                  return ListTile(
                    dense: true,
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: ClipOval(
                        child: img != null
                            ? RawImage(image: img, fit: BoxFit.cover)
                            : Text(g.emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    title: Text(g.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(
                      '${g.rarity.name.toUpperCase()} • w:${g.rarity.weight} • $pct%',
                      style: TextStyle(fontSize: 11, color: rarityColor, fontWeight: FontWeight.bold),
                    ),
                    trailing: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: rarityColor,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(GameState gameState, LevelTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: SizedBox(
        height: 36,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hint button
            SizedBox(
              width: 36,
              height: 36,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
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
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  color: theme.flowColor,
                  tooltip: 'Hint',
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Reset button
            SizedBox(
              width: 36,
              height: 36,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    AudioService.playFailureVoice();
                    ref.read(gameProvider.notifier).resetLevel();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  color: const Color(0xFF888888),
                  tooltip: 'Reset',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
