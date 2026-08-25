import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/direction.dart';
import '../models/grid.dart';
import '../models/level.dart';
import '../models/position.dart';
import '../models/tile.dart';
import '../models/cauldron_goodie.dart';
import '../services/goodies_image_service.dart';
import 'goodies_assigner.dart';
import 'level_generator.dart';
import 'path_finder.dart';
import 'win_checker.dart';

/// JS interop: bind to window._tubatureGrid for the automated recorder.
/// Top-level @JS declarations bind to globalThis (= window in browsers).
@JS('_tubatureGrid')
external set _jsTubatureGrid(JSString? value);

@JS('_tubatureReady')
external set _jsTubatureReady(JSBoolean? value);

class GameState {
  final Level? currentLevel;
  final Grid? grid;
  final Set<Position> connectedTiles;
  final Map<Position, int> connectionDepths;
  final Map<Position, Direction> inflowDirections;
  final Map<Position, CauldronGoodie> ampolleGoodies;
  final int moveCount;
  final bool isComplete;
  final int levelsCompleted;
  final int currentLevelNumber;
  final Difficulty? chosenDifficulty;

  const GameState({
    this.currentLevel,
    this.grid,
    this.connectedTiles = const {},
    this.connectionDepths = const {},
    this.inflowDirections = const {},
    this.ampolleGoodies = const {},
    this.moveCount = 0,
    this.isComplete = false,
    this.levelsCompleted = 0,
    this.currentLevelNumber = 1,
    this.chosenDifficulty,
  });

  GameState copyWith({
    Level? currentLevel,
    Grid? grid,
    Set<Position>? connectedTiles,
    Map<Position, int>? connectionDepths,
    Map<Position, Direction>? inflowDirections,
    Map<Position, CauldronGoodie>? ampolleGoodies,
    int? moveCount,
    bool? isComplete,
    int? levelsCompleted,
    int? currentLevelNumber,
    Difficulty? chosenDifficulty,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      grid: grid ?? this.grid,
      connectedTiles: connectedTiles ?? this.connectedTiles,
      connectionDepths: connectionDepths ?? this.connectionDepths,
      inflowDirections: inflowDirections ?? this.inflowDirections,
      ampolleGoodies: ampolleGoodies ?? this.ampolleGoodies,
      moveCount: moveCount ?? this.moveCount,
      isComplete: isComplete ?? this.isComplete,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      currentLevelNumber: currentLevelNumber ?? this.currentLevelNumber,
      chosenDifficulty: chosenDifficulty ?? this.chosenDifficulty,
    );
  }

  /// Determine the current difficulty based on chosen setting or progressive escalation.
  Difficulty get progressiveDifficulty {
    if (levelsCompleted < 2) return Difficulty.easy;
    if (levelsCompleted < 5) return Difficulty.medium;
    return Difficulty.hard;
  }

  Difficulty get currentDifficulty {
    if (chosenDifficulty != null) return chosenDifficulty!;
    return progressiveDifficulty;
  }

