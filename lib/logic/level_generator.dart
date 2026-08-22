import 'dart:math';

import '../models/direction.dart';
import '../models/grid.dart';
import '../models/level.dart';
import '../models/position.dart';
import '../models/tile.dart';
import 'win_checker.dart';

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
      final grid = _generateGrid(size, size);
      if (grid != null) {
        // Verify solution is valid BEFORE shuffling
        if (!WinChecker.checkWin(grid)) continue; // bad generation

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
  }

  Grid? _generateGrid(int rows, int cols) {
    // 1. Initialize empty grid
    List<List<Tile>> tiles = List.generate(
      rows,
      (r) => List.generate(cols, (c) => const Tile(type: TileType.empty)),
    );

    // 2. Pick Source on an edge
    Position sourcePos = _getRandomEdgePosition(rows, cols);
    Direction sourceDir = _getInwardDirection(sourcePos, rows, cols);
    tiles[sourcePos.row][sourcePos.col] = Tile(
      type: TileType.source,
      baseDirection: sourceDir,
      isFixed: true,
    );

    // 3. Pick Sink on another edge (ensure distance)
    Position sinkPos;
    Direction sinkDir;
    int attempts = 0;
    do {
      sinkPos = _getRandomEdgePosition(rows, cols);
      attempts++;
    } while ((_manhattan(sourcePos, sinkPos) < (rows + cols) ~/ 2 ||
              sinkPos == sourcePos) &&
        attempts < 100);

    sinkDir = _getInwardDirection(sinkPos, rows, cols);
    tiles[sinkPos.row][sinkPos.col] = Tile(
      type: TileType.sink,
      baseDirection: sinkDir, // sink opens inward to receive flow
      isFixed: true,
    );

    // 4. Find path from the source's neighbor (following its opening)
    //    to the sink's neighbor (arriving at its opening)
    //    This ensures the path connects through the correct openings.
    Position sourceNeighbor = sourcePos.neighbor(sourceDir);
    Position sinkNeighbor = sinkPos.neighbor(sinkDir);

    if (!_isValid(sourceNeighbor, rows, cols) ||
        !_isValid(sinkNeighbor, rows, cols)) {
      return null;
    }

    // BFS from sourceNeighbor to sinkNeighbor, avoiding source and sink
    List<Position> innerPath = _findPath(
      sourceNeighbor,
      sinkNeighbor,
      rows,
      cols,
      avoid: {sourcePos, sinkPos},
    );
    if (innerPath.isEmpty) return null;

    // Full path: source → innerPath → sink
    List<Position> fullPath = [sourcePos, ...innerPath, sinkPos];

    // 5. Place correct tiles along the inner path
    for (int i = 1; i < fullPath.length - 1; i++) {
      Position prev = fullPath[i - 1];
      Position curr = fullPath[i];
      Position next = fullPath[i + 1];

      Direction from = _getDirection(curr, prev);
      Direction to = _getDirection(curr, next);

      tiles[curr.row][curr.col] = _createTileFromDirections({from, to});
    }

    // 6. Fill remaining empty tiles with random pipe tiles
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (tiles[r][c].type == TileType.empty) {
          tiles[r][c] = _getRandomTile();
        }
      }
    }

    return Grid(rows, cols, tiles);
  }

  Grid _shuffleGrid(Grid original) {
    List<List<Tile>> newTiles = List.generate(
      original.rows,
      (r) => List.generate(original.cols, (c) {
        Tile t = original.tiles[r][c];
        if (t.isFixed || t.type == TileType.empty) return t;
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

  int _manhattan(Position p1, Position p2) {
    return (p1.row - p2.row).abs() + (p1.col - p2.col).abs();
  }

  bool _isValid(Position pos, int rows, int cols) {
    return pos.row >= 0 && pos.row < rows && pos.col >= 0 && pos.col < cols;
  }

  List<Position> _findPath(
    Position start,
    Position end,
    int rows,
    int cols, {
    Set<Position> avoid = const {},
  }) {
    // BFS for pathfinding
    Map<Position, Position> cameFrom = {};
    List<Position> queue = [start];
    Set<Position> visited = {start, ...avoid};

    while (queue.isNotEmpty) {
      Position current = queue.removeAt(0);
      if (current == end) {
        List<Position> path = [];
        Position? temp = current;
        while (temp != null) {
          path.add(temp);
          temp = cameFrom[temp];
        }
        return path.reversed.toList();
      }

      // Shuffle directions to create more interesting paths
      final dirs = List.of(Direction.values)..shuffle(_random);
      for (Direction dir in dirs) {
        Position next = current.neighbor(dir);
        if (_isValid(next, rows, cols) && !visited.contains(next)) {
          visited.add(next);
          cameFrom[next] = current;
          queue.add(next);
        }
      }
    }
    return [];
  }

  Direction _getDirection(Position from, Position to) {
    if (to.row < from.row) return Direction.north;
    if (to.row > from.row) return Direction.south;
    if (to.col < from.col) return Direction.west;
    return Direction.east;
  }

  Tile _createTileFromDirections(Set<Direction> dirs) {
    if (dirs.length == 2) {
      if (dirs.contains(Direction.north) && dirs.contains(Direction.south)) {
        return const Tile(type: TileType.line, rotation: 0);
      }
      if (dirs.contains(Direction.east) && dirs.contains(Direction.west)) {
        return const Tile(type: TileType.line, rotation: 90);
      }
      // Corners
      if (dirs.contains(Direction.south) && dirs.contains(Direction.east)) {
        return const Tile(type: TileType.corner, rotation: 0);
      }
      if (dirs.contains(Direction.south) && dirs.contains(Direction.west)) {
        return const Tile(type: TileType.corner, rotation: 90);
      }
      if (dirs.contains(Direction.north) && dirs.contains(Direction.west)) {
        return const Tile(type: TileType.corner, rotation: 180);
      }
      if (dirs.contains(Direction.north) && dirs.contains(Direction.east)) {
        return const Tile(type: TileType.corner, rotation: 270);
      }
    }
    return const Tile(type: TileType.line); // fallback
  }

  Tile _getRandomTile() {
    // No cross tiles — they're rotationally symmetric (rotating does nothing)
    // and confuse players. Only line, corner, and tee.
    List<TileType> types = [
      TileType.line,
      TileType.corner,
      TileType.tee,
    ];
    TileType type = types[_random.nextInt(types.length)];
    return Tile(type: type, rotation: _random.nextInt(4) * 90);
  }

  Level getTutorialLevel(int number) {
    int size = number <= 3 ? 3 : (number <= 6 ? 4 : 5);
    while (true) {
      final grid = _generateGrid(size, size);
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
