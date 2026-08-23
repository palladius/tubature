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
  final Map<Position, int> connectionDepths;
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
    final depths = _calculateConnectionDepths(level.grid);
    state = GameState(
      currentLevel: level,
      grid: level.grid,
      connectedTiles: depths.keys.toSet(),
      connectionDepths: depths,
      moveCount: 0,
      isComplete: false,
      levelsCompleted: newCompleted,
      currentLevelNumber: newLevelNum,
      chosenDifficulty: state.chosenDifficulty,
    );
  }

  void resetLevel() {
    if (state.currentLevel != null) {
      final level = state.currentLevel!;
      final depths = _calculateConnectionDepths(level.grid);
      state = state.copyWith(
        grid: level.grid,
        connectedTiles: depths.keys.toSet(),
        connectionDepths: depths,
        moveCount: 0,
        isComplete: false,
      );
    }
  }

  void _loadLevel(Level level, {int levelNumber = 1, Difficulty? chosenDifficulty}) {
    final depths = _calculateConnectionDepths(level.grid);
    state = GameState(
      currentLevel: level,
      grid: level.grid,
      connectedTiles: depths.keys.toSet(),
      connectionDepths: depths,
      moveCount: 0,
      isComplete: false,
      levelsCompleted: state.levelsCompleted,
      currentLevelNumber: levelNumber,
      chosenDifficulty: chosenDifficulty ?? state.chosenDifficulty,
    );
  }

  void rotateTile(Position pos) {
    if (state.isComplete || state.grid == null) return;
    
    final tile = state.grid!.tileAt(pos);
    if (tile == null || tile.isFixed) return;

    final newGrid = state.grid!.withRotatedTile(pos);
    final depths = _calculateConnectionDepths(newGrid);
    final isComplete = WinChecker.checkWin(newGrid);

    state = state.copyWith(
      grid: newGrid,
      connectedTiles: depths.keys.toSet(),
      connectionDepths: depths,
      moveCount: state.moveCount + 1,
      isComplete: isComplete,
    );
  }

  Map<Position, int> _calculateConnectionDepths(Grid grid) {
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
    return PathFinder.findConnectionDepths(grid, sourcePos);
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(() {
  return GameNotifier();
});
