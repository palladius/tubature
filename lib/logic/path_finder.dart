
import '../models/grid.dart';
import '../models/position.dart';


class PathFinder {
  static Set<Position> findConnected(Grid grid, Position start) {
    Set<Position> visited = {};
    List<Position> queue = [start];
    visited.add(start);

    while (queue.isNotEmpty) {
      final currentPos = queue.removeAt(0);
      final currentTile = grid.tileAt(currentPos);
      if (currentTile == null) continue;

      for (final dir in currentTile.openings) {
        final neighborPos = currentPos.neighbor(dir);
        if (visited.contains(neighborPos)) continue;

        final neighborTile = grid.tileAt(neighborPos);
        if (neighborTile == null) continue;

        if (neighborTile.openings.contains(dir.opposite)) {
          visited.add(neighborPos);
          queue.add(neighborPos);
        }
      }
    }

    return visited;
  }
}
