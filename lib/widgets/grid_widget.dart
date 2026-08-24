import 'package:flutter/material.dart';
import '../models/direction.dart';
import '../models/grid.dart';
import '../models/position.dart';
import '../models/cauldron_goodie.dart';
import '../services/goodies_image_service.dart';
import '../theme/level_theme.dart';
import 'tile_widget.dart';

/// Widget that displays the full puzzle grid.
///
/// Calculates tile size from available width to ensure tiles are square
/// and large enough for kid-friendly tapping (≥56dp). Centers the grid
/// on screen and supports wave flow depth propagation & victory celebration pulsing.
/// Dead-end tiles with goodies show a hover/focus zoom preview (3x).
class GridWidget extends StatefulWidget {
  final Grid grid;
  final Set<Position> connectedTiles;
  final Map<Position, int> connectionDepths;
  final Map<Position, Direction> inflowDirections;
  final Map<Position, CauldronGoodie> ampolleGoodies;
  final bool isVictoryCelebrating;
  final LevelTheme theme;
  final String creatureTheme;
  final void Function(Position) onTileTap;
  final Position? focusedTile;

  const GridWidget({
    super.key,
    required this.grid,
    required this.connectedTiles,
    this.connectionDepths = const {},
    this.inflowDirections = const {},
    this.ampolleGoodies = const {},
    this.isVictoryCelebrating = false,
    required this.theme,
    required this.creatureTheme,
    required this.onTileTap,
    this.focusedTile,
  });

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  Position? _hoveredTile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate tile size: fill available width with padding
        const horizontalPadding = 16.0;
        final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
        final availableHeight = constraints.maxHeight - (horizontalPadding * 2);

        // Tile size is the minimum of width-based and height-based sizing
        final tileFromWidth = availableWidth / widget.grid.cols;
        final tileFromHeight = availableHeight / widget.grid.rows;
        final tileSize = tileFromWidth < tileFromHeight
            ? tileFromWidth
            : tileFromHeight;

        // Ensure minimum 48dp (Material guideline), prefer 56dp+
        final effectiveTileSize = tileSize.clamp(48.0, double.infinity);

        final gridWidth = effectiveTileSize * widget.grid.cols;
        final gridHeight = effectiveTileSize * widget.grid.rows;

        // Determine which tile should show zoom (hover or keyboard focus on goodie tile)
        final zoomTile = _hoveredTile ?? widget.focusedTile;
        final zoomGoodie = zoomTile != null ? widget.ampolleGoodies[zoomTile] : null;
        final zoomImage = zoomGoodie != null ? GoodiesImageService.getImage(zoomGoodie.id) : null;

        return Center(
          child: SizedBox(
            width: gridWidth + 4,
            height: gridHeight + 4,
            child: Stack(
              clipBehavior: Clip.none, // allow zoom overlay to extend beyond grid
              children: [
                // Main grid
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isVictoryCelebrating
                            ? widget.theme.flowColor.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.08),
                        blurRadius: widget.isVictoryCelebrating ? 24 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.grid.rows, (row) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(widget.grid.cols, (col) {
                            final position = Position(row, col);
                            final tile = widget.grid.tiles[row][col];
                            final isConnected = widget.connectedTiles.contains(position);
                            final depth = widget.connectionDepths[position] ?? 0;
                            final inflowDir = widget.inflowDirections[position];
                            final displayTile = tile.copyWith(isConnected: isConnected);
                            final goodie = widget.ampolleGoodies[position];

                            final isFocused = widget.focusedTile != null &&
                                widget.focusedTile!.row == row &&
                                widget.focusedTile!.col == col;

                            return SizedBox(
                              width: effectiveTileSize,
                              height: effectiveTileSize,
                              child: MouseRegion(
                                onEnter: (_) {
                                  if (goodie != null) {
                                    setState(() => _hoveredTile = position);
                                  }
                                },
                                onExit: (_) {
                                  if (_hoveredTile == position) {
                                    setState(() => _hoveredTile = null);
                                  }
                                },
                                child: Stack(
                                  children: [
                                    TileWidget(
                                      tile: displayTile,
                                      position: position,
                                      connectionDepth: depth,
                                      inflowDirection: inflowDir,
                                      goodie: goodie,
                                      isVictoryCelebrating: widget.isVictoryCelebrating,
                                      theme: widget.theme,
                                      creatureTheme: widget.creatureTheme,
                                      onTap: () => widget.onTileTap(position),
                                    ),
                                    // Keyboard focus ring ⌨️
                                    if (isFocused)
                                      Positioned.fill(
                                        child: IgnorePointer(
                                          child: Container(
                                            margin: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: widget.theme.flowColor,
                                                width: 3,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: widget.theme.flowColor.withValues(alpha: 0.6),
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ),

                // Hover/Focus zoom overlay for goodies 🔍
                if (zoomTile != null && zoomImage != null)
                  Positioned(
                    // Center the 3x zoom on the hovered tile, offset by 2px grid border
                    left: 2 + zoomTile.col * effectiveTileSize - effectiveTileSize,
                    top: 2 + zoomTile.row * effectiveTileSize - effectiveTileSize,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: effectiveTileSize * 3,
                          height: effectiveTileSize * 3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.theme.flowColor.withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: RawImage(
                              image: zoomImage,
                              fit: BoxFit.cover,
                              width: effectiveTileSize * 3,
                              height: effectiveTileSize * 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
