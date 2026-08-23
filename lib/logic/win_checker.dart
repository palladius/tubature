import '../models/grid.dart';
import '../models/position.dart';
import '../models/tile.dart';
import 'path_finder.dart';

class WinChecker {
  /// Check if ALL non-empty tiles on the grid are connected to the source.
  ///
  /// Win condition: every single tile must be reachable from the source
  /// through matching pipe openings. There is no sink — the entire
  /// grid must be filled with water.
  static bool checkWin(Grid grid) {
    Position? sourcePos;
    int totalTiles = 0;

    for (int r = 0; r < grid.rows; r++) {
      for (int c = 0; c < grid.cols; c++) {
        final tile = grid.tiles[r][c];
        if (tile.type != TileType.empty) {
          totalTiles++;
          if (tile.type == TileType.source) {
            sourcePos = Position(r, c);
          }
        }
      }
    }

    if (sourcePos == null) return false;

    final connected = PathFinder.findConnected(grid, sourcePos);
    return connected.length == totalTiles;
  }
}
