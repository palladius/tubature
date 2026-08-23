import 'package:flutter/material.dart';
import '../models/direction.dart';
import '../models/tile.dart';
import '../theme/level_theme.dart';

/// CustomPainter that renders a single pipe tile.
///
/// Draws chunky, rounded pipe segments from the tile center to edge midpoints.
/// Connected pipes are filled with the level's flow color (smoothly animated
/// via [flowProgress]); disconnected pipes are drawn in neutral gray.
/// Supports whole-board celebration shine via [pulseProgress].
class PipePainter extends CustomPainter {
  final Tile tile;
  final LevelTheme theme;
  final double flowProgress;
  final double pulseProgress;

  const PipePainter({
    required this.tile,
    required this.theme,
    this.flowProgress = 1.0,
    this.pulseProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (tile.type == TileType.empty) return;

    // Clip to cell bounds — prevents thick pipe strokes from bleeding
    // into neighboring cells (especially curved corner arcs)
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height / 2);

    // Pipe thickness scales with tile size (roughly 22% of tile width)
    final basePipeWidth = size.width * 0.22;
    final pipeWidth = basePipeWidth + (pulseProgress * 1.5);

    // Choose colors based on connection state and animated flow progress
    final bool connected = tile.isConnected;
    final Color fillColor = connected
        ? Color.lerp(theme.pipeDisconnected, theme.flowColor, flowProgress)!
        : theme.pipeDisconnected;
    final Color strokeColor = connected
        ? Color.lerp(theme.pipeStroke, theme.flowColorDark, flowProgress)!
        : theme.pipeStroke;
    final Color lightFill = connected
        ? Color.lerp(const Color(0xFFE0E0E0), theme.flowColorLight, flowProgress)!
        : const Color(0xFFE0E0E0);

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
      ..color = pulseProgress > 0.0
          ? Color.lerp(lightFill, Colors.white, pulseProgress * 0.7)!
          : lightFill
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth * (0.5 + pulseProgress * 0.15)
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

    // Draw source special marker
    if (tile.type == TileType.source) {
      _drawSourceMarker(canvas, size, center, connected);
    }

    // Draw pipe segments based on tile type
    if (tile.type == TileType.source) {
      // Source: single pipe from center to edge
      final dir = openings.first;
      final edge = edgeMidpoint(dir);
      canvas.drawLine(center, edge, outlinePaint);
      canvas.drawLine(center, edge, fillPaint);
      canvas.drawLine(center, edge, highlightPaint);
    } else if (tile.type == TileType.deadEnd) {
      // Dead end (ampolla): pipe stem with a prominent sealed flask / bulb
      final dir = openings.first;
      _drawDeadEndPipe(
        canvas, size, center, dir, pipeWidth,
        outlinePaint, fillPaint, highlightPaint,
        edgeMidpoint, strokeColor, fillColor, lightFill, connected,
      );
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
      // Corner: continuous path connecting both edges through center (no center circle disk!)
      final dirs = openings.toList();
      final p1 = edgeMidpoint(dirs[0]);
      final p2 = edgeMidpoint(dirs[1]);
      final cornerPath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(center.dx, center.dy)
        ..lineTo(p2.dx, p2.dy);
      canvas.drawPath(cornerPath, outlinePaint);
      canvas.drawPath(cornerPath, fillPaint);
      canvas.drawPath(cornerPath, highlightPaint);
    } else if (tile.type == TileType.tee) {
      // T-junction: straight pipe + branch, clean seamless join
      _drawTeePipe(canvas, size, center, openings, pipeWidth,
          outlinePaint, fillPaint, highlightPaint, edgeMidpoint);
    }

    canvas.restore();
  }

  /// Draw a T-junction: one straight pipe through the two aligned openings,
  /// plus a branch from center to the third opening.
  void _drawTeePipe(
    Canvas canvas,
    Size size,
    Offset center,
    Set<Direction> openings,
    double pipeWidth,
    Paint outlinePaint,
    Paint fillPaint,
    Paint highlightPaint,
    Offset Function(Direction) edgeMidpoint,
  ) {
    final dirs = openings.toList();

    // Find the straight-through pair (opposite directions)
    Direction? straightA;
    Direction? straightB;
    Direction? branch;

    for (int i = 0; i < dirs.length; i++) {
      for (int j = i + 1; j < dirs.length; j++) {
        if (dirs[i].opposite == dirs[j]) {
          straightA = dirs[i];
          straightB = dirs[j];
          // The remaining direction is the branch
          branch = dirs.firstWhere((d) => d != dirs[i] && d != dirs[j]);
          break;
        }
      }
      if (straightA != null) break;
    }

    if (straightA != null && straightB != null && branch != null) {
      final pA = edgeMidpoint(straightA);
      final pB = edgeMidpoint(straightB);
      final pBranch = edgeMidpoint(branch);

      // 1. Draw all outlines first
      canvas.drawLine(pA, pB, outlinePaint);
      canvas.drawLine(center, pBranch, outlinePaint);

      // 2. Draw all fills (joins seamlessly)
      canvas.drawLine(pA, pB, fillPaint);
      canvas.drawLine(center, pBranch, fillPaint);

      // 3. Draw highlights
      canvas.drawLine(pA, pB, highlightPaint);
      canvas.drawLine(center, pBranch, highlightPaint);
    } else {
      // Fallback: draw all three branches layered
      for (final dir in dirs) {
        canvas.drawLine(center, edgeMidpoint(dir), outlinePaint);
      }
      for (final dir in dirs) {
        canvas.drawLine(center, edgeMidpoint(dir), fillPaint);
      }
      for (final dir in dirs) {
        canvas.drawLine(center, edgeMidpoint(dir), highlightPaint);
      }
    }
  }

