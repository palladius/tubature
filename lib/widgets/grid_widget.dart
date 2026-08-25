import 'dart:async';
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
/// Goodies zoom: hover/H-key/long-press shows 3x preview.
/// Gate: tile must be connected AND 8 seconds must have passed since connection.
/// Once revealed, stays revealed even if pipe is broken.
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
  final bool isZoomKeyHeld;
  final void Function(CauldronGoodie goodie, Position pos)? onGoodieRevealed;

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
    this.isZoomKeyHeld = false,
    this.onGoodieRevealed,
  });

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  Position? _hoveredTile;
  Position? _longPressedTile;

  // Persistent set: once an ampolla is revealed, it stays revealed
  final Set<Position> _revealed = {};
  // Timers waiting the 8s before revealing
  final Map<Position, Timer> _pendingTimers = {};
  // Positions that already have a timer started (to avoid duplicates)
  final Set<Position> _timerStarted = {};

  @override
  void didUpdateWidget(covariant GridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect level change: if ampolleGoodies keys changed, reset everything
    if (!_sameKeys(widget.ampolleGoodies, oldWidget.ampolleGoodies)) {
      _resetAll();
    }

    // Start timers for newly connected goodie tiles
    _checkForNewConnections();
  }

  @override
  void dispose() {
    for (final t in _pendingTimers.values) {
      t.cancel();
    }
    super.dispose();
  }

  bool _sameKeys(Map<Position, CauldronGoodie> a, Map<Position, CauldronGoodie> b) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k)) return false;
    }
    return true;
  }

  void _resetAll() {
    for (final t in _pendingTimers.values) {
      t.cancel();
    }
    _pendingTimers.clear();
    _timerStarted.clear();
    _revealed.clear();
    _hoveredTile = null;
    _longPressedTile = null;
  }

  void _checkForNewConnections() {
    for (final pos in widget.ampolleGoodies.keys) {
      // Only start timer if: tile is connected AND no timer started yet AND not already revealed
      if (widget.connectedTiles.contains(pos) &&
          !_timerStarted.contains(pos) &&
          !_revealed.contains(pos)) {
        _timerStarted.add(pos);
        _pendingTimers[pos] = Timer(const Duration(seconds: 6), () {
          if (mounted) {
            setState(() => _revealed.add(pos));
            // Notify parent to show badge 🏅
            final goodie = widget.ampolleGoodies[pos];
            if (goodie != null) {
              widget.onGoodieRevealed?.call(goodie, pos);
            }
          }
          _pendingTimers.remove(pos);
        });
      }
    }
  }

  /// Can we show zoom for this position?
  bool _canZoom(Position pos) {
    // Victory: all goodie tiles are zoomable
    if (widget.isVictoryCelebrating && widget.ampolleGoodies.containsKey(pos)) {
      return true;
    }
    // During gameplay: only if revealed (8s after water arrived)
    return _revealed.contains(pos);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 16.0;
        final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
        final availableHeight = constraints.maxHeight - (horizontalPadding * 2);

        final tileFromWidth = availableWidth / widget.grid.cols;
        final tileFromHeight = availableHeight / widget.grid.rows;
        final tileSize = tileFromWidth < tileFromHeight ? tileFromWidth : tileFromHeight;
        final effectiveTileSize = tileSize.clamp(48.0, double.infinity);

        final gridWidth = effectiveTileSize * widget.grid.cols;
        final gridHeight = effectiveTileSize * widget.grid.rows;

        // Determine zoom target: long press > hover > H-key focus
        Position? zoomTile = _longPressedTile ?? _hoveredTile;
        if (zoomTile == null && widget.isZoomKeyHeld && widget.focusedTile != null) {
          zoomTile = widget.focusedTile;
        }

        // Final gate: can we actually zoom this tile?
        final showZoom = zoomTile != null && _canZoom(zoomTile);
        final zoomGoodie = showZoom ? widget.ampolleGoodies[zoomTile] : null;
        final zoomImage = zoomGoodie != null
            ? GoodiesImageService.getImage(zoomGoodie.id)
            : null;

        return Center(
          child: SizedBox(
            width: gridWidth + 4,
            height: gridHeight + 4,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ─── Grid ───
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
                            final zoomable = _canZoom(position);

                            final isFocused = widget.focusedTile != null &&
                                widget.focusedTile!.row == row &&
                                widget.focusedTile!.col == col;

                            return SizedBox(
                              width: effectiveTileSize,
                              height: effectiveTileSize,
                              child: MouseRegion(
                                onEnter: (_) {
                                  // STRICT: only allow hover if zoomable
                                  if (goodie != null && zoomable) {
                                    setState(() => _hoveredTile = position);
                                  }
                                },
                                onExit: (_) {
                                  if (_hoveredTile == position) {
                                    setState(() => _hoveredTile = null);
                                  }
                                },
                                child: GestureDetector(
                                  onLongPressStart: goodie != null && zoomable
                                      ? (_) => setState(() => _longPressedTile = position)
                                      : null,
                                  onLongPressEnd: goodie != null
                                      ? (_) => setState(() => _longPressedTile = null)
                                      : null,
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
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ),

                // ─── Zoom overlay 🔍 ───
                if (zoomTile != null && zoomImage != null)
                  Positioned(
                    left: 2 + zoomTile.col * effectiveTileSize - effectiveTileSize,
                    top: 2 + zoomTile.row * effectiveTileSize - effectiveTileSize,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.27,
                        child: Container(
                          width: effectiveTileSize * 3,
                          height: effectiveTileSize * 3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.theme.flowColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                                spreadRadius: 1,
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
