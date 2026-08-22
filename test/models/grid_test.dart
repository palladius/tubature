import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/grid.dart';
import 'package:tubature/models/position.dart';
import 'package:tubature/models/tile.dart';

void main() {
  group('Grid', () {
    test('isValidPosition', () {
      final grid = Grid(2, 2, [
        [const Tile(type: TileType.empty), const Tile(type: TileType.empty)],
        [const Tile(type: TileType.empty), const Tile(type: TileType.empty)],
      ]);
      expect(grid.isValidPosition(const Position(0, 0)), isTrue);
      expect(grid.isValidPosition(const Position(2, 2)), isFalse);
      expect(grid.isValidPosition(const Position(-1, 0)), isFalse);
    });

    test('tileAt', () {
      final grid = Grid(1, 1, [[const Tile(type: TileType.line)]]);
      expect(grid.tileAt(const Position(0, 0))?.type, TileType.line);
      expect(grid.tileAt(const Position(1, 1)), isNull);
    });

    test('withRotatedTile', () {
      final grid = Grid(1, 1, [[const Tile(type: TileType.line, rotation: 0)]]);
      final newGrid = grid.withRotatedTile(const Position(0, 0));
      expect(newGrid.tileAt(const Position(0, 0))?.rotation, 90);
      expect(grid.tileAt(const Position(0, 0))?.rotation, 0); // immutable
    });
  });
}
