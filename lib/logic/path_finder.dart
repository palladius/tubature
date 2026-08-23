import '../models/grid.dart';
import '../models/position.dart';

class PathFinder {
  /// Returns the set of all positions connected to the starting position (source).
  static Set<Position> findConnected(Grid grid, Position start) {
    return findConnectionDepths(grid, start).keys.toSet();
  }

  /// Returns a map of connected tile positions to their BFS depth distance from the source.
  /// The source position itself is at depth 0.
  static Map<Position, int> findConnectionDepths(Grid grid, Position start) {
    Map<Position, int> depths = {start: 0};
    List<Position> queue = [start];

    while (queue.isNotEmpty) {
      final currentPos = queue.removeAt(0);
      final currentDepth = depths[currentPos] ?? 0;
      final currentTile = grid.tileAt(currentPos);
      if (currentTile == null) continue;

      for (final dir in currentTile.openings) {
        final neighborPos = currentPos.neighbor(dir);
        if (depths.containsKey(neighborPos)) continue;

        final neighborTile = grid.tileAt(neighborPos);
        if (neighborTile == null) continue;

        if (neighborTile.openings.contains(dir.opposite)) {
          depths[neighborPos] = currentDepth + 1;
          queue.add(neighborPos);
        }
      }
    }

    return depths;
  }
}
