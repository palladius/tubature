import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/direction.dart';
import 'package:tubature/models/tile.dart';

void main() {
  group('Tile Openings', () {
    test('line rotation 0', () {
      const t = Tile(type: TileType.line, rotation: 0);
      expect(t.openings, {Direction.north, Direction.south});
    });
    test('line rotation 90', () {
      const t = Tile(type: TileType.line, rotation: 90);
      expect(t.openings, {Direction.east, Direction.west});
    });
    test('corner rotation 0', () {
      const t = Tile(type: TileType.corner, rotation: 0);
      expect(t.openings, {Direction.south, Direction.east});
    });
    test('tee rotation 90', () {
      const t = Tile(type: TileType.tee, rotation: 90);
      expect(t.openings, {Direction.east, Direction.south, Direction.west});
    });
    test('cross rotation 0', () {
      const t = Tile(type: TileType.cross, rotation: 0);
      expect(t.openings, {Direction.north, Direction.east, Direction.south, Direction.west});
    });
    test('source', () {
      const t = Tile(type: TileType.source, baseDirection: Direction.north);
      expect(t.openings, {Direction.north});
    });
    test('empty', () {
      const t = Tile(type: TileType.empty);
      expect(t.openings, isEmpty);
    });
  });

  group('Tile rotate', () {
    test('rotate increases rotation by 90', () {
      const t = Tile(type: TileType.line, rotation: 0);
      expect(t.rotate().rotation, 90);
      expect(t.rotate().rotate().rotation, 180);
      expect(t.rotate().rotate().rotate().rotate().rotation, 0);
    });
    test('fixed tile does not rotate', () {
      const t = Tile(type: TileType.source, rotation: 0, isFixed: true);
      expect(t.rotate().rotation, 0);
    });
  });
}
