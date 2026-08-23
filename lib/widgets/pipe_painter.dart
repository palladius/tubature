import 'dart:math';
import 'package:flutter/material.dart';
import '../models/direction.dart';
import '../models/tile.dart';
import '../theme/level_theme.dart';

/// CustomPainter that renders a single pipe tile with realistic liquid fluid simulation.
///
/// Features:
/// - Chunky, rounded pipe segments with seamless joints
/// - Dynamic liquid flow animation with surging curved meniscus and micro-bubbles
/// - Continuous caustics shimmer and pulsating fluid highlights
/// - Swirling liquid flask for sealed dead-end ampolle
/// - Whole-board celebration glow pulse
class PipePainter extends CustomPainter {
  final Tile tile;
  final LevelTheme theme;
  final double flowProgress;
  final double pulseProgress;
  final double shimmerProgress;

  const PipePainter({
    required this.tile,
    required this.theme,
    this.flowProgress = 1.0,
    this.pulseProgress = 0.0,
    this.shimmerProgress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (tile.type == TileType.empty) return;

    // Clip to cell bounds — prevents thick pipe strokes from bleeding
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height / 2);

    // Base pipe thickness scales with tile size
    final basePipeWidth = size.width * 0.22;
    final pipeWidth = basePipeWidth + (pulseProgress * 2.0);

    final bool connected = tile.isConnected;
    
    // Liquid colors with flow interpolation
    final Color fillColor = connected
        ? Color.lerp(theme.pipeDisconnected, theme.flowColor, flowProgress)!
        : theme.pipeDisconnected;
    final Color strokeColor = connected
        ? Color.lerp(theme.pipeStroke, theme.flowColorDark, flowProgress)!
        : theme.pipeStroke;
    final Color lightFill = connected
        ? Color.lerp(const Color(0xFFE0E0E0), theme.flowColorLight, flowProgress)!
        : const Color(0xFFE0E0E0);

    // Liquid Shimmer Modulation: subtle wave pulse
    final double shimmerMod = connected ? sin(shimmerProgress * 2 * pi) * 0.15 : 0.0;

    // 1. Pipe outline paint
    final outlinePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth + 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 2. Pipe fill paint
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 3. Inner fluid highlight with moving caustics
    final highlightPaint = Paint()
      ..color = pulseProgress > 0.0
          ? Color.lerp(lightFill, Colors.white, pulseProgress * 0.7)!
          : Color.lerp(lightFill, Colors.white, (0.2 + shimmerMod).clamp(0.0, 1.0))!
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth * (0.45 + (shimmerMod * 0.1) + (pulseProgress * 0.15))
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final openings = tile.openings;
    if (openings.isEmpty) return;

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

    // Source marker
    if (tile.type == TileType.source) {
      _drawSourceMarker(canvas, size, center, connected);
    }

    // Draw pipes based on tile type
    if (tile.type == TileType.source) {
      final dir = openings.first;
      final edge = edgeMidpoint(dir);
      canvas.drawLine(center, edge, outlinePaint);
      canvas.drawLine(center, edge, fillPaint);
      canvas.drawLine(center, edge, highlightPaint);
      if (connected) {
        _drawLiquidBubbles(canvas, center, edge, size.width, shimmerProgress);
      }
    } else if (tile.type == TileType.deadEnd) {
      final dir = openings.first;
      _drawDeadEndPipe(
        canvas, size, center, dir, pipeWidth,
        outlinePaint, fillPaint, highlightPaint,
        edgeMidpoint, strokeColor, fillColor, lightFill, connected,
        shimmerProgress,
      );
    } else if (tile.type == TileType.cross) {
      _drawStraightPipe(
        canvas, edgeMidpoint(Direction.north), edgeMidpoint(Direction.south),
        outlinePaint, fillPaint, highlightPaint, connected, size.width, shimmerProgress,
      );
      _drawStraightPipe(
        canvas, edgeMidpoint(Direction.east), edgeMidpoint(Direction.west),
        outlinePaint, fillPaint, highlightPaint, connected, size.width, shimmerProgress,
      );
    } else if (tile.type == TileType.line) {
      final dirs = openings.toList();
      _drawStraightPipe(
        canvas, edgeMidpoint(dirs[0]), edgeMidpoint(dirs[1]),
        outlinePaint, fillPaint, highlightPaint, connected, size.width, shimmerProgress,
      );
    } else if (tile.type == TileType.corner) {
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
      if (connected) {
        _drawLiquidBubbles(canvas, p1, center, size.width, shimmerProgress);
        _drawLiquidBubbles(canvas, center, p2, size.width, (shimmerProgress + 0.5) % 1.0);
      }
    } else if (tile.type == TileType.tee) {
      _drawTeePipe(
        canvas, size, center, openings, pipeWidth,
        outlinePaint, fillPaint, highlightPaint, edgeMidpoint, connected, shimmerProgress,
      );
    }

    // Draw active liquid surging meniscus wave front when filling
    if (connected && flowProgress < 0.98) {
      for (final dir in openings) {
        final edge = edgeMidpoint(dir);
        final currentFront = Offset.lerp(center, edge, flowProgress)!;
        _drawFluidMeniscus(canvas, currentFront, pipeWidth, theme.flowColorLight);
      }
    }

    canvas.restore();
  }

