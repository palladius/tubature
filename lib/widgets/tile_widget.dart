import 'dart:math';
import 'package:flutter/material.dart';
import '../models/direction.dart';
import '../models/tile.dart';
import '../models/position.dart';
import '../models/cauldron_goodie.dart';
import '../services/audio_service.dart';
import '../services/goodies_image_service.dart';
import '../theme/level_theme.dart';
import 'pipe_painter.dart';
import 'creature_painter.dart';

/// Widget for a single tile in the puzzle grid.
///
/// Features:
/// - Smooth rotation animation (200ms) with tap scale bounce
/// - Organic liquid fluid flow propagation with turbulent chaos jitter
/// - Continuous fluid shimmer and moving bubbles
/// - Victory pulse celebration
class TileWidget extends StatefulWidget {
  final Tile tile;
  final Position position;
  final LevelTheme theme;
  final String creatureTheme;
  final int connectionDepth;
  final Direction? inflowDirection;
  final CauldronGoodie? goodie;
  final bool isVictoryCelebrating;
  final VoidCallback? onTap;

  const TileWidget({
    super.key,
    required this.tile,
    required this.position,
    required this.theme,
    required this.creatureTheme,
    this.connectionDepth = 0,
    this.inflowDirection,
    this.goodie,
    this.isVictoryCelebrating = false,
    this.onTap,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _flowController;
  late Animation<double> _flowAnimation;

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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

    _flowController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _flowAnimation = CurvedAnimation(
      parent: _flowController,
      curve: Curves.easeInOut,
    );

    // Continuous dynamic living river current & shimmer (60 FPS)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.tile.isConnected) {
      _shimmerController.repeat();
      _triggerFlowAnimation();
    }

    if (widget.isVictoryCelebrating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.tile.isConnected != oldWidget.tile.isConnected) {
      if (widget.tile.isConnected) {
        _shimmerController.repeat();
        _triggerFlowAnimation();
      } else {
        _shimmerController.stop();
        _flowController.reset();
      }
    } else if (widget.tile.isConnected && widget.connectionDepth != oldWidget.connectionDepth) {
      _triggerFlowAnimation();
    }

    if (widget.isVictoryCelebrating != oldWidget.isVictoryCelebrating) {
      if (widget.isVictoryCelebrating) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  /// Fluid continuous wave propagation: tiles overlap heavily so 2-3 fill simultaneously
  void _triggerFlowAnimation() {
    final r = widget.position.row;
    final c = widget.position.col;
    final depth = widget.connectionDepth;

    // Organic turbulence: subtle spatial jitter for natural feel
    final chaosJitter = ((sin(r * 3.8 + c * 2.3) * 15) +
            (cos(r * 1.7 - c * 2.9) * 10))
        .toInt();

    // Key insight: fill duration is 700ms, stagger is only 180ms.
    // So tile N+1 starts when tile N is at 180/700 = 26% progress.
    // At any moment, ~4 tiles are actively filling → truly continuous fluid wave!
    final baseDelay = depth * 180;
    final delayMs = max(0, baseDelay + chaosJitter);

    // Keep dry until wave reaches this tile
    _flowController.value = 0.0;

    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted && widget.tile.isConnected) {
        if (widget.tile.type == TileType.deadEnd) {
          _flowController.duration = const Duration(milliseconds: 8500);
          _flowController.forward(from: 0.0);
          AudioService.playAmpollaGlub();
          if (widget.goodie?.isLegendary == true) {
            AudioService.playSchmoogleReveal();
          }
        } else {
          _flowController.duration = const Duration(milliseconds: 700);
          _flowController.forward(from: 0.0);
          if (depth > 0) {
            AudioService.playWaterFlow(chainLength: depth);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _flowController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.tile.isFixed) return;
    if (widget.onTap == null) return;

    AudioService.playTileClick();
    _scaleController.forward().then((_) {
      if (mounted) _scaleController.reverse();
    });

    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final rotationTurns = widget.tile.rotation / 360.0;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _flowAnimation,
          _shimmerAnimation,
          _pulseAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.theme.tileBackground,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: widget.tile.isConnected
                      ? widget.theme.flowColor.withValues(
                          alpha: 0.35 * _flowAnimation.value,
                        )
                      : Colors.grey.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Stack(
                children: [
                  // Pipe layer with rotation and dynamic fluid simulation
                    AnimatedRotation(
                      turns: rotationTurns,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: CustomPaint(
                        painter: PipePainter(
                          tile: widget.tile.copyWith(rotation: 0),
                          theme: widget.theme,
                          flowProgress:
                              widget.tile.isConnected ? _flowAnimation.value : 0.0,
                          pulseProgress:
                              widget.isVictoryCelebrating ? _pulseAnimation.value : 0.0,
                          shimmerProgress:
                              widget.tile.isConnected ? _shimmerAnimation.value : 0.0,
                          inflowDirection: widget.inflowDirection?.rotateClockwiseBy(-widget.tile.rotation),
                          goodieImage: widget.goodie != null ? GoodiesImageService.getImage(widget.goodie!.id) : null,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  // Creature overlay for source only
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  CreatureType _getSourceCreature() {
    switch (widget.creatureTheme) {
      case 'dragon_gems':
        return CreatureType.dragon;
      case 'wizard_alchemy':
        return CreatureType.wizard;
      case 'space_station':
        return CreatureType.crystal;
      default:
        return CreatureType.dragon;
    }
  }
}
