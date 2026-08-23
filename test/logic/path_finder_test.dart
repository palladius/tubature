import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/logic/path_finder.dart';
import 'package:tubature/models/direction.dart';
import 'package:tubature/models/grid.dart';
import 'package:tubature/models/position.dart';
import 'package:tubature/models/tile.dart';

void main() {
  test('PathFinder findConnected', () {
    final grid = Grid(2, 2, [
      [
        const Tile(type: TileType.source, baseDirection: Direction.east),
        const Tile(type: TileType.line, rotation: 90), // E-W
      ],
      [
        const Tile(type: TileType.empty),
        const Tile(type: TileType.empty),
      ]
    ]);

    final connected = PathFinder.findConnected(grid, const Position(0, 0));
    expect(connected.contains(const Position(0, 0)), isTrue);
    expect(connected.contains(const Position(0, 1)), isTrue);
    expect(connected.length, 2);
  });

  test('PathFinder no connection', () {
    final grid = Grid(2, 2, [
      [
        const Tile(type: TileType.source, baseDirection: Direction.east),
        const Tile(type: TileType.line, rotation: 0), // N-S
      ],
      [
        const Tile(type: TileType.empty),
        const Tile(type: TileType.empty),
      ]
    ]);

    final connected = PathFinder.findConnected(grid, const Position(0, 0));
    expect(connected.contains(const Position(0, 0)), isTrue);
    expect(connected.contains(const Position(0, 1)), isFalse);
    expect(connected.length, 1);
  });

  test('PathFinder findConnectionDepths calculates progressive BFS distance', () {
    // 3x1 grid: [Source ->] [Line E-W] [Line E-W]
    final grid = Grid(1, 3, [
      [
        const Tile(type: TileType.source, baseDirection: Direction.east),
        const Tile(type: TileType.line, rotation: 90), // E-W
        const Tile(type: TileType.line, rotation: 90), // E-W
      ]
    ]);

    final depths = PathFinder.findConnectionDepths(grid, const Position(0, 0));
    expect(depths[const Position(0, 0)], 0);
    expect(depths[const Position(0, 1)], 1);
    expect(depths[const Position(0, 2)], 2);
  });
}
