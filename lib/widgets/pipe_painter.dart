import 'dart:math';
import 'package:flutter/material.dart';
import '../models/direction.dart';
import '../models/tile.dart';
import '../theme/level_theme.dart';

/// CustomPainter that renders a single pipe tile with realistic liquid river inundation.
///
/// Features:
/// - Asymmetric river inundation: water floods along the left and right banks at different speeds
/// - Slanted parabolic meniscus wave front rushing forward through dry pipes
/// - Natural fluid turbulence, vortex curls around corners, and moving caustics
/// - 2x enlarged crystal flask bulb with swirling liquid volume and glub bubbles
/// - Continuous caustics shimmer and ambient micro-bubbles
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

    // Clip to cell bounds to prevent bleeding
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final center = Offset(size.width / 2, size.height / 2);

    // Pipe thickness scales with tile size
    final basePipeWidth = size.width * 0.22;
    final pipeWidth = basePipeWidth + (pulseProgress * 2.0);

    final bool connected = tile.isConnected;

    // Liquid Shimmer Modulation
    final double shimmerMod = connected ? sin(shimmerProgress * 2 * pi) * 0.15 : 0.0;

    // Base Disconnected Paints (Gray Pipe)
    final baseOutlinePaint = Paint()
      ..color = theme.pipeStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth + 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final baseFillPaint = Paint()
      ..color = theme.pipeDisconnected
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final baseHighlightPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth * 0.45
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Active Liquid Paints (Purple / Theme Flow Color)
    final fluidFillPaint = Paint()
      ..color = theme.flowColor
      ..style = PaintingStyle.fill;

    final fluidStrokePaint = Paint()
      ..color = theme.flowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fluidOutlinePaint = Paint()
      ..color = theme.flowColorDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth + 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fluidHighlightPaint = Paint()
      ..color = pulseProgress > 0.0
          ? Color.lerp(theme.flowColorLight, Colors.white, pulseProgress * 0.7)!
          : Color.lerp(theme.flowColorLight, Colors.white, (0.25 + shimmerMod).clamp(0.0, 1.0))!
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

    // 1. ALWAYS DRAW BASE PIPE STRUCTURE (Gray dry pipe)
    _drawBasePipe(
      canvas, size, center, openings, pipeWidth,
      baseOutlinePaint, baseFillPaint, baseHighlightPaint, edgeMidpoint,
    );

    // 2. DRAW NATURAL RIVER INUNDATION LAYER (Asymmetric flow progress)
    if (connected && flowProgress > 0.0) {
      _drawLiquidRiverFlow(
        canvas, size, center, openings, pipeWidth,
        fluidOutlinePaint, fluidStrokePaint, fluidFillPaint, fluidHighlightPaint,
        edgeMidpoint,
      );
    }

    // Source creature marker
    if (tile.type == TileType.source) {
      _drawSourceMarker(canvas, size, center, connected);
    }

    canvas.restore();
  }

  /// 1. Draws the static base pipe geometry in gray
  void _drawBasePipe(
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
    if (tile.type == TileType.source) {
      final dir = openings.first;
      final edge = edgeMidpoint(dir);
      canvas.drawLine(center, edge, outlinePaint);
      canvas.drawLine(center, edge, fillPaint);
      canvas.drawLine(center, edge, highlightPaint);
    } else if (tile.type == TileType.deadEnd) {
      final dir = openings.first;
      _drawBaseDeadEnd(canvas, size, center, dir, pipeWidth, outlinePaint, fillPaint, highlightPaint, edgeMidpoint);
    } else if (tile.type == TileType.cross) {
      canvas.drawLine(edgeMidpoint(Direction.north), edgeMidpoint(Direction.south), outlinePaint);
      canvas.drawLine(edgeMidpoint(Direction.north), edgeMidpoint(Direction.south), fillPaint);
      canvas.drawLine(edgeMidpoint(Direction.north), edgeMidpoint(Direction.south), highlightPaint);

      canvas.drawLine(edgeMidpoint(Direction.east), edgeMidpoint(Direction.west), outlinePaint);
      canvas.drawLine(edgeMidpoint(Direction.east), edgeMidpoint(Direction.west), fillPaint);
      canvas.drawLine(edgeMidpoint(Direction.east), edgeMidpoint(Direction.west), highlightPaint);
    } else if (tile.type == TileType.line) {
      final dirs = openings.toList();
      final p1 = edgeMidpoint(dirs[0]);
      final p2 = edgeMidpoint(dirs[1]);
      canvas.drawLine(p1, p2, outlinePaint);
      canvas.drawLine(p1, p2, fillPaint);
      canvas.drawLine(p1, p2, highlightPaint);
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
    } else if (tile.type == TileType.tee) {
      _drawBaseTee(canvas, size, center, openings, outlinePaint, fillPaint, highlightPaint, edgeMidpoint);
    }
  }

  /// 2. Draws the organic liquid river stream filling the pipe with asymmetric bank speed
  void _drawLiquidRiverFlow(
    Canvas canvas,
    Size size,
    Offset center,
    Set<Direction> openings,
    double pipeWidth,
    Paint fluidOutlinePaint,
    Paint fluidStrokePaint,
    Paint fluidFillPaint,
    Paint fluidHighlightPaint,
    Offset Function(Direction) edgeMidpoint,
  ) {
    // Unique deterministic eddy / bank bias for this tile
    final bankBias = (sin(center.dx * 5.3 + center.dy * 7.7) > 0) ? 1.0 : -1.0;

    if (tile.type == TileType.source) {
      final dir = openings.first;
      final edge = edgeMidpoint(dir);
      _drawRiverStreamSegment(canvas, center, edge, pipeWidth, flowProgress, bankBias, fluidFillPaint, fluidHighlightPaint);
    } else if (tile.type == TileType.line) {
      final dirs = openings.toList();
      final p1 = edgeMidpoint(dirs[0]);
      final p2 = edgeMidpoint(dirs[1]);
      _drawRiverStreamSegment(canvas, p1, p2, pipeWidth, flowProgress, bankBias, fluidFillPaint, fluidHighlightPaint);
    } else if (tile.type == TileType.corner) {
      final dirs = openings.toList();
      final p1 = edgeMidpoint(dirs[0]);
      final p2 = edgeMidpoint(dirs[1]);
      _drawRiverCornerSegment(canvas, p1, center, p2, pipeWidth, flowProgress, bankBias, fluidFillPaint, fluidHighlightPaint);
    } else if (tile.type == TileType.tee) {
      for (final dir in openings) {
        final edge = edgeMidpoint(dir);
        _drawRiverStreamSegment(canvas, center, edge, pipeWidth, flowProgress, bankBias, fluidFillPaint, fluidHighlightPaint);
      }
    } else if (tile.type == TileType.cross) {
      for (final dir in Direction.values) {
        final edge = edgeMidpoint(dir);
        _drawRiverStreamSegment(canvas, center, edge, pipeWidth, flowProgress, bankBias, fluidFillPaint, fluidHighlightPaint);
      }
    } else if (tile.type == TileType.deadEnd) {
      final dir = openings.first;
      _drawRiverDeadEnd(canvas, size, center, dir, pipeWidth, flowProgress, bankBias, fluidFillPaint, fluidHighlightPaint, edgeMidpoint);
    }

    // Ambient micro-bubbles along the flooded river
    if (flowProgress >= 0.8) {
      for (final dir in openings) {
        final edge = edgeMidpoint(dir);
        _drawLiquidBubbles(canvas, center, edge, size.width, shimmerProgress);
      }
    }
  }

  /// Renders a straight river segment with asymmetric left vs right bank velocity
  void _drawRiverStreamSegment(
    Canvas canvas,
    Offset from,
    Offset to,
    double pipeWidth,
    double progress,
    double bankBias,
    Paint fillPaint,
    Paint highlightPaint,
  ) {
    if (progress >= 1.0) {
      // 100% full: draw clean solid stream
      canvas.drawLine(from, to, fillPaint..style = PaintingStyle.stroke..strokeWidth = pipeWidth);
      canvas.drawLine(from, to, highlightPaint);
      fillPaint.style = PaintingStyle.fill;
      return;
    }

    final dirVector = (to - from);
    final length = dirVector.distance;
    if (length == 0) return;
    final u = dirVector / length; // unit direction
    final normal = Offset(-u.dy, u.dx); // perpendicular normal (left bank)

    final halfW = pipeWidth / 2.0;

    // Asymmetric bank progress:
    // Left bank vs Right bank differ by up to 38% during inundation!
    final skew = 0.38 * bankBias * sin(progress * pi);
    final leftFrac = ((progress * 1.30) - 0.15 + skew).clamp(0.0, 1.0);
    final rightFrac = ((progress * 1.30) - 0.15 - skew).clamp(0.0, 1.0);

    if (leftFrac <= 0.0 && rightFrac <= 0.0) return;

    final pLeftStart = from + normal * halfW;
    final pRightStart = from - normal * halfW;

    final pLeftFront = pLeftStart + u * (length * leftFrac);
    final pRightFront = pRightStart + u * (length * rightFrac);

    // Meniscus tongue bulging forward in center
    final centerFrac = ((leftFrac + rightFrac) / 2.0 + 0.08).clamp(0.0, 1.0);
    final pMeniscusTip = from + u * (length * centerFrac);

    final riverPath = Path()
      ..moveTo(pLeftStart.dx, pLeftStart.dy)
      ..lineTo(pLeftFront.dx, pLeftFront.dy)
      ..quadraticBezierTo(
        pMeniscusTip.dx, pMeniscusTip.dy,
        pRightFront.dx, pRightFront.dy,
      )
      ..lineTo(pRightStart.dx, pRightStart.dy)
      ..close();

    fillPaint.style = PaintingStyle.fill;
    canvas.drawPath(riverPath, fillPaint);

    // Specular liquid foam / crest highlight along the asymmetric wave front
    final waveCrestPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final crestPath = Path()
      ..moveTo(pLeftFront.dx, pLeftFront.dy)
      ..quadraticBezierTo(
        pMeniscusTip.dx, pMeniscusTip.dy,
        pRightFront.dx, pRightFront.dy,
      );
    canvas.drawPath(crestPath, waveCrestPaint);

    // Inner highlight along flooded center
    if (centerFrac > 0.1) {
      final pHighlightEnd = from + u * (length * centerFrac * 0.85);
      canvas.drawLine(from, pHighlightEnd, highlightPaint);
    }
  }

  /// Renders a corner river turn with centrifugal liquid bias around the bend
  void _drawRiverCornerSegment(
    Canvas canvas,
    Offset p1,
    Offset center,
    Offset p2,
    double pipeWidth,
    double progress,
    double bankBias,
    Paint fillPaint,
    Paint highlightPaint,
  ) {
    if (progress >= 1.0) {
      final cornerPath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(center.dx, center.dy)
        ..lineTo(p2.dx, p2.dy);
      canvas.drawPath(cornerPath, fillPaint..style = PaintingStyle.stroke..strokeWidth = pipeWidth);
      canvas.drawPath(cornerPath, highlightPaint);
      fillPaint.style = PaintingStyle.fill;
      return;
    }

    // Step 1: Inundate from p1 to center
    final firstHalfProgress = (progress * 2.0).clamp(0.0, 1.0);
    _drawRiverStreamSegment(canvas, p1, center, pipeWidth, firstHalfProgress, bankBias, fillPaint, highlightPaint);

    // Step 2: Inundate from center to p2 with centrifugal bank shift
    if (progress > 0.45) {
      final secondHalfProgress = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);
      _drawRiverStreamSegment(canvas, center, p2, pipeWidth, secondHalfProgress, -bankBias, fillPaint, highlightPaint);
    }
  }

  /// Renders an ampolla dead-end with fluid rushing into neck and filling glass flask
  void _drawRiverDeadEnd(
    Canvas canvas,
    Size size,
    Offset center,
    Direction dir,
    double pipeWidth,
    double progress,
    double bankBias,
    Paint fillPaint,
    Paint highlightPaint,
    Offset Function(Direction) edgeMidpoint,
  ) {
    final edge = edgeMidpoint(dir);
    final dx = (edge.dx - center.dx) / (size.width / 2);
    final dy = (edge.dy - center.dy) / (size.height / 2);
    final dirVector = Offset(dx, dy);

    final bulbCenter = center - dirVector * (pipeWidth * 0.10);
    final bulbRadius = pipeWidth * 1.55;

    // 1. Inundate the neck stem first (progress 0.0 -> 0.4)
    final stemProgress = (progress / 0.45).clamp(0.0, 1.0);
    _drawRiverStreamSegment(canvas, edge, bulbCenter, pipeWidth, stemProgress, bankBias, fillPaint, highlightPaint);

    // 2. Fill the glass bulb flask (progress 0.35 -> 1.0)
    if (progress > 0.35) {
      final bulbFillFrac = ((progress - 0.35) / 0.65).clamp(0.0, 1.0);
      final fluidFillRadius = (bulbRadius - 1.0) * bulbFillFrac;
      final liquidPulse = sin(shimmerProgress * 2 * pi) * 2.0;

      if (fluidFillRadius > 0.5) {
        fillPaint.style = PaintingStyle.fill;
        canvas.drawCircle(bulbCenter, fluidFillRadius, fillPaint);

        // Swirling bright fluid core
        canvas.drawCircle(
          bulbCenter,
          ((fluidFillRadius * 0.72) + liquidPulse).clamp(0.0, bulbRadius),
          Paint()
            ..color = Color.lerp(
              theme.flowColor,
              theme.flowColorLight,
              (0.40 + (sin(shimmerProgress * 2 * pi) * 0.25)).clamp(0.0, 1.0),
            )!
            ..style = PaintingStyle.fill,
        );

        // Rising glub bubbles in ampolla
        final bubbleCount = (bulbFillFrac * 4).toInt() + 1;
        for (int b = 0; b < bubbleCount; b++) {
          final bPhase = (shimmerProgress + (b * 0.25)) % 1.0;
          final bOffset = Offset(
            sin((bPhase + b) * 2 * pi) * (fluidFillRadius * 0.50),
            cos((bPhase + b) * 2 * pi) * (fluidFillRadius * 0.50) - (bPhase * 4.0),
          );
          canvas.drawCircle(
            bulbCenter + bOffset,
            (fluidFillRadius * 0.16).clamp(1.8, 6.0),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.85)
              ..style = PaintingStyle.fill,
          );
        }
      }
    }
  }

  void _drawBaseDeadEnd(
    Canvas canvas,
    Size size,
    Offset center,
    Direction dir,
    double pipeWidth,
    Paint outlinePaint,
    Paint fillPaint,
    Paint highlightPaint,
    Offset Function(Direction) edgeMidpoint,
  ) {
    final edge = edgeMidpoint(dir);
    final dx = (edge.dx - center.dx) / (size.width / 2);
    final dy = (edge.dy - center.dy) / (size.height / 2);
    final dirVector = Offset(dx, dy);

    final bulbCenter = center - dirVector * (pipeWidth * 0.10);
    final bulbRadius = pipeWidth * 1.55;

    // Pipe stem
    canvas.drawLine(edge, bulbCenter, outlinePaint);
    canvas.drawLine(edge, bulbCenter, fillPaint);
    canvas.drawLine(edge, bulbCenter, highlightPaint);

    // Collar ring
    final collarCenter = bulbCenter + dirVector * (bulbRadius * 0.82);
    canvas.drawCircle(collarCenter, pipeWidth * 0.72, Paint()..color = theme.pipeStroke..style = PaintingStyle.fill);
    canvas.drawCircle(collarCenter, pipeWidth * 0.52, Paint()..color = theme.pipeDisconnected..style = PaintingStyle.fill);

    // Bulb glass body
    canvas.drawCircle(bulbCenter, bulbRadius + 3.5, Paint()..color = theme.pipeStroke..style = PaintingStyle.fill);
    canvas.drawCircle(bulbCenter, bulbRadius - 1.0, Paint()..color = const Color(0xFF162128)..style = PaintingStyle.fill);

    // Specular reflections
    final specularOffset = Offset(-bulbRadius * 0.36, -bulbRadius * 0.36);
    canvas.drawOval(
      Rect.fromCenter(center: bulbCenter + specularOffset, width: bulbRadius * 0.65, height: bulbRadius * 0.35),
      Paint()..color = Colors.white.withValues(alpha: 0.50)..style = PaintingStyle.fill,
    );
    final rimOffset = Offset(bulbRadius * 0.38, bulbRadius * 0.38);
    canvas.drawOval(
      Rect.fromCenter(center: bulbCenter + rimOffset, width: bulbRadius * 0.35, height: bulbRadius * 0.18),
      Paint()..color = Colors.white.withValues(alpha: 0.25)..style = PaintingStyle.fill,
    );
  }

  void _drawBaseTee(
    Canvas canvas,
    Size size,
    Offset center,
    Set<Direction> openings,
    Paint outlinePaint,
    Paint fillPaint,
    Paint highlightPaint,
    Offset Function(Direction) edgeMidpoint,
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
    } else {
      for (final dir in dirs) {
        canvas.drawLine(center, edgeMidpoint(dir), outlinePaint);
        canvas.drawLine(center, edgeMidpoint(dir), fillPaint);
        canvas.drawLine(center, edgeMidpoint(dir), highlightPaint);
      }
    }
  }

  void _drawLiquidBubbles(Canvas canvas, Offset from, Offset to, double tileSize, double phase) {
    final bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.65)..style = PaintingStyle.fill;
    final glowPaint = Paint()..color = theme.flowColorLight.withValues(alpha: 0.40)..style = PaintingStyle.fill;

    for (int i = 0; i < 2; i++) {
      final offsetFrac = (phase + (i * 0.45)) % 1.0;
      final bubblePos = Offset.lerp(from, to, offsetFrac)!;
      final bubbleRadius = (tileSize * 0.035) * (1.0 + (sin((phase + i) * pi * 2) * 0.3));

      canvas.drawCircle(bubblePos, bubbleRadius + 1.5, glowPaint);
      canvas.drawCircle(bubblePos, bubbleRadius, bubblePaint);
    }
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
      Paint()..color = (connected ? theme.flowColorDark : const Color(0xFFE65100))..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      auraRadius * 0.52,
      Paint()..color = (connected ? theme.flowColorLight : const Color(0xFFFFD54F))..style = PaintingStyle.fill,
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
