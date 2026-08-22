import 'package:flutter/material.dart';
import '../models/tile.dart';
import '../models/position.dart';
import '../theme/level_theme.dart';
import 'pipe_painter.dart';
import 'creature_painter.dart';

/// Widget for a single tile in the puzzle grid.
///
/// Handles tap interaction (rotate on tap), rotation animation (200ms),
/// and visual feedback (scale pulse). Source/Sink tiles don't rotate.
class TileWidget extends StatefulWidget {
  final Tile tile;
  final Position position;
  final LevelTheme theme;
  final String creatureTheme;
  final VoidCallback? onTap;

  const TileWidget({
    super.key,
    required this.tile,
    required this.position,
    required this.theme,
    required this.creatureTheme,
    this.onTap,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.tile.isFixed) return;
    if (widget.onTap == null) return;

    // Scale pulse feedback
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate rotation in turns (0.0 to 1.0) from rotation degrees
    final rotationTurns = widget.tile.rotation / 360.0;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: widget.theme.tileBackground,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.tile.isConnected
                  ? widget.theme.flowColor.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Stack(
            children: [
              // Pipe layer with rotation animation
              AnimatedRotation(
                turns: rotationTurns,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: CustomPaint(
                  painter: PipePainter(
                    tile: widget.tile.copyWith(rotation: 0),
                    theme: widget.theme,
                  ),
                  size: Size.infinite,
                ),
              ),
              // Creature overlay for source/sink
              if (widget.tile.type == TileType.source)
                Positioned.fill(
                  child: CustomPaint(
                    painter: CreaturePainter(
                      creatureType: _getSourceCreature(),
                      theme: widget.theme,
                      isConnected: widget.tile.isConnected,
                    ),
                  ),
                ),
              if (widget.tile.type == TileType.sink)
                Positioned.fill(
                  child: CustomPaint(
                    painter: CreaturePainter(
                      creatureType: _getSinkCreature(),
                      theme: widget.theme,
                      isConnected: widget.tile.isConnected,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  CreatureType _getSourceCreature() {
    switch (widget.creatureTheme) {
      case 'wizard_dungeon':
        return CreatureType.wizard;
      case 'space_wars':
        return CreatureType.rocket;
      case 'dragon_gems':
      default:
        return CreatureType.dragon;
    }
  }

  CreatureType _getSinkCreature() {
    switch (widget.creatureTheme) {
      case 'wizard_dungeon':
        return CreatureType.dungeon;
      case 'space_wars':
        return CreatureType.starship;
      case 'dragon_gems':
      default:
        return CreatureType.gems;
    }
  }
}
