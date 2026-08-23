import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/logic/win_checker.dart';
import 'package:tubature/models/direction.dart';
import 'package:tubature/models/grid.dart';
import 'package:tubature/models/tile.dart';

void main() {
  group('WinChecker (v2.0 - All tiles connected)', () {
    test('1x3 grid: all tiles connected = win', () {
      final grid = Grid(1, 3, [
        [
          const Tile(type: TileType.source, baseDirection: Direction.east),
          const Tile(type: TileType.line, rotation: 90), // {E, W}
          const Tile(type: TileType.deadEnd, rotation: 90), // {W}
        ]
      ]);
      expect(WinChecker.checkWin(grid), isTrue);
    });

    test('1x3 grid: middle line disconnected = NOT win', () {
      final grid = Grid(1, 3, [
        [
          const Tile(type: TileType.source, baseDirection: Direction.east),
          const Tile(type: TileType.line, rotation: 0), // {N, S} (misaligned)
          const Tile(type: TileType.deadEnd, rotation: 90), // {W}
        ]
      ]);
      expect(WinChecker.checkWin(grid), isFalse);
    });

    test('2x2 grid: all 4 tiles connected = win', () {
      final grid = Grid(2, 2, [
        [
          const Tile(type: TileType.source, baseDirection: Direction.east), // {E}
          const Tile(type: TileType.corner, rotation: 90), // {W, S}
        ],
        [
          const Tile(type: TileType.deadEnd, rotation: 270), // {E}
          const Tile(type: TileType.corner, rotation: 180), // {N, W}
        ],
      ]);
      expect(WinChecker.checkWin(grid), isTrue);
    });

    test('2x2 grid: 1 tile disconnected = NOT win', () {
      final grid = Grid(2, 2, [
        [
          const Tile(type: TileType.source, baseDirection: Direction.east), // {E}
          const Tile(type: TileType.corner, rotation: 90), // {W, S}
        ],
        [
          const Tile(type: TileType.deadEnd, rotation: 270), // {E}
          const Tile(type: TileType.corner, rotation: 0), // {S, E} (misaligned)
        ],
      ]);
      expect(WinChecker.checkWin(grid), isFalse);
    });

    test('2x2 grid: empty tiles are ignored and only non-empty must connect', () {
      final grid = Grid(2, 2, [
        [
          const Tile(type: TileType.source, baseDirection: Direction.east), // {E}
          const Tile(type: TileType.deadEnd, rotation: 90), // {W}
        ],
        [
          const Tile(type: TileType.empty),
          const Tile(type: TileType.empty),
        ],
      ]);
      expect(WinChecker.checkWin(grid), isTrue);
    });

    test('3x3 branching network: all 5 non-empty tiles connected = win', () {
      final grid = Grid(3, 3, [
        [
          const Tile(type: TileType.empty),
          const Tile(type: TileType.source, baseDirection: Direction.south), // {S}
          const Tile(type: TileType.empty),
        ],
        [
          const Tile(type: TileType.deadEnd, rotation: 270), // {E}
          const Tile(type: TileType.cross), // {N, E, S, W}
          const Tile(type: TileType.deadEnd, rotation: 90), // {W}
        ],
        [
          const Tile(type: TileType.empty),
          const Tile(type: TileType.deadEnd, rotation: 180), // {N}
          const Tile(type: TileType.empty),
        ],
      ]);
      expect(WinChecker.checkWin(grid), isTrue);
    });

    test('3x3 branching network: 1 disconnected leaf = NOT win', () {
      final grid = Grid(3, 3, [
        [
          const Tile(type: TileType.empty),
          const Tile(type: TileType.source, baseDirection: Direction.south), // {S}
          const Tile(type: TileType.empty),
        ],
        [
          const Tile(type: TileType.deadEnd, rotation: 270), // {E}
          const Tile(type: TileType.cross), // {N, E, S, W}
          const Tile(type: TileType.deadEnd, rotation: 90), // {W}
        ],
        [
          const Tile(type: TileType.empty),
          const Tile(type: TileType.deadEnd, rotation: 0), // {S} (misaligned)
          const Tile(type: TileType.empty),
        ],
      ]);
      expect(WinChecker.checkWin(grid), isFalse);
    });

    test('grid with no source tile returns false', () {
      final grid = Grid(2, 2, [
        [
          const Tile(type: TileType.line, rotation: 90),
          const Tile(type: TileType.line, rotation: 90),
        ],
        [
          const Tile(type: TileType.empty),
          const Tile(type: TileType.empty),
        ],
      ]);
      expect(WinChecker.checkWin(grid), isFalse);
    });
  });
}
