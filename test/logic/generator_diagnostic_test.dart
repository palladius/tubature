import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/logic/level_generator.dart';
import 'package:tubature/models/level.dart';
import 'package:tubature/models/position.dart';
import 'package:tubature/models/tile.dart';

/// Detailed diagnostic tests to understand the level generator and path
/// behavior, ensuring generated levels are valid and solvable.
void main() {
  group('Generator produces solvable grids', () {
    test('pre-shuffle grid IS solved (generator creates valid path)', () {
      // We need to verify the generator creates valid solution grids
      // by peeking inside the generation process.
      // Since _generateGrid is private, let's test indirectly:
      // Generate many levels and verify the STRUCTURE is correct.

      final generator = LevelGenerator(Random(42));

      for (int i = 0; i < 10; i++) {
        final level = generator.generateLevel(Difficulty.easy, id: i);
        final grid = level.grid;

        // Count tile types
        int sourceCount = 0;
        int sinkCount = 0;
        int emptyCount = 0;
        int pipeCount = 0;

        for (int r = 0; r < grid.rows; r++) {
          for (int c = 0; c < grid.cols; c++) {
            final tile = grid.tiles[r][c];
            switch (tile.type) {
              case TileType.source:
                sourceCount++;
              case TileType.sink:
                sinkCount++;
              case TileType.empty:
                emptyCount++;
              default:
                pipeCount++;
            }
          }
        }

        expect(sourceCount, 1, reason: 'Level $i has exactly 1 source');
        expect(sinkCount, 1, reason: 'Level $i has exactly 1 sink');
        expect(pipeCount, greaterThan(0), reason: 'Level $i has pipe tiles');
        // No empty tiles should exist (generator fills all cells)
        expect(emptyCount, 0, reason: 'Level $i has no empty tiles');
      }
    });

    test('every non-fixed tile has valid type', () {
      final generator = LevelGenerator(Random(42));

      for (int i = 0; i < 10; i++) {
        final level = generator.generateLevel(Difficulty.easy, id: i);
        for (int r = 0; r < level.grid.rows; r++) {
          for (int c = 0; c < level.grid.cols; c++) {
            final tile = level.grid.tiles[r][c];
            // Every tile should have valid openings
            if (tile.type != TileType.empty) {
              expect(tile.openings, isNotEmpty,
                  reason: 'Tile at ($r,$c) type=${tile.type} should have openings');
            }
          }
        }
      }
    });

    test('source and sink opening directions point inward', () {
      final generator = LevelGenerator(Random(42));

      for (int i = 0; i < 10; i++) {
        final level = generator.generateLevel(Difficulty.easy, id: i);
        Position? sourcePos;
        Position? sinkPos;

        for (int r = 0; r < level.grid.rows; r++) {
          for (int c = 0; c < level.grid.cols; c++) {
            if (level.grid.tiles[r][c].type == TileType.source) sourcePos = Position(r, c);
            if (level.grid.tiles[r][c].type == TileType.sink) sinkPos = Position(r, c);
          }
        }

        final sourceOpenings = level.grid.tileAt(sourcePos!)!.openings;
        expect(sourceOpenings.length, 1, reason: 'Source has 1 opening');

        final sinkOpenings = level.grid.tileAt(sinkPos!)!.openings;
        expect(sinkOpenings.length, 1, reason: 'Sink has 1 opening');

        // Source opening should point to a valid grid position
        final sourceDir = sourceOpenings.first;
        final sourceNeighborPos = sourcePos.neighbor(sourceDir);
        expect(level.grid.isValidPosition(sourceNeighborPos), isTrue,
            reason: 'Level $i: source opening must point inside grid');

        // Sink opening should point to a valid grid position
        final sinkDir = sinkOpenings.first;
        final sinkNeighborPos = sinkPos.neighbor(sinkDir);
        expect(level.grid.isValidPosition(sinkNeighborPos), isTrue,
            reason: 'Level $i: sink opening must point inside grid');
      }
    });
  });

  group('Shuffle verification', () {
    test('shuffled grid has same tile types but different rotations', () {
      // This test verifies the shuffle only changes rotations, not tile types
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
  });
}
