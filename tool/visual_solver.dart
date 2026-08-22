import 'dart:math';
import 'package:tubature/logic/level_generator.dart';
import 'package:tubature/logic/path_finder.dart';
import 'package:tubature/logic/win_checker.dart';
import 'package:tubature/models/direction.dart';
import 'package:tubature/models/grid.dart';
import 'package:tubature/models/level.dart';
import 'package:tubature/models/position.dart';
import 'package:tubature/models/tile.dart';

/// Generates levels and prints ASCII art showing the puzzle and solution.
/// Run with: dart run test/visual_solver.dart
void main() {
  final generator = LevelGenerator(Random(42));

  print('🚰 TUBATURE — Visual Solver Demo\n');
  print('=' * 50);

  // Generate 3 different themed levels
  for (int i = 0; i < 3; i++) {
    final level = generator.generateLevel(Difficulty.easy, id: i);
    final themeName = level.theme.name;

    print('\n🎮 Level ${i + 1} (Easy 5×5) — Theme: $themeName');
    print('─' * 40);

    // Show the shuffled (unsolved) grid
    print('\n📦 Shuffled puzzle:');
    _printGrid(level.grid, level);

    // Verify it's not pre-solved
    final preSolved = WinChecker.checkWin(level.grid);
    print('  Pre-solved: ${preSolved ? "❌ YES (bug!)" : "✅ NO (good!)"}');

    // Now solve it by trying all rotations with DFS
    final solution = _solve(level.grid);
    if (solution != null) {
      print('\n✅ SOLVED! Solution:');
      _printGrid(solution, level);

      // Verify solution
      final isSolved = WinChecker.checkWin(solution);
      print('  Win check: ${isSolved ? "✅ VERIFIED" : "❌ FAILED"}');

      // Show the connected path
      final sourcePos = _findType(solution, TileType.source);
      if (sourcePos != null) {
        final connected = PathFinder.findConnected(solution, sourcePos);
        print('  Connected tiles: ${connected.length}/${solution.rows * solution.cols}');
      }
    } else {
      print('\n❌ NO SOLUTION FOUND (this is a bug!)');
    }

    print('');
  }

  // Also test tutorials
  print('=' * 50);
  print('\n📖 TUTORIAL LEVELS\n');

  for (int t = 1; t <= 5; t++) {
    final level = generator.getTutorialLevel(t);
    final size = level.grid.rows;

    print('Tutorial $t (${size}×$size):');

    final solution = _solve(level.grid);
    if (solution != null) {
      _printGrid(solution, level);
      final isSolved = WinChecker.checkWin(solution);
      print('  ✅ Solvable! Win: $isSolved');
    } else {
      print('  ❌ NOT SOLVABLE');
    }
    print('');
  }
}

void _printGrid(Grid grid, Level level) {
  final sourcePos = _findType(grid, TileType.source);
  final connected = sourcePos != null
      ? PathFinder.findConnected(grid, sourcePos)
      : <Position>{};

  for (int r = 0; r < grid.rows; r++) {
    final row = StringBuffer('  ');
    for (int c = 0; c < grid.cols; c++) {
      final pos = Position(r, c);
      final tile = grid.tileAt(pos)!;
      final isConn = connected.contains(pos);

      String ch = _tileChar(tile);
      if (isConn) {
        ch = '\x1b[32m$ch\x1b[0m'; // Green for connected
      } else if (tile.type == TileType.source || tile.type == TileType.sink) {
        ch = '\x1b[33m$ch\x1b[0m'; // Yellow for source/sink
      }
      row.write(ch);
      row.write(' ');
    }
    print(row);
  }
}

String _tileChar(Tile tile) {
  switch (tile.type) {
    case TileType.source:
      return '⊕';
    case TileType.sink:
      return '⊗';
    case TileType.line:
      return tile.openings.contains(Direction.north) ? '│' : '─';
    case TileType.corner:
      final o = tile.openings;
      if (o.contains(Direction.south) && o.contains(Direction.east)) return '┌';
      if (o.contains(Direction.south) && o.contains(Direction.west)) return '┐';
      if (o.contains(Direction.north) && o.contains(Direction.west)) return '┘';
      if (o.contains(Direction.north) && o.contains(Direction.east)) return '└';
      return '╮';
    case TileType.tee:
      final o = tile.openings;
      if (!o.contains(Direction.west)) return '├';
      if (!o.contains(Direction.east)) return '┤';
      if (!o.contains(Direction.north)) return '┬';
      if (!o.contains(Direction.south)) return '┴';
      return '┼';
    case TileType.cross:
      return '┼';
    case TileType.empty:
      return '·';
  }
}

Position? _findType(Grid grid, TileType type) {
  for (int r = 0; r < grid.rows; r++) {
    for (int c = 0; c < grid.cols; c++) {
      if (grid.tiles[r][c].type == type) return Position(r, c);
    }
  }
  return null;
}

/// DFS solver
Grid? _solve(Grid grid) {
  final positions = <Position>[];
  for (int r = 0; r < grid.rows; r++) {
    for (int c = 0; c < grid.cols; c++) {
      final tile = grid.tiles[r][c];
      if (!tile.isFixed && tile.type != TileType.empty) {
        positions.add(Position(r, c));
      }
    }
  }
  return _dfs(grid, positions, 0);
}

Grid? _dfs(Grid grid, List<Position> positions, int idx) {
  if (WinChecker.checkWin(grid)) return grid;
  if (idx >= positions.length) return null;

  final pos = positions[idx];
  final tile = grid.tileAt(pos)!;

  final rotations = tile.type == TileType.cross
      ? 1
      : tile.type == TileType.line
          ? 2
          : 4;

  var current = grid;
  for (int r = 0; r < rotations; r++) {
    final result = _dfs(current, positions, idx + 1);
    if (result != null) return result;
    current = current.withRotatedTile(pos);
  }
  return null;
}
