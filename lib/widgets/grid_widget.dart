import 'package:flutter/material.dart';
import '../models/direction.dart';
import '../models/grid.dart';
import '../models/position.dart';
import '../theme/level_theme.dart';
import 'tile_widget.dart';

/// Widget that displays the full puzzle grid.
///
/// Calculates tile size from available width to ensure tiles are square
/// and large enough for kid-friendly tapping (≥56dp). Centers the grid
/// on screen and supports wave flow depth propagation & victory celebration pulsing.
class GridWidget extends StatelessWidget {
  final Grid grid;
  final Set<Position> connectedTiles;
  final Map<Position, int> connectionDepths;
  final Map<Position, Direction> inflowDirections;
  final bool isVictoryCelebrating;
  final LevelTheme theme;
  final String creatureTheme;
  final void Function(Position) onTileTap;

  const GridWidget({
    super.key,
    required this.grid,
    required this.connectedTiles,
    this.connectionDepths = const {},
    this.inflowDirections = const {},
    this.isVictoryCelebrating = false,
    required this.theme,
    required this.creatureTheme,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate tile size: fill available width with padding
        const horizontalPadding = 16.0;
        final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
        final availableHeight = constraints.maxHeight - (horizontalPadding * 2);

        // Tile size is the minimum of width-based and height-based sizing
        final tileFromWidth = availableWidth / grid.cols;
        final tileFromHeight = availableHeight / grid.rows;
        final tileSize = tileFromWidth < tileFromHeight
            ? tileFromWidth
            : tileFromHeight;

        // Ensure minimum 48dp (Material guideline), prefer 56dp+
        final effectiveTileSize = tileSize.clamp(48.0, double.infinity);

        final gridWidth = effectiveTileSize * grid.cols;
        final gridHeight = effectiveTileSize * grid.rows;

        return Center(
          child: Container(
            width: gridWidth + 4, // slight padding for border
            height: gridHeight + 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: isVictoryCelebrating
                      ? theme.flowColor.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: isVictoryCelebrating ? 24 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(grid.rows, (row) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(grid.cols, (col) {
                      final position = Position(row, col);
                      final tile = grid.tiles[row][col];
                      // Mark tile as connected based on path finder results
                      final isConnected = connectedTiles.contains(position);
                      final depth = connectionDepths[position] ?? 0;
                      final inflowDir = inflowDirections[position];
                      final displayTile = tile.copyWith(isConnected: isConnected);

                      return SizedBox(
                        width: effectiveTileSize,
                        height: effectiveTileSize,
                        child: TileWidget(
                          tile: displayTile,
                          position: position,
                          connectionDepth: depth,
                          inflowDirection: inflowDir,
                          isVictoryCelebrating: isVictoryCelebrating,
                          theme: theme,
                          creatureTheme: creatureTheme,
                          onTap: () => onTileTap(position),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