  void _drawStraightPipe(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint outlinePaint,
    Paint fillPaint,
    Paint highlightPaint,
    bool connected,
    double tileSize,
    double shimmer,
  ) {
    canvas.drawLine(from, to, outlinePaint);
    canvas.drawLine(from, to, fillPaint);
    canvas.drawLine(from, to, highlightPaint);
    if (connected) {
      _drawLiquidBubbles(canvas, from, to, tileSize, shimmer);
    }
  }

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
    bool connected,
    double shimmer,
  ) {
    final dirs = openings.toList();
    Direction? straightA;
    Direction? straightB;
    Direction? branch;

    for (int i = 0; i < dirs.length; i++) {
      for (int j = i + 1; j < dirs.length; j++) {
        if (dirs[i].opposite == dirs[j]) {
          straightA = dirs[i];
          straightB = dirs[j];
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

      canvas.drawLine(pA, pB, outlinePaint);
      canvas.drawLine(center, pBranch, outlinePaint);

      canvas.drawLine(pA, pB, fillPaint);
      canvas.drawLine(center, pBranch, fillPaint);

      canvas.drawLine(pA, pB, highlightPaint);
      canvas.drawLine(center, pBranch, highlightPaint);

      if (connected) {
        _drawLiquidBubbles(canvas, pA, pB, size.width, shimmer);
        _drawLiquidBubbles(canvas, center, pBranch, size.width, (shimmer + 0.4) % 1.0);
      }
    } else {
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

  /// Draw animated liquid bubbles flowing through a pipe segment
  void _drawLiquidBubbles(Canvas canvas, Offset from, Offset to, double tileSize, double phase) {
    final bubblePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    
    final glowPaint = Paint()
      ..color = theme.flowColorLight.withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;

    // Draw 2 moving micro bubbles
    for (int i = 0; i < 2; i++) {
      final offsetFrac = (phase + (i * 0.45)) % 1.0;
      final bubblePos = Offset.lerp(from, to, offsetFrac)!;
      final bubbleRadius = (tileSize * 0.035) * (1.0 + (sin((phase + i) * pi * 2) * 0.3));

      canvas.drawCircle(bubblePos, bubbleRadius + 1.5, glowPaint);
      canvas.drawCircle(bubblePos, bubbleRadius, bubblePaint);
    }
  }

  /// Draw a surging fluid pressure front / curved meniscus
  void _drawFluidMeniscus(Canvas canvas, Offset pos, double pipeWidth, Color glowColor) {
    final meniscusPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    
    final auraPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final r = pipeWidth * 0.4;
    canvas.drawCircle(pos, r * 1.4, auraPaint);
    canvas.drawCircle(pos, r, meniscusPaint);
  }

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
    double shimmer,
  ) {
    final edge = edgeMidpoint(dir);

    final dx = (edge.dx - center.dx) / (size.width / 2);
    final dy = (edge.dy - center.dy) / (size.height / 2);
    final dirVector = Offset(dx, dy);

    final bulbCenter = center - dirVector * (pipeWidth * 0.15);
    final bulbRadius = pipeWidth * 0.85;

    // Pipe stem
    canvas.drawLine(edge, bulbCenter, outlinePaint);
    canvas.drawLine(edge, bulbCenter, fillPaint);
    canvas.drawLine(edge, bulbCenter, highlightPaint);

    if (connected) {
      _drawLiquidBubbles(canvas, edge, bulbCenter, size.width, shimmer);
    }

    // Collar ring
    final collarCenter = bulbCenter + dirVector * (bulbRadius * 0.7);
    canvas.drawCircle(
      collarCenter,
      pipeWidth * 0.58,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      collarCenter,
      pipeWidth * 0.44,
      Paint()
        ..color = connected ? fillColor : theme.pipeDisconnected
        ..style = PaintingStyle.fill,
    );

    // Bulb glass body
    canvas.drawCircle(
      bulbCenter,
      bulbRadius + 3.0,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.fill,
    );

    // Bulb fluid chamber
    final liquidPulse = connected ? sin(shimmer * 2 * pi) * 1.5 : 0.0;
    canvas.drawCircle(
      bulbCenter,
      bulbRadius - 1.0,
      Paint()
        ..color = connected
            ? Color.lerp(const Color(0xFF1E2D2F), fillColor, flowProgress)!
            : const Color(0xFF2C3E50)
        ..style = PaintingStyle.fill,
    );

    if (connected) {
      // Swirling fluid core
      canvas.drawCircle(
        bulbCenter,
        (bulbRadius * 0.65) + liquidPulse,
        Paint()
          ..color = Color.lerp(fillColor, lightFill, 0.45 + (sin(shimmer * 2 * pi) * 0.25))!
          ..style = PaintingStyle.fill,
      );

      // Bubbles in ampolla
      final bubbleOffset = Offset(
        sin(shimmer * 2 * pi) * (bulbRadius * 0.3),
        cos(shimmer * 2 * pi) * (bulbRadius * 0.3),
      );
      canvas.drawCircle(
        bulbCenter + bubbleOffset,
        bulbRadius * 0.22,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.fill,
      );
    }

    // Specular reflections
    final specularOffset = Offset(-bulbRadius * 0.32, -bulbRadius * 0.32);
    canvas.drawOval(
      Rect.fromCenter(
        center: bulbCenter + specularOffset,
        width: bulbRadius * 0.55,
        height: bulbRadius * 0.30,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: connected ? 0.75 : 0.45)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawSourceMarker(Canvas canvas, Size size, Offset center, bool connected) {
    final auraRadius = size.width * 0.38;
    canvas.drawCircle(
      center,
      auraRadius,
      Paint()
        ..color = (connected ? theme.flowColor : Colors.amber).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      center,
      auraRadius * 0.7,
      Paint()
        ..color = (connected ? theme.flowColorDark : const Color(0xFFE65100))
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      auraRadius * 0.52,
      Paint()
        ..color = (connected ? theme.flowColorLight : const Color(0xFFFFD54F))
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant PipePainter oldDelegate) {
    return oldDelegate.tile != tile ||
        oldDelegate.theme != theme ||
        oldDelegate.flowProgress != flowProgress ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.shimmerProgress != shimmerProgress;
  }
}
