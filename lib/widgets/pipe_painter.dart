
import 'package:flutter/material.dart';
import '../models/direction.dart';
import '../models/tile.dart';
import '../theme/level_theme.dart';

/// CustomPainter that renders a single pipe tile.
///
/// Draws chunky, rounded pipe segments from the tile center to edge midpoints.
/// Connected pipes are filled with the level's flow color; disconnected pipes
/// are drawn in gray.
class PipePainter extends CustomPainter {
  final Tile tile;
  final LevelTheme theme;

  const PipePainter({
    required this.tile,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (tile.type == TileType.empty) return;

    final center = Offset(size.width / 2, size.height / 2);
    
    

    // Pipe thickness scales with tile size (roughly 20% of tile width)
    final pipeWidth = size.width * 0.22;
    

    // Choose colors based on connection state
    final bool connected = tile.isConnected;
    final Color fillColor =
        connected ? theme.flowColor : theme.pipeDisconnected;
    final Color strokeColor =
        connected ? theme.flowColorDark : theme.pipeStroke;
    final Color lightFill =
        connected ? theme.flowColorLight : const Color(0xFFE0E0E0);

    // Paint for the pipe fill (thick rounded line)
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Paint for the pipe outline (slightly thicker, darker)
    final outlinePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth + 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Paint for the inner highlight (slightly thinner, lighter)
    final highlightPaint = Paint()
      ..color = lightFill
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth * 0.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Get the openings for this tile
    final openings = tile.openings;
    if (openings.isEmpty) return;

    // Calculate edge midpoints for each direction
    Offset edgeMidpoint(Direction dir) {
      switch (dir) {
        case Direction.north:
          return Offset(center.dx, 0);
        case Direction.south:
          return Offset(center.dx, size.height);
        case Direction.east:
          return Offset(size.width, center.dy);
        case Direction.west:
          return Offset(0, center.dy);
      }
    }

    // Draw source/sink special markers
    if (tile.type == TileType.source || tile.type == TileType.sink) {
      _drawCreatureMarker(canvas, size, center, connected);
    }

    // Draw pipe segments
    if (tile.type == TileType.source || tile.type == TileType.sink) {
      // Source/Sink: single pipe from center to edge
      final dir = openings.first;
      final edge = edgeMidpoint(dir);
      canvas.drawLine(center, edge, outlinePaint);
      canvas.drawLine(center, edge, fillPaint);
      canvas.drawLine(center, edge, highlightPaint);
    } else if (tile.type == TileType.cross) {
      // Cross: draw two straight lines through center
      _drawStraightPipe(
          canvas, edgeMidpoint(Direction.north), edgeMidpoint(Direction.south),
          outlinePaint, fillPaint, highlightPaint);
      _drawStraightPipe(
          canvas, edgeMidpoint(Direction.east), edgeMidpoint(Direction.west),
          outlinePaint, fillPaint, highlightPaint);
    } else if (tile.type == TileType.line) {
      // Line: straight pipe between two opposite openings
      final dirs = openings.toList();
      _drawStraightPipe(
          canvas, edgeMidpoint(dirs[0]), edgeMidpoint(dirs[1]),
          outlinePaint, fillPaint, highlightPaint);
    } else if (tile.type == TileType.corner) {
      // Corner: draw two segments from edge to center, creating a bend
      final dirs = openings.toList();
      // Draw each segment edge→center
      for (final dir in dirs) {
        final edge = edgeMidpoint(dir);
        canvas.drawLine(center, edge, outlinePaint);
        canvas.drawLine(center, edge, fillPaint);
        canvas.drawLine(center, edge, highlightPaint);
      }
      // Draw a filled circle at center to smooth the corner joint
      canvas.drawCircle(
          center, pipeWidth / 2 + 2, Paint()..color = strokeColor);
      canvas.drawCircle(center, pipeWidth / 2, Paint()..color = fillColor);
      canvas.drawCircle(
          center, pipeWidth * 0.25, Paint()..color = lightFill);
    } else if (tile.type == TileType.tee) {
      // T-junction: draw three segments from edges to center
      final dirs = openings.toList();
      for (final dir in dirs) {
        final edge = edgeMidpoint(dir);
        canvas.drawLine(center, edge, outlinePaint);
        canvas.drawLine(center, edge, fillPaint);
        canvas.drawLine(center, edge, highlightPaint);
      }
      // Smooth center joint
      canvas.drawCircle(
          center, pipeWidth / 2 + 2, Paint()..color = strokeColor);
      canvas.drawCircle(center, pipeWidth / 2, Paint()..color = fillColor);
      canvas.drawCircle(
          center, pipeWidth * 0.25, Paint()..color = lightFill);
    }

    // If connected, add a subtle glow effect
    if (connected) {
      final glowPaint = Paint()
        ..color = theme.flowColor.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      for (final dir in openings) {
        canvas.drawLine(center, edgeMidpoint(dir), glowPaint..strokeWidth = pipeWidth * 1.5);
      }
    }
  }

  void _drawStraightPipe(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint outline,
    Paint fill,
    Paint highlight,
  ) {
    canvas.drawLine(from, to, outline);
    canvas.drawLine(from, to, fill);
    canvas.drawLine(from, to, highlight);
  }

  /// Draw a cute marker for Source (dragon-ish) or Sink (unicorn-ish).
  /// These are simple geometric shapes — not full creature illustrations.
  /// Full creature paintings are in CreaturePainter overlay.
  void _drawCreatureMarker(
      Canvas canvas, Size size, Offset center, bool connected) {
    final radius = size.width * 0.25;

    if (tile.type == TileType.source) {
      // Source: filled circle with inner ring (represents dragon's fire orb)
      final outerPaint = Paint()
        ..color = connected ? theme.flowColor : theme.pipeDisconnected
        ..style = PaintingStyle.fill;
      final ringPaint = Paint()
        ..color = connected ? theme.flowColorDark : theme.pipeStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final innerPaint = Paint()
        ..color = connected ? theme.flowColorLight : const Color(0xFFE8E8E8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius + 2, ringPaint);
      canvas.drawCircle(center, radius, outerPaint);
      canvas.drawCircle(center, radius * 0.4, innerPaint);
    } else {
      // Sink: open circle with double ring (represents unicorn's magic portal)
      final outerRing = Paint()
        ..color = connected ? theme.flowColorDark : theme.pipeStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final innerRing = Paint()
        ..color = connected ? theme.flowColor : theme.pipeDisconnected
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final centerDot = Paint()
        ..color = connected ? theme.flowColorLight : const Color(0xFFE0E0E0)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius + 2, outerRing);
      canvas.drawCircle(center, radius * 0.7, innerRing);
      canvas.drawCircle(center, radius * 0.25, centerDot);
    }
  }

  @override
  bool shouldRepaint(covariant PipePainter oldDelegate) {
    return tile != oldDelegate.tile || theme != oldDelegate.theme;
  }
}
