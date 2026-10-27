import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:tubature/logic/level_generator.dart';
import 'package:tubature/logic/path_finder.dart';
import 'package:tubature/logic/win_checker.dart';
import 'package:tubature/models/direction.dart';
import 'package:tubature/models/grid.dart';
import 'package:tubature/models/level.dart';
import 'package:tubature/models/position.dart';
import 'package:tubature/models/tile.dart';

const String version = '2.12.0';

String tileToAscii(Tile tile) {
  final o = tile.openings;
  switch (tile.type) {
    case TileType.source:
      return '🐉';
    case TileType.deadEnd:
      if (o.contains(Direction.north)) return '▲';
      if (o.contains(Direction.south)) return '▼';
      if (o.contains(Direction.east)) return '►';
      if (o.contains(Direction.west)) return '◄';
      return '◄';
    case TileType.line:
      return o.contains(Direction.north) || o.contains(Direction.south) ? '║' : '═';
    case TileType.corner:
      if (o.contains(Direction.south) && o.contains(Direction.east)) return '╔';
      if (o.contains(Direction.south) && o.contains(Direction.west)) return '╗';
      if (o.contains(Direction.north) && o.contains(Direction.west)) return '╝';
      if (o.contains(Direction.north) && o.contains(Direction.east)) return '╚';
      return '╔';
    case TileType.tee:
      if (!o.contains(Direction.west)) return '╠';
      if (!o.contains(Direction.east)) return '╣';
      if (!o.contains(Direction.north)) return '╦';
      if (!o.contains(Direction.south)) return '╩';
      return '╬';
    case TileType.cross:
      return '╬';
    case TileType.empty:
      return '·';
  }
}

Position? findSourcePosition(Grid grid) {
  for (int r = 0; r < grid.rows; r++) {
    for (int c = 0; c < grid.cols; c++) {
      if (grid.tiles[r][c].type == TileType.source) {
        return Position(r, c);
      }
    }
  }
  return null;
}

String renderBoard({
  required Grid grid,
  required Position? cursor,
  required int moves,
  required String difficultyName,
  required int levelNumber,
}) {
  final buffer = StringBuffer();
  final sourcePos = findSourcePosition(grid);
  final connected = sourcePos != null
      ? PathFinder.findConnected(grid, sourcePos)
      : <Position>{};
  final totalTiles = grid.rows * grid.cols;
  final connectedCount = connected.length;

  buffer.writeln('\x1b[2J\x1b[H'); // Clear screen and move cursor to top-left
  buffer.writeln('┌──────────────────────────────────────────┐');
  buffer.writeln('│  🚰 TUBATURE CLI v$version  $difficultyName (${grid.rows}×${grid.cols})'.padRight(43) + '│');
  buffer.writeln('│  Moves: $moves   Connected: $connectedCount/$totalTiles   Lvl: $levelNumber'.padRight(43) + '│');
  buffer.writeln('├──────────────────────────────────────────┤');

  for (int r = 0; r < grid.rows; r++) {
    buffer.write('│  ');
    for (int c = 0; c < grid.cols; c++) {
      final pos = Position(r, c);
      final tile = grid.tileAt(pos)!;
      final isConn = connected.contains(pos);
      final isCursor = cursor != null && cursor.row == r && cursor.col == c;

      String ch = tileToAscii(tile);

      if (isCursor) {
        // Highlight cursor tile
        buffer.write('\x1b[7m[$ch]\x1b[0m ');
      } else if (isConn) {
        // Green for connected
        buffer.write(' \x1b[32;1m$ch\x1b[0m  ');
      } else if (tile.type == TileType.source) {
        // Yellow for source
        buffer.write(' \x1b[33;1m$ch\x1b[0m  ');
      } else {
        // Gray/white for disconnected
        buffer.write(' \x1b[90m$ch\x1b[0m  ');
      }
    }
    buffer.writeln('│');
  }

  buffer.writeln('├──────────────────────────────────────────┤');
  buffer.writeln('│  Controls: [←↑↓→/WASD] Move   [Space] Rotate │');
  buffer.writeln('│  [R] Reset   [H] Hint/Solve   [Q] Quit      │');
  buffer.writeln('└──────────────────────────────────────────┘');

  return buffer.toString();
}

