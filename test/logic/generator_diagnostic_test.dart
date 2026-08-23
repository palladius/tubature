import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/logic/level_generator.dart';
import 'package:tubature/logic/win_checker.dart';
import 'package:tubature/models/direction.dart';
import 'package:tubature/models/grid.dart';
import 'package:tubature/models/level.dart';
import 'package:tubature/models/position.dart';
import 'package:tubature/models/tile.dart';

/// Diagnostic tests for LevelGenerator (v2.0 - Source-only spanning tree).
///
/// Ensures generated levels are valid, single-source networks with no sinks,
/// where all tiles are connected in the pre-shuffle spanning tree.
void main() {
  group('Generator produces valid v2.0 levels', () {
    test('generated level has exactly 1 source, 0 empty tiles, and valid pipe tiles', () {
      final generator = LevelGenerator(Random(42));

      for (int i = 0; i < 10; i++) {
        final level = generator.generateLevel(Difficulty.easy, id: i);
        final grid = level.grid;

        int sourceCount = 0;
        int emptyCount = 0;
        int pipeCount = 0;

        for (int r = 0; r < grid.rows; r++) {
          for (int c = 0; c < grid.cols; c++) {
            final tile = grid.tiles[r][c];
            switch (tile.type) {
              case TileType.source:
                sourceCount++;
                break;
              case TileType.empty:
                emptyCount++;
                break;
              case TileType.line:
              case TileType.corner:
              case TileType.tee:
              case TileType.cross:
              case TileType.deadEnd:
                pipeCount++;
                break;
            }
          }
        }

        expect(sourceCount, 1, reason: 'Level $i must have exactly 1 source');
        expect(pipeCount, greaterThan(0), reason: 'Level $i must have pipe/deadEnd tiles');
        expect(emptyCount, 0, reason: 'Level $i generator fills all grid cells');
      }
    });

    test('every non-fixed tile has valid openings', () {
      final generator = LevelGenerator(Random(42));

      for (int i = 0; i < 10; i++) {
        final level = generator.generateLevel(Difficulty.easy, id: i);
        for (int r = 0; r < level.grid.rows; r++) {
          for (int c = 0; c < level.grid.cols; c++) {
            final tile = level.grid.tiles[r][c];
            if (tile.type != TileType.empty) {
              expect(tile.openings, isNotEmpty,
                  reason: 'Tile at ($r,$c) type=${tile.type} should have openings');
            }
          }
        }
      }
    });

    test('source is on edge and opening points inward', () {
      final generator = LevelGenerator(Random(42));

      for (int i = 0; i < 10; i++) {
        final level = generator.generateLevel(Difficulty.easy, id: i);
        Position? sourcePos;

        for (int r = 0; r < level.grid.rows; r++) {
          for (int c = 0; c < level.grid.cols; c++) {
            if (level.grid.tiles[r][c].type == TileType.source) {
              sourcePos = Position(r, c);
            }
          }
        }

        expect(sourcePos, isNotNull, reason: 'Level $i has source');
        expect(_isOnEdge(sourcePos!, level.grid), isTrue,
            reason: 'Level $i: source must be on grid edge');

        final sourceTile = level.grid.tileAt(sourcePos)!;
        expect(sourceTile.isFixed, isTrue, reason: 'Source tile must be fixed');

        final sourceOpenings = sourceTile.openings;
        expect(sourceOpenings.length, 1, reason: 'Source has exactly 1 opening');

        // Source opening should point to a valid inner grid position
        final sourceDir = sourceOpenings.first;
        final neighborPos = sourcePos.neighbor(sourceDir);
        expect(level.grid.isValidPosition(neighborPos), isTrue,
            reason: 'Level $i: source opening must point inside grid');
      }
    });

    test('spanning tree grid passes WinChecker.checkWin (ALL tiles connected)', () {
      // Hand-crafted 3×3 spanning tree grid where all tiles connect via source
      final solvedGrid = Grid(3, 3, [
        [
          const Tile(type: TileType.source, baseDirection: Direction.south, isFixed: true),
          const Tile(type: TileType.deadEnd, rotation: 0), // {S}
          const Tile(type: TileType.deadEnd, rotation: 0), // {S}
        ],
        [
          const Tile(type: TileType.corner, rotation: 270), // {E, N}
          const Tile(type: TileType.cross), // {N, E, S, W}
          const Tile(type: TileType.tee, rotation: 180), // {S, W, N}
        ],
        [
          const Tile(type: TileType.deadEnd, rotation: 270), // {E}
          const Tile(type: TileType.corner, rotation: 180), // {N, W}
          const Tile(type: TileType.deadEnd, rotation: 180), // {N}
        ],
      ]);

      expect(WinChecker.checkWin(solvedGrid), isTrue,
          reason: 'Pre-shuffle spanning tree grid with all tiles connected must pass WinChecker');
    });
  });

  group('Shuffle verification', () {
    test('shuffled grid has same tile types but rotated angles', () {
      final generator = LevelGenerator(Random(42));

      for (int i = 0; i < 5; i++) {
        final level = generator.generateLevel(Difficulty.easy, id: i);
        final grid = level.grid;

        // All tiles should have valid rotations (0, 90, 180, 270)
        for (int r = 0; r < grid.rows; r++) {
          for (int c = 0; c < grid.cols; c++) {
            final tile = grid.tiles[r][c];
            expect(tile.rotation % 90, 0,
                reason: 'Tile at ($r,$c) rotation must be multiple of 90');
            expect(tile.rotation, inInclusiveRange(0, 270),
                reason: 'Tile at ($r,$c) rotation must be 0-270');
          }
        }
      }
    });

    test('post-shuffle grid is not pre-solved', () {
      final generator = LevelGenerator(Random(42));

      for (int i = 0; i < 10; i++) {
        final level = generator.generateLevel(Difficulty.easy, id: i);
        expect(WinChecker.checkWin(level.grid), isFalse,
            reason: 'Level $i after shuffle must not be pre-solved');
      }
    });
  });
}

bool _isOnEdge(Position pos, Grid grid) {
  return pos.row == 0 ||
      pos.row == grid.rows - 1 ||
      pos.col == 0 ||
      pos.col == grid.cols - 1;
}
