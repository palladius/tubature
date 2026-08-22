import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/logic/win_checker.dart';
import 'package:tubature/models/direction.dart';
import 'package:tubature/models/grid.dart';
import 'package:tubature/models/tile.dart';

void main() {
  test('WinChecker win', () {
    final grid = Grid(1, 3, [
      [
        const Tile(type: TileType.source, baseDirection: Direction.east),
        const Tile(type: TileType.line, rotation: 90),
        const Tile(type: TileType.sink, baseDirection: Direction.west),
      ]
    ]);
    expect(WinChecker.checkWin(grid), isTrue);
  });

  test('WinChecker loose', () {
    final grid = Grid(1, 3, [
      [
        const Tile(type: TileType.source, baseDirection: Direction.east),
        const Tile(type: TileType.line, rotation: 0),
        const Tile(type: TileType.sink, baseDirection: Direction.west),
      ]
    ]);
    expect(WinChecker.checkWin(grid), isFalse);
  });
}
