import 'dart:math';

import '../models/direction.dart';
import '../models/grid.dart';
import '../models/level.dart';
import '../models/position.dart';
import '../models/tile.dart';
import 'win_checker.dart';

/// Generates levels using a randomized DFS spanning tree.
///
/// Algorithm:
/// 1. Place Source on a random edge cell
/// 2. Run randomized DFS from source's inner neighbor → visits EVERY cell
/// 3. Each cell gets a tile type based on its tree connections
/// 4. Shuffle rotations to create the puzzle
/// 5. Verify: pre-shuffle = solvable, post-shuffle = not solved
class LevelGenerator {
  final Random _random;

  LevelGenerator([Random? random]) : _random = random ?? Random();

  Level generateLevel(Difficulty difficulty, {int? id}) {
    int size = 5;
    if (difficulty == Difficulty.easy) {
      size = 5;
    } else if (difficulty == Difficulty.medium) {
      size = _random.nextBool() ? 6 : 7;
    } else {
      size = 8;
    }

    final theme = CreatureTheme.values[_random.nextInt(CreatureTheme.values.length)];

    while (true) {
      final grid = _generateSpanningTreeGrid(size, size);
      if (grid == null) continue;

      // Verify solution is valid BEFORE shuffling
      if (!WinChecker.checkWin(grid)) continue;

      final shuffledGrid = _shuffleGrid(grid);
      if (!WinChecker.checkWin(shuffledGrid)) {
        return Level(
          id: id ?? _random.nextInt(1000000),
          difficulty: difficulty,
          grid: shuffledGrid,
          theme: theme,
        );
      }
      // If still solved after shuffle, try again
    }
  }