  /// Draw a dead-end tile as a magic flask / bulb ("ampolla") termination.
  void _drawDeadEndPipe(
    Canvas canvas,
    Size size,
    Offset center,
    Direction dir,
    double pipeWidth,
    Paint outlinePaint,
    Paint fillPaint,
    Paint highlightPaint,
    Offset Function(Direction) edgeMidpoint,
    Color strokeColor,
    Color fillColor,
    Color lightFill,
    bool connected,
  ) {
    final edge = edgeMidpoint(dir);

    // Direction vector from center to edge
    final dx = (edge.dx - center.dx) / (size.width / 2);
    final dy = (edge.dy - center.dy) / (size.height / 2);
    final dirVector = Offset(dx, dy);

    // Bulb center positioned slightly opposite to the opening
    final bulbCenter = center - dirVector * (pipeWidth * 0.15);
    final bulbRadius = pipeWidth * 0.85;

    // Draw the pipe stem from edge into the bulb
    canvas.drawLine(edge, bulbCenter, outlinePaint);
    canvas.drawLine(edge, bulbCenter, fillPaint);
    canvas.drawLine(edge, bulbCenter, highlightPaint);

    // Collar flange where pipe meets bulb
    final collarCenter = bulbCenter + dirVector * (bulbRadius * 0.7);
    canvas.drawCircle(
      collarCenter,
      pipeWidth * 0.58,
      Paint()..color = strokeColor,
    );
    canvas.drawCircle(
      collarCenter,
      pipeWidth * 0.48,
      Paint()..color = fillColor,
    );

    // Outer outline for ampolla bulb
    canvas.drawCircle(
      bulbCenter,
      bulbRadius + 2.5,
      Paint()..color = strokeColor,
    );

    // Main bulb body
    canvas.drawCircle(
      bulbCenter,
      bulbRadius,
      Paint()..color = fillColor,
    );

    // Inner bright fluid core / glow
    canvas.drawCircle(
      bulbCenter,
      bulbRadius * 0.65,
      Paint()..color = lightFill,
    );

    // Specular glass highlights (white reflections)
    final highlightAngle = Offset(-bulbRadius * 0.35, -bulbRadius * 0.35);
    canvas.drawCircle(
      bulbCenter + highlightAngle,
      bulbRadius * 0.22,
      Paint()..color = Colors.white.withValues(alpha: connected ? 0.75 : 0.45),
    );

    canvas.drawCircle(
      bulbCenter + Offset(-bulbRadius * 0.15, -bulbRadius * 0.55),
      bulbRadius * 0.12,
      Paint()..color = Colors.white.withValues(alpha: connected ? 0.85 : 0.55),
    );

    // Animated sparkle pulse when bulb is filled and celebrating
    if (connected && (flowProgress > 0.85 || pulseProgress > 0.0)) {
      final sparkleAlpha = ((pulseProgress > 0.0 ? pulseProgress : (flowProgress - 0.85) * 6.6)).clamp(0.0, 1.0);
      canvas.drawCircle(
        bulbCenter,
        bulbRadius * (0.8 + pulseProgress * 0.3),
        Paint()
          ..color = Colors.white.withValues(alpha: sparkleAlpha * 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
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

  /// Draw the Source marker — a filled circle with inner ring.
  void _drawSourceMarker(
      Canvas canvas, Size size, Offset center, bool connected) {
    final radius = size.width * 0.25;

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
  }

  @override
  bool shouldRepaint(covariant PipePainter oldDelegate) {
    return tile != oldDelegate.tile ||
        theme != oldDelegate.theme ||
        flowProgress != oldDelegate.flowProgress ||
        pulseProgress != oldDelegate.pulseProgress;
  }
}