/// Recursive DFS solver
Grid? solveGrid(Grid grid) {
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

void runDemo() {
  print('🚰 Tubature CLI Text Mode — Automated Demo & Verification');
  print('========================================================');
  final generator = LevelGenerator(Random(12345));
  final level = generator.generateLevel(Difficulty.easy, id: 1);

  print('\n📦 Generated Easy 5×5 Puzzle:');
  print(renderBoard(
    grid: level.grid,
    cursor: const Position(0, 0),
    moves: 0,
    difficultyName: 'Easy',
    levelNumber: 1,
  ));

  print('🔍 Solving puzzle with DFS...');
  final solved = solveGrid(level.grid);
  if (solved != null && WinChecker.checkWin(solved)) {
    print('✅ Puzzle solved successfully!');
    print(renderBoard(
      grid: solved,
      cursor: null,
      moves: 9,
      difficultyName: 'Easy (Solved)',
      levelNumber: 1,
    ));
    print('🎉 WIN CHECK PASSED: All pipes connected to source!\n');
    exit(0);
  } else {
    print('❌ Failed to solve puzzle.');
    exit(1);
  }
}

Future<void> main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    print('''
Tubature CLI Text Mode v$version
Usage:
  dart run tool/cli_play.dart [options]

Options:
  --difficulty <easy|medium|hard>  Set level difficulty (default: easy)
  --seed <number>                  Set random seed
  --demo                           Run automated solver demo and exit
  --help, -h                       Show this help message
''');
    return;
  }

  if (args.contains('--demo') || args.contains('--verify')) {
    runDemo();
    return;
  }

  Difficulty difficulty = Difficulty.easy;
  String diffName = 'Easy';
  if (args.contains('--difficulty')) {
    final idx = args.indexOf('--difficulty');
    if (idx + 1 < args.length) {
      final val = args[idx + 1].toLowerCase();
      if (val == 'medium') {
        difficulty = Difficulty.medium;
        diffName = 'Medium';
      } else if (val == 'hard') {
        difficulty = Difficulty.hard;
        diffName = 'Hard';
      }
    }
  }

  int seed = DateTime.now().millisecondsSinceEpoch;
  if (args.contains('--seed')) {
    final idx = args.indexOf('--seed');
    if (idx + 1 < args.length) {
      seed = int.tryParse(args[idx + 1]) ?? seed;
    }
  }

  final generator = LevelGenerator(Random(seed));
  int levelNum = 1;
  Level currentLevel = generator.generateLevel(difficulty, id: levelNum);
  Grid grid = currentLevel.grid;
  Position cursor = const Position(0, 0);
  int moves = 0;

  if (!stdin.hasTerminal) {
    print('Non-interactive terminal detected. Running demo mode...');
    runDemo();
    return;
  }

  stdin.echoMode = false;
  stdin.lineMode = false;

  void draw() {
    stdout.write(renderBoard(
      grid: grid,
      cursor: cursor,
      moves: moves,
      difficultyName: diffName,
      levelNumber: levelNum,
    ));
  }

  void cleanup() {
    try {
      stdin.lineMode = true;
      stdin.echoMode = true;
    } catch (_) {}
  }

  ProcessSignal.sigint.watch().listen((_) {
    cleanup();
    print('\nGoodbye! 👋\n');
    exit(0);
  });

  draw();

  await for (final charCodes in stdin) {
    if (charCodes.isEmpty) continue;

    if (charCodes.length >= 3 && charCodes[0] == 27 && charCodes[1] == 91) {
      final key = charCodes[2];
      if (key == 65 && cursor.row > 0) {
        cursor = Position(cursor.row - 1, cursor.col);
      } else if (key == 66 && cursor.row < grid.rows - 1) {
        cursor = Position(cursor.row + 1, cursor.col);
      } else if (key == 67 && cursor.col < grid.cols - 1) {
        cursor = Position(cursor.row, cursor.col + 1);
      } else if (key == 68 && cursor.col > 0) {
        cursor = Position(cursor.row, cursor.col - 1);
      }
      draw();
      continue;
    }

    final code = charCodes[0];
    final char = String.fromCharCode(code).toLowerCase();

    if (char == 'q' || code == 3) {
      cleanup();
      print('\nThanks for playing Tubature CLI! 🚰👋\n');
      return;
    } else if (char == 'w' && cursor.row > 0) {
      cursor = Position(cursor.row - 1, cursor.col);
    } else if (char == 's' && cursor.row < grid.rows - 1) {
      cursor = Position(cursor.row + 1, cursor.col);
    } else if (char == 'a' && cursor.col > 0) {
      cursor = Position(cursor.row, cursor.col - 1);
    } else if (char == 'd' && cursor.col < grid.cols - 1) {
      cursor = Position(cursor.row, cursor.col + 1);
    } else if (char == ' ' || code == 10 || code == 13) {
      final currentTile = grid.tileAt(cursor);
      if (currentTile != null && !currentTile.isFixed && currentTile.type != TileType.empty) {
        grid = grid.withRotatedTile(cursor);
        moves++;
      }
    } else if (char == 'r') {
      grid = currentLevel.grid;
      moves = 0;
    } else if (char == 'h') {
      final solution = solveGrid(grid);
      if (solution != null) {
        grid = solution;
        moves += 5;
      }
    }

    draw();

    if (WinChecker.checkWin(grid)) {
      stdout.write('''
\x1b[32;1m
🎉 ============================================== 🎉
   ALDAMARJE! LEVEL $levelNum COMPLETED IN $moves MOVES!
   Mo và là che la ditta Spurghi Bottazzi ringrazia!
🎉 ============================================== 🎉
\x1b[0m
Press [Space] for Next Level or [Q] to Quit: ''');

      final nextCharCodes = await stdin.first;
      if (nextCharCodes.isNotEmpty) {
        final nextChar = String.fromCharCode(nextCharCodes[0]).toLowerCase();
        if (nextChar == 'q') {
          cleanup();
          print('\nArrivederci! 👋\n');
          return;
        }
      }

      levelNum++;
      currentLevel = generator.generateLevel(difficulty, id: levelNum);
      grid = currentLevel.grid;
      moves = 0;
      cursor = const Position(0, 0);
      draw();
    }
  }

  cleanup();
}