  /// Generate a grid where ALL tiles are connected via a spanning tree.
  ///
  /// Uses randomized DFS (recursive backtracker) to create a tree
  /// that visits every cell exactly once. Then assigns tile types
  /// based on each cell's connections in the tree.
  Grid? _generateSpanningTreeGrid(int rows, int cols) {
    // 1. Pick Source on an edge
    Position sourcePos = _getRandomEdgePosition(rows, cols);
    Direction sourceDir = _getInwardDirection(sourcePos, rows, cols);

    // 2. Build spanning tree using randomized DFS
    // The tree is represented as a map: position → set of connected neighbor directions
    Map<Position, Set<Direction>> treeConnections = {};
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        treeConnections[Position(r, c)] = {};
      }
    }

    // Start DFS from the source's inner neighbor
    Position startPos = sourcePos.neighbor(sourceDir);
    if (!_isValid(startPos, rows, cols)) return null;

    // Add connection: source → startPos
    treeConnections[sourcePos]!.add(sourceDir);
    treeConnections[startPos]!.add(sourceDir.opposite);

    // DFS from startPos to cover all remaining cells
    Set<Position> visited = {sourcePos, startPos};
    _dfsSpanningTree(startPos, rows, cols, visited, treeConnections);

    // Verify all cells are visited
    if (visited.length != rows * cols) return null;

    // 3. Assign tile types based on tree connections
    List<List<Tile>> tiles = List.generate(
      rows,
      (r) => List.generate(cols, (c) {
        final pos = Position(r, c);
        final connections = treeConnections[pos]!;

        if (pos == sourcePos) {
          return Tile(
            type: TileType.source,
            baseDirection: sourceDir,
            isFixed: true,
          );
        }

        return _tileFromConnections(connections);
      }),
    );

    return Grid(rows, cols, tiles);
  }

  /// Randomized DFS to build a spanning tree.
  void _dfsSpanningTree(
    Position current,
    int rows,
    int cols,
    Set<Position> visited,
    Map<Position, Set<Direction>> connections,
  ) {
    // Shuffle directions for randomness
    final dirs = List.of(Direction.values)..shuffle(_random);

    for (final dir in dirs) {
      final neighbor = current.neighbor(dir);
      if (!_isValid(neighbor, rows, cols)) continue;
      if (visited.contains(neighbor)) continue;

      // Add bidirectional tree edge
      connections[current]!.add(dir);
      connections[neighbor]!.add(dir.opposite);
      visited.add(neighbor);

      // Recurse
      _dfsSpanningTree(neighbor, rows, cols, visited, connections);
    }
  }

  /// Convert a set of connected directions into the correct tile type + rotation.
  Tile _tileFromConnections(Set<Direction> connections) {
    final count = connections.length;

    if (count == 1) {
      // Dead end (cap) — 1 opening
      final dir = connections.first;
      return Tile(
        type: TileType.deadEnd,
        rotation: _rotationForDeadEnd(dir),
      );
    } else if (count == 2) {
      final dirs = connections.toList();
      // Check if they're opposite (line) or adjacent (corner)
      if (dirs[0] == dirs[1].opposite) {
        // Line tile
        return Tile(
          type: TileType.line,
          rotation: _rotationForLine(dirs[0], dirs[1]),
        );
      } else {
        // Corner tile
        return Tile(
          type: TileType.corner,
          rotation: _rotationForCorner(connections),
        );
      }
    } else if (count == 3) {
      // Tee tile
      return Tile(
        type: TileType.tee,
        rotation: _rotationForTee(connections),
      );
    } else if (count == 4) {
      // Cross tile (all 4 directions)
      return const Tile(type: TileType.cross);
    }

    // Fallback — should never happen
    return const Tile(type: TileType.line);
  }

  /// Dead-end base opening is South at rotation 0.
  int _rotationForDeadEnd(Direction openDir) {
    switch (openDir) {
      case Direction.south: return 0;
      case Direction.west: return 90;
      case Direction.north: return 180;
      case Direction.east: return 270;
    }
  }

  /// Line base openings are {N, S} at rotation 0.
  int _rotationForLine(Direction a, Direction b) {
    final dirs = {a, b};
    if (dirs.contains(Direction.north) && dirs.contains(Direction.south)) return 0;
    return 90; // E-W
  }

  /// Corner base openings are {S, E} at rotation 0.
  int _rotationForCorner(Set<Direction> dirs) {
    if (dirs.contains(Direction.south) && dirs.contains(Direction.east)) return 0;
    if (dirs.contains(Direction.south) && dirs.contains(Direction.west)) return 90;
    if (dirs.contains(Direction.north) && dirs.contains(Direction.west)) return 180;
    if (dirs.contains(Direction.north) && dirs.contains(Direction.east)) return 270;
    return 0; // fallback
  }

  /// Tee base openings are {N, E, S} at rotation 0 (missing W).
  int _rotationForTee(Set<Direction> dirs) {
    if (!dirs.contains(Direction.west)) return 0;   // N, E, S → rot 0
    if (!dirs.contains(Direction.north)) return 90;  // E, S, W → rot 90
    if (!dirs.contains(Direction.east)) return 180;  // N, S, W → rot 180
    if (!dirs.contains(Direction.south)) return 270; // N, E, W → rot 270
    return 0; // fallback
  }

  Grid _shuffleGrid(Grid original) {
    List<List<Tile>> newTiles = List.generate(
      original.rows,
      (r) => List.generate(original.cols, (c) {
        Tile t = original.tiles[r][c];
        if (t.isFixed || t.type == TileType.empty) return t;
        // For cross tiles (4-way symmetric), skip — rotating does nothing
        if (t.type == TileType.cross) return t;
        int rotations = _random.nextInt(3) + 1; // 1 to 3 rotations
        for (int i = 0; i < rotations; i++) {
          t = t.rotate();
        }
        return t;
      }),
    );
    return Grid(original.rows, original.cols, newTiles);
  }

  Position _getRandomEdgePosition(int rows, int cols) {
    int edge = _random.nextInt(4);
    if (edge == 0) return Position(0, _random.nextInt(cols)); // top
    if (edge == 1) {
      return Position(rows - 1, _random.nextInt(cols)); // bottom
    }
    if (edge == 2) return Position(_random.nextInt(rows), 0); // left
    return Position(_random.nextInt(rows), cols - 1); // right
  }

  Direction _getInwardDirection(Position pos, int rows, int cols) {
    if (pos.row == 0) return Direction.south;
    if (pos.row == rows - 1) return Direction.north;
    if (pos.col == 0) return Direction.east;
    return Direction.west;
  }

  bool _isValid(Position pos, int rows, int cols) {
    return pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols;
  }

  Level getTutorialLevel(int number) {
    int size = number <= 3 ? 3 : (number <= 6 ? 4 : 5);
    while (true) {
      final grid = _generateSpanningTreeGrid(size, size);
      if (grid != null && WinChecker.checkWin(grid)) {
        final shuffledGrid = _shuffleGrid(grid);
        if (!WinChecker.checkWin(shuffledGrid)) {
          return Level(
            id: number,
            difficulty: Difficulty.easy,
            grid: shuffledGrid,
            theme: CreatureTheme.dragon_gems,
          );
        }
      }
    }
  }
}