  String get difficultyLabel {
    switch (currentDifficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}

class GameNotifier extends Notifier<GameState> {
  final LevelGenerator _generator = LevelGenerator();

  @override
  GameState build() {
    if (kIsWeb) {
      try { _jsTubatureReady = true.toJS; } catch (_) {}
    }
    return const GameState();
  }

  void startNewGame(Difficulty difficulty) {
    final level = _generator.generateLevel(difficulty);
    _loadLevel(level, levelNumber: 1, chosenDifficulty: difficulty);
  }

  /// Start a progressive game — difficulty increases as levels are beaten.
  void startProgressive() {
    const initialState = GameState();
    state = initialState;
    final level = _generator.generateLevel(Difficulty.easy);
    _loadLevel(level, levelNumber: 1, chosenDifficulty: null);
  }

  void startTutorial(int levelNumber) {
    final level = _generator.getTutorialLevel(levelNumber);
    _loadLevel(level, levelNumber: levelNumber, chosenDifficulty: null);
  }

  /// Move to the next level with progressive or fixed difficulty.
  void nextLevel() {
    final newCompleted = state.levelsCompleted + 1;
    final newLevelNum = state.currentLevelNumber + 1;

    final Difficulty difficulty = state.chosenDifficulty ??
        (newCompleted < 2
            ? Difficulty.easy
            : newCompleted < 5
                ? Difficulty.medium
                : Difficulty.hard);

    final level = _generator.generateLevel(difficulty, id: newLevelNum);
    // Use _loadLevel to properly assign goodies + preload images
    _loadLevel(level, levelNumber: newLevelNum, chosenDifficulty: state.chosenDifficulty);
    // Preserve levelsCompleted (which _loadLevel doesn't set)
    state = state.copyWith(levelsCompleted: newCompleted);
  }

  void resetLevel() {
    if (state.currentLevel != null) {
      final level = state.currentLevel!;
      final flowInfo = _calculateFlowInfo(level.grid);
      state = state.copyWith(
        grid: level.grid,
        connectedTiles: flowInfo.depths.keys.toSet(),
        connectionDepths: flowInfo.depths,
        inflowDirections: flowInfo.inflowDirections,
        moveCount: 0,
        isComplete: false,
      );
    }
  }

  void _loadLevel(Level level, {int levelNumber = 1, Difficulty? chosenDifficulty}) {
    final flowInfo = _calculateFlowInfo(level.grid);
    
    // Assign goodies to dead ends
    final deadEndPositions = <Position>[];
    for (int r = 0; r < level.grid.rows; r++) {
      for (int c = 0; c < level.grid.cols; c++) {
        if (level.grid.tiles[r][c].type == TileType.deadEnd) {
          deadEndPositions.add(Position(r, c));
        }
      }
    }
    
    final diff = chosenDifficulty ?? state.progressiveDifficulty;
    final assignedGoodies = GoodiesAssigner.assignGoodies(deadEndPositions.length, diff);
    final ampolleGoodies = Map.fromIterables(deadEndPositions, assignedGoodies);
    
    // Preload images async (fire and forget)
    GoodiesImageService.preloadImages(assignedGoodies);

    state = GameState(
      currentLevel: level,
      grid: level.grid,
      connectedTiles: flowInfo.depths.keys.toSet(),
      connectionDepths: flowInfo.depths,
      inflowDirections: flowInfo.inflowDirections,
      ampolleGoodies: ampolleGoodies,
      moveCount: 0,
      isComplete: false,
      levelsCompleted: state.levelsCompleted,
      currentLevelNumber: levelNumber,
      chosenDifficulty: chosenDifficulty ?? state.chosenDifficulty,
    );
    _exportGridToJs();
  }

  void rotateTile(Position pos) {
    if (state.isComplete || state.grid == null) return;
    
    final tile = state.grid!.tileAt(pos);
    if (tile == null || tile.isFixed) return;

    final newGrid = state.grid!.withRotatedTile(pos);
    final flowInfo = _calculateFlowInfo(newGrid);
    final isComplete = WinChecker.checkWin(newGrid);

    state = state.copyWith(
      grid: newGrid,
      connectedTiles: flowInfo.depths.keys.toSet(),
      connectionDepths: flowInfo.depths,
      inflowDirections: flowInfo.inflowDirections,
      moveCount: state.moveCount + 1,
      isComplete: isComplete,
    );
    _exportGridToJs();
  }

  FlowInfo _calculateFlowInfo(Grid grid) {
    Position? sourcePos;
    for (int r = 0; r < grid.rows; r++) {
      for (int c = 0; c < grid.cols; c++) {
        if (grid.tiles[r][c].type == TileType.source) {
          sourcePos = Position(r, c);
          break;
        }
      }
      if (sourcePos != null) break;
    }
    
    if (sourcePos == null) return const FlowInfo(depths: {}, inflowDirections: {});
    return PathFinder.findFlowInfo(grid, sourcePos);
  }

  /// Export grid state to JavaScript for the automated recorder/solver.
  /// Sets window._tubatureGrid as a JSON string on web platforms.
  void _exportGridToJs() {
    if (!kIsWeb) return;
    final grid = state.grid;
    if (grid == null) return;

    final totalTiles = grid.rows * grid.cols;
    final connectedCount = state.connectedTiles.length;

    final solvedGrid = state.currentLevel?.solvedGrid;
    final tiles = <List<Map<String, dynamic>>>[];
    for (int r = 0; r < grid.rows; r++) {
      final row = <Map<String, dynamic>>[];
      for (int c = 0; c < grid.cols; c++) {
        final tile = grid.tiles[r][c];
        final tileData = {
          'type': tile.type.name,
          'rotation': tile.rotation,
          'isFixed': tile.isFixed,
          'baseDirection': tile.baseDirection?.name,
          'isConnected': tile.isConnected,
        };
        // Expose solved rotation for the automated solver ("cheat code")
        if (solvedGrid != null &&
            r < solvedGrid.rows && c < solvedGrid.cols) {
          tileData['solvedRotation'] = solvedGrid.tiles[r][c].rotation;
        }
        row.add(tileData);
      }
      tiles.add(row);
    }

    final data = jsonEncode({
      'rows': grid.rows,
      'cols': grid.cols,
      'tiles': tiles,
      'isComplete': state.isComplete,
      'moveCount': state.moveCount,
      'connectedCount': connectedCount,
      'totalTiles': totalTiles,
      'hasSolution': solvedGrid != null,
    });

    _setTubatureGrid(data);
  }

  /// Reliably set window._tubatureGrid via @JS top-level setter.
  static void _setTubatureGrid(String jsonData) {
    try {
      _jsTubatureGrid = jsonData.toJS;
    } catch (_) {
      // Silently fail on non-web platforms
    }
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});

