import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grid.dart';
import '../models/level.dart';
import '../models/position.dart';
import '../models/tile.dart';
import 'level_generator.dart';
import 'path_finder.dart';
import 'win_checker.dart';

class GameState {
  final Level? currentLevel;
  final Grid? grid;
  final Set<Position> connectedTiles;
  final int moveCount;
  final bool isComplete;
  final int levelsCompleted;
  final int currentLevelNumber;

  const GameState({
    this.currentLevel,
    this.grid,
    this.connectedTiles = const {},
    this.moveCount = 0,
    this.isComplete = false,
    this.levelsCompleted = 0,
    this.currentLevelNumber = 1,
  });

  GameState copyWith({
    Level? currentLevel,
    Grid? grid,
    Set<Position>? connectedTiles,
    int? moveCount,
    bool? isComplete,
    int? levelsCompleted,
    int? currentLevelNumber,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      grid: grid ?? this.grid,
      connectedTiles: connectedTiles ?? this.connectedTiles,
      moveCount: moveCount ?? this.moveCount,
      isComplete: isComplete ?? this.isComplete,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      currentLevelNumber: currentLevelNumber ?? this.currentLevelNumber,
    );
  }

  /// Determine the current difficulty based on levels completed.
  /// 
  /// Progression (aggressive — kids said it was too easy!):
  /// - Levels 1-2: Easy (6×6)
  /// - Levels 3-5: Medium (7×7 or 8×8)
  /// - Levels 6+: Hard (9×9 or 10×10)
  Difficulty get progressiveDifficulty {
    if (levelsCompleted < 2) return Difficulty.easy;
    if (levelsCompleted < 5) return Difficulty.medium;
    return Difficulty.hard;
  }

  String get difficultyLabel {
    switch (progressiveDifficulty) {
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
    return const GameState();
  }

  void startNewGame(Difficulty difficulty) {
    final level = _generator.generateLevel(difficulty);
    _loadLevel(level, levelNumber: 1);
  }

  /// Start a progressive game — difficulty increases as levels are beaten.
  void startProgressive() {
    const initialState = GameState();
    state = initialState;
    final level = _generator.generateLevel(Difficulty.easy);
    _loadLevel(level, levelNumber: 1);
  }

  void startTutorial(int levelNumber) {
    final level = _generator.getTutorialLevel(levelNumber);
    _loadLevel(level, levelNumber: levelNumber);
  }

  /// Move to the next level with progressive difficulty.
  void nextLevel() {
    final newCompleted = state.levelsCompleted + 1;
    final newLevelNum = state.currentLevelNumber + 1;

    // Determine difficulty based on progression
    final Difficulty difficulty;
    if (newCompleted < 3) {
      difficulty = Difficulty.easy;
    } else if (newCompleted < 7) {
      difficulty = Difficulty.medium;
    } else {
      difficulty = Difficulty.hard;
    }

    final level = _generator.generateLevel(difficulty, id: newLevelNum);
    final connected = _calculateConnected(level.grid);
    state = GameState(
      currentLevel: level,
      grid: level.grid,
      connectedTiles: connected,
      moveCount: 0,
      isComplete: false,
      levelsCompleted: newCompleted,
      currentLevelNumber: newLevelNum,
    );
  }

  void resetLevel() {
    if (state.currentLevel != null) {
      final level = state.currentLevel!;
      final connected = _calculateConnected(level.grid);
      state = state.copyWith(
        grid: level.grid,
        connectedTiles: connected,
        moveCount: 0,
        isComplete: false,
      );
    }
  }

  void _loadLevel(Level level, {int levelNumber = 1}) {
    final connected = _calculateConnected(level.grid);
    state = GameState(
      currentLevel: level,
      grid: level.grid,
      connectedTiles: connected,
      moveCount: 0,
      isComplete: false,
      levelsCompleted: state.levelsCompleted,
      currentLevelNumber: levelNumber,
    );
  }

  void rotateTile(Position pos) {
    if (state.isComplete || state.grid == null) return;
    
    final tile = state.grid!.tileAt(pos);
    if (tile == null || tile.isFixed) return;

    final newGrid = state.grid!.withRotatedTile(pos);
    final connected = _calculateConnected(newGrid);
    final isComplete = WinChecker.checkWin(newGrid);

    state = state.copyWith(
      grid: newGrid,
      connectedTiles: connected,
      moveCount: state.moveCount + 1,
      isComplete: isComplete,
    );
  }

  Set<Position> _calculateConnected(Grid grid) {
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
    
    if (sourcePos == null) return {};
    return PathFinder.findConnected(grid, sourcePos);
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});
