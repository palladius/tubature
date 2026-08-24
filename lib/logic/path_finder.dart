import '../models/direction.dart';
import '../models/grid.dart';
import '../models/position.dart';

/// Encapsulates fluid propagation metadata across the puzzle grid.
class FlowInfo {
  final Map<Position, int> depths;
  final Map<Position, Direction> inflowDirections;

  const FlowInfo({
    required this.depths,
    required this.inflowDirections,
  });
}

class PathFinder {
  /// Returns the set of all positions connected to the starting position (source).
  static Set<Position> findConnected(Grid grid, Position start) {
    return findFlowInfo(grid, start).depths.keys.toSet();
  }

  /// Returns a map of connected tile positions to their BFS depth distance from the source.
  static Map<Position, int> findConnectionDepths(Grid grid, Position start) {
    return findFlowInfo(grid, start).depths;
  }

  /// Returns complete fluid flow information including BFS distance depths
  /// and the exact incoming direction (`inflowDirections`) where water enters each tile.
  static FlowInfo findFlowInfo(Grid grid, Position start) {
    Map<Position, int> depths = {start: 0};
    Map<Position, Direction> inflowDirections = {};
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
          inflowDirections[neighborPos] = dir.opposite;
          queue.add(neighborPos);
        }
      }
    }

    return FlowInfo(depths: depths, inflowDirections: inflowDirections);
  }
}
