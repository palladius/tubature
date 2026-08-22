import '../models/grid.dart';
import '../models/position.dart';
import '../models/tile.dart';
import 'path_finder.dart';

class WinChecker {
  static bool checkWin(Grid grid) {
    Position? sourcePos;
    Position? sinkPos;

    for (int r = 0; r < grid.rows; r++) {
      for (int c = 0; c < grid.cols; c++) {
        final tile = grid.tiles[r][c];
        if (tile.type == TileType.source) {
          sourcePos = Position(r, c);
        } else if (tile.type == TileType.sink) {
          sinkPos = Position(r, c);
        }
      }
    }

    if (sourcePos == null || sinkPos == null) return false;

    final connected = PathFinder.findConnected(grid, sourcePos);
    return connected.contains(sinkPos);
  }
}
