import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/direction.dart';
import '../models/tile.dart';
import '../theme/level_theme.dart';
import 'cauldron_reveal_painter.dart';

/// CustomPainter that renders a single pipe tile with realistic Torrential River Flood ("Fiume in Piena") physics.
///
/// Features:
/// 1. Asymmetric Flash Flood Inundation (0.0 -> 1.0):
///    - Riverbanks surge at different velocities with turbulent noise
///    - Parabolic water tongue rushing forward through dry pipes
///    - Foaming white wave crest & splashing water droplets jumping ahead
///    - Centrifugal wall sloshing around corners and tee branches
///
/// 2. Continuous Living River Current (Connected & 1.0):
///    - Multi-layered animated sinusoidal streamlines flowing at water current speed
///    - Traveling specular caustics and glistening sunlight ripples
///    - Drifting micro-bubbles and vortex eddies
///
/// 3. Dynamic Crystal Ampolla Bulb:
///    - Neck breach splash -> rising turbulent liquid volume -> swirling core & glub bubbles
class PipePainter extends CustomPainter {
  final Tile tile;
  final LevelTheme theme;
  final double flowProgress;
  final double pulseProgress;
  final double shimmerProgress;
  final Direction? inflowDirection;
  final ui.Image? goodieImage;
  final List<ui.Image?>? crossImages;

  const PipePainter({
    required this.tile,
    required this.theme,
    this.flowProgress = 1.0,
    this.pulseProgress = 0.0,
    this.shimmerProgress = 0.0,
    this.inflowDirection,
    this.goodieImage,
    this.crossImages,
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
    final pipeWidth = basePipeWidth + (pulseProgress * 2.5);

    final bool connected = tile.isConnected;

    // Continuous Liquid Shimmer Modulation (60 FPS living river)
    final double shimmerMod = connected ? sin(shimmerProgress * 2 * pi) * 0.18 : 0.0;

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
      ..strokeWidth = pipeWidth * 0.42
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Active Liquid Paints (Theme Flow Color / Living Purple)
    final fluidFillPaint = Paint()
      ..color = theme.flowColor
      ..style = PaintingStyle.fill;

    final fluidOutlinePaint = Paint()
      ..color = theme.flowColorDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth + 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fluidHighlightPaint = Paint()
      ..color = pulseProgress > 0.0
          ? Color.lerp(theme.flowColorLight, Colors.white, pulseProgress * 0.8)!
          : Color.lerp(theme.flowColorLight, Colors.white, (0.28 + shimmerMod).clamp(0.0, 1.0))!
      ..style = PaintingStyle.stroke
      ..strokeWidth = pipeWidth * (0.42 + (shimmerMod * 0.12) + (pulseProgress * 0.15))
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

    // 1. ALWAYS DRAW BASE PIPE CASING (Gray dry pipe channel)
    _drawBasePipe(
      canvas, size, center, openings, pipeWidth,
      baseOutlinePaint, baseFillPaint, baseHighlightPaint, edgeMidpoint,
    );

    // 2. DRAW TORRENTIAL RIVER FLOOD & LIVING CURRENT
    if (connected && flowProgress > 0.0) {
      _drawTorrentialRiver(
        canvas, size, center, openings, pipeWidth,
        fluidOutlinePaint, fluidFillPaint, fluidHighlightPaint,
        edgeMidpoint,
      );
    }

    // Source creature marker
    if (tile.type == TileType.source) {
      _drawSourceMarker(canvas, size, center, connected);
    }

    // ✚ Google-colored symbols on the rare cross tile (NW/NE/SW/SE quadrants)
    if (tile.type == TileType.cross) {
      _drawCrossGoogleSymbols(canvas, size, center, pipeWidth);
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

  /// 2. Draws the Torrential River Flood ("Fiume in Piena") with continuous current streamlines
  void _drawTorrentialRiver(
    Canvas canvas,
    Size size,
    Offset center,
    Set<Direction> openings,
    double pipeWidth,
    Paint fluidOutlinePaint,
    Paint fluidFillPaint,
    Paint fluidHighlightPaint,
    Offset Function(Direction) edgeMidpoint,
  ) {
    // Unique deterministic spatial turbulence bias for this tile
    final bankBias = (sin(center.dx * 6.7 + center.dy * 4.3) > 0) ? 1.0 : -1.0;

    if (tile.type == TileType.source) {
      final dir = openings.first;
      final edge = edgeMidpoint(dir);
      _drawTorrentialStreamSegment(canvas, size, center, edge, pipeWidth, flowProgress, bankBias, fluidFillPaint, fluidHighlightPaint);
    } else if (tile.type == TileType.line) {
      final dirs = openings.toList();
      final entry = (inflowDirection != null && openings.contains(inflowDirection))
          ? inflowDirection!
          : dirs[0];
      final exit = dirs.firstWhere((d) => d != entry, orElse: () => dirs.last);
      final p1 = edgeMidpoint(entry);
      final p2 = edgeMidpoint(exit);
      _drawTorrentialStreamSegment(canvas, size, p1, p2, pipeWidth, flowProgress, bankBias, fluidFillPaint, fluidHighlightPaint);
    } else if (tile.type == TileType.corner) {
      final dirs = openings.toList();
      final entry = (inflowDirection != null && openings.contains(inflowDirection))
          ? inflowDirection!
          : dirs[0];
      final exit = dirs.firstWhere((d) => d != entry, orElse: () => dirs.last);
      final p1 = edgeMidpoint(entry);
      final p2 = edgeMidpoint(exit);
      _drawTorrentialCornerSegment(canvas, size, p1, center, p2, pipeWidth, flowProgress, bankBias, fluidFillPaint, fluidHighlightPaint);
    } else if (tile.type == TileType.tee) {
      final dirs = openings.toList();
      final entry = (inflowDirection != null && openings.contains(inflowDirection))
          ? inflowDirection!
          : dirs[0];
      final exits = dirs.where((d) => d != entry).toList();

      final firstHalf = (flowProgress * 1.8).clamp(0.0, 1.0);
      _drawTorrentialStreamSegment(canvas, size, edgeMidpoint(entry), center, pipeWidth, firstHalf, bankBias, fluidFillPaint, fluidHighlightPaint);

      // Junction fill at center
      if (firstHalf >= 0.80) {
        final jPaint = Paint()..color = fluidFillPaint.color..style = PaintingStyle.fill;
        canvas.drawCircle(center, pipeWidth / 2.0 + 1.0, jPaint);
      }

      if (flowProgress > 0.40) {
        final secondHalf = ((flowProgress - 0.40) / 0.60).clamp(0.0, 1.0);
        for (final exit in exits) {
          _drawTorrentialStreamSegment(canvas, size, center, edgeMidpoint(exit), pipeWidth, secondHalf, -bankBias, fluidFillPaint, fluidHighlightPaint);
        }
      }
    } else if (tile.type == TileType.cross) {
      final entry = (inflowDirection != null && openings.contains(inflowDirection))
          ? inflowDirection!
          : Direction.north;
      final exits = Direction.values.where((d) => d != entry).toList();

      final firstHalf = (flowProgress * 1.8).clamp(0.0, 1.0);
      _drawTorrentialStreamSegment(canvas, size, edgeMidpoint(entry), center, pipeWidth, firstHalf, bankBias, fluidFillPaint, fluidHighlightPaint);

      // Junction fill at center
      if (firstHalf >= 0.80) {
        final jPaint = Paint()..color = fluidFillPaint.color..style = PaintingStyle.fill;
        canvas.drawCircle(center, pipeWidth / 2.0 + 1.0, jPaint);
      }

      if (flowProgress > 0.40) {
        final secondHalf = ((flowProgress - 0.40) / 0.60).clamp(0.0, 1.0);
        for (final exit in exits) {
          _drawTorrentialStreamSegment(canvas, size, center, edgeMidpoint(exit), pipeWidth, secondHalf, -bankBias, fluidFillPaint, fluidHighlightPaint);
        }
      }
    } else if (tile.type == TileType.deadEnd) {
      final dir = openings.first;
      _drawTorrentialDeadEnd(canvas, size, center, dir, pipeWidth, flowProgress, bankBias, fluidFillPaint, fluidHighlightPaint, edgeMidpoint);
    }
  }

  /// Renders a straight pipe river segment:
  /// - During Inundation (progress < 1.0): Asymmetric left vs right bank surge + foam crest + splash droplets
  /// - Full Stream (progress >= 1.0): Continuous multi-layered traveling streamlines, caustics, and water ripples
  void _drawTorrentialStreamSegment(
    Canvas canvas,
    Size size,
    Offset from,
    Offset to,
    double pipeWidth,
    double progress,
    double bankBias,
    Paint fillPaint,
    Paint highlightPaint,
  ) {
    final dirVector = (to - from);
    final length = dirVector.distance;
    if (length == 0) return;
    final u = dirVector / length; // unit direction
    final normal = Offset(-u.dy, u.dx); // perpendicular normal (left bank)
    final halfW = pipeWidth / 2.0;

    if (progress >= 1.0) {
      // ==========================================
      // LIVING RUSHING RIVER (CONTINUOUS 60 FPS)
      // ==========================================
      // 1. Solid base flow body
      fillPaint.style = PaintingStyle.stroke;
      fillPaint.strokeWidth = pipeWidth;
      canvas.drawLine(from, to, fillPaint);

      // 2. Continuous Traveling Streamlines (sinusoidal river ripples)
      final streamPaint = Paint()
        ..color = Color.lerp(theme.flowColorLight, Colors.white, 0.40)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      final phase = shimmerProgress * 2 * pi;
      final pathCenter = Path();
      final pathLeft = Path();
      final pathRight = Path();

      const sampleCount = 12;
      for (int i = 0; i <= sampleCount; i++) {
        final t = i / sampleCount;
        final along = t * length;

        // Traveling sine waves in direction of flow
        final waveCenter = sin((t * 4 * pi) - (phase * 2.0)) * (halfW * 0.28);
        final waveLeft = sin((t * 3.5 * pi) - (phase * 1.7) + 1.2) * (halfW * 0.20);
        final waveRight = cos((t * 3.8 * pi) - (phase * 1.9) - 0.8) * (halfW * 0.20);

        final pCenter = from + (u * along) + (normal * waveCenter);
        final pLeft = from + (u * along) + (normal * (halfW * 0.52 + waveLeft));
        final pRight = from + (u * along) - (normal * (halfW * 0.52 - waveRight));

        if (i == 0) {
          pathCenter.moveTo(pCenter.dx, pCenter.dy);
          pathLeft.moveTo(pLeft.dx, pLeft.dy);
          pathRight.moveTo(pRight.dx, pRight.dy);
        } else {
          pathCenter.lineTo(pCenter.dx, pCenter.dy);
          pathLeft.lineTo(pLeft.dx, pLeft.dy);
          pathRight.lineTo(pRight.dx, pRight.dy);
        }
      }

      // Draw Center Main Current Streamline
      canvas.drawPath(pathCenter, streamPaint);

      // Draw Side Secondary Streamlines (subtler)
      streamPaint.strokeWidth = 1.4;
      streamPaint.color = Colors.white.withValues(alpha: 0.45);
      canvas.drawPath(pathLeft, streamPaint);
      canvas.drawPath(pathRight, streamPaint);

      // 3. Traveling Sun Caustic Glints & Micro-Bubbles along the stream
      _drawTravelingCausticRipples(canvas, from, to, u, length, halfW, shimmerProgress);
      return;
    }

    // ==========================================
    // INUNDATION FLASH FLOOD WAVE (0.0 -> 1.0)
    // ==========================================
    // Asymmetric bank speed:
    // Left bank vs Right bank differ dramatically during flash flood inundation!
    final bankDelta = 0.44 * bankBias * sin(progress * pi);
    final leftFrac = ((progress * 1.35) - 0.12 + bankDelta).clamp(0.0, 1.0);
    final rightFrac = ((progress * 1.35) - 0.12 - bankDelta).clamp(0.0, 1.0);

    if (leftFrac <= 0.0 && rightFrac <= 0.0) return;

    final pLeftStart = from + normal * halfW;
    final pRightStart = from - normal * halfW;

    final pLeftFront = pLeftStart + u * (length * leftFrac);
    final pRightFront = pRightStart + u * (length * rightFrac);

    // Parabolic water tongue bulging forward with dynamic inertia
    final centerFrac = ((leftFrac + rightFrac) / 2.0 + (0.12 * sin(progress * pi))).clamp(0.0, 1.0);
    final pMeniscusTip = from + u * (length * centerFrac);

    // Liquid Torrent Body Path
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

    // 1. Foaming Froth Wave Crest (White foaming head of the river in flood)
    final waveCrestPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final crestPath = Path()
      ..moveTo(pLeftFront.dx, pLeftFront.dy)
      ..quadraticBezierTo(
        pMeniscusTip.dx, pMeniscusTip.dy,
        pRightFront.dx, pRightFront.dy,
      );
    canvas.drawPath(crestPath, waveCrestPaint);

    // 2. Frothing Foam Beads along the wave crest
    final foamPaint = Paint()..color = Colors.white.withValues(alpha: 0.85)..style = PaintingStyle.fill;
    for (double t = 0.1; t <= 0.9; t += 0.2) {
      final pFoam = Offset.lerp(
        Offset.lerp(pLeftFront, pMeniscusTip, t)!,
        Offset.lerp(pMeniscusTip, pRightFront, t)!,
        t,
      )!;
      final beadRadius = 1.8 + (sin((progress + t) * pi * 4) * 0.8).abs();
      canvas.drawCircle(pFoam, beadRadius, foamPaint);
    }

    // 3. Splashing Water Spray Droplets jumping ahead of the flood head
    final sprayPaint = Paint()..color = theme.flowColorLight.withValues(alpha: 0.90)..style = PaintingStyle.fill;
    final splashCount = 4;
    for (int s = 0; s < splashCount; s++) {
      final sprayFrac = centerFrac + (0.04 * (s + 1));
      if (sprayFrac < 1.0) {
        final sprayLateral = (sin(s * 2.3 + progress * 8.0) * (halfW * 0.60));
        final pSpray = from + (u * (length * sprayFrac)) + (normal * sprayLateral);
        final sprayRadius = (halfW * 0.14) * (1.0 - (s * 0.18));
        canvas.drawCircle(pSpray, sprayRadius.clamp(1.5, 4.0), sprayPaint);
        canvas.drawCircle(pSpray, (sprayRadius * 0.5).clamp(1.0, 2.0), Paint()..color = Colors.white);
      }
    }

    // 4. Inner current highlight behind the wave
    if (centerFrac > 0.12) {
      final pHighlightEnd = from + u * (length * centerFrac * 0.82);
      canvas.drawLine(from, pHighlightEnd, highlightPaint);
    }
  }

  /// Renders a corner river turn with centrifugal liquid sloshing around the bend
  void _drawTorrentialCornerSegment(
    Canvas canvas,
    Size size,
    Offset p1,
    Offset center,
    Offset p2,
    double pipeWidth,
    double progress,
    double bankBias,
    Paint fillPaint,
    Paint highlightPaint,
  ) {
    // Junction fill circle at the bend point to eliminate gray gap
    final junctionPaint = Paint()
      ..color = fillPaint.color
      ..style = PaintingStyle.fill;
    final junctionRadius = pipeWidth / 2.0 + 1.0;

    if (progress >= 1.0) {
      // Continuous living current — both legs + junction fill
      _drawTorrentialStreamSegment(canvas, size, p1, center, pipeWidth, 1.0, bankBias, fillPaint, highlightPaint);
      canvas.drawCircle(center, junctionRadius, junctionPaint);
      _drawTorrentialStreamSegment(canvas, size, center, p2, pipeWidth, 1.0, -bankBias, fillPaint, highlightPaint);
      return;
    }

    // Inundation Phase:
    // First half rushes to center with centrifugal bank bias
    final firstHalfProgress = (progress * 2.0).clamp(0.0, 1.0);
    _drawTorrentialStreamSegment(canvas, size, p1, center, pipeWidth, firstHalfProgress, bankBias, fillPaint, highlightPaint);

    // Fill junction when first leg reaches center
    if (firstHalfProgress >= 0.85) {
      final junctionAlpha = ((firstHalfProgress - 0.85) / 0.15).clamp(0.0, 1.0);
      junctionPaint.color = fillPaint.color.withValues(alpha: junctionAlpha);
      canvas.drawCircle(center, junctionRadius, junctionPaint);
    }

    // Second half surges around the bend with outer-wall centrifugal momentum
    if (progress > 0.40) {
      final secondHalfProgress = ((progress - 0.40) / 0.60).clamp(0.0, 1.0);
      _drawTorrentialStreamSegment(canvas, size, center, p2, pipeWidth, secondHalfProgress, -bankBias, fillPaint, highlightPaint);
    }
  }

  /// Renders an ampolla dead-end with fluid rushing into neck and filling glass flask
  void _drawTorrentialDeadEnd(
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

    // 1. Inundate the neck stem first (progress 0.0 -> 0.45)
    final stemProgress = (progress / 0.45).clamp(0.0, 1.0);
    _drawTorrentialStreamSegment(canvas, size, edge, bulbCenter, pipeWidth, stemProgress, bankBias, fillPaint, highlightPaint);

    // 2. Fill the glass bulb flask with turbulent swirling liquid
    if (progress > 0.30) {
      final bulbFillFrac = ((progress - 0.30) / 0.70).clamp(0.0, 1.0);
      final fluidFillRadius = (bulbRadius - 1.0) * bulbFillFrac;
      final liquidPulse = sin(shimmerProgress * 2 * pi) * 2.5;

      if (fluidFillRadius > 0.5) {
        fillPaint.style = PaintingStyle.fill;
        canvas.drawCircle(bulbCenter, fluidFillRadius, fillPaint);

        // Swirling bright fluid core with luminous vortex
        canvas.drawCircle(
          bulbCenter,
          ((fluidFillRadius * 0.75) + liquidPulse).clamp(0.0, bulbRadius),
          Paint()
            ..color = Color.lerp(
              theme.flowColor,
              theme.flowColorLight,
              (0.45 + (sin(shimmerProgress * 2 * pi) * 0.28)).clamp(0.0, 1.0),
            )!
            ..style = PaintingStyle.fill,
        );

        // Dynamic swirling foam ring in the ampolla
        final foamRadius = (fluidFillRadius * 0.88).clamp(1.0, bulbRadius);
        canvas.drawCircle(
          bulbCenter,
          foamRadius,
          Paint()
            ..color = Colors.white.withValues(alpha: (0.35 * bulbFillFrac))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );

        // Rising carbonated "glub glub" bubbles inside the ampolla
        final bubbleCount = (bulbFillFrac * 5).toInt() + 1;
        for (int b = 0; b < bubbleCount; b++) {
          final bPhase = (shimmerProgress + (b * 0.22)) % 1.0;
          final bOffset = Offset(
            sin((bPhase + b) * 2 * pi) * (fluidFillRadius * 0.55),
            cos((bPhase + b) * 2 * pi) * (fluidFillRadius * 0.55) - (bPhase * 5.0),
          );
          canvas.drawCircle(
            bulbCenter + bOffset,
            (fluidFillRadius * 0.16).clamp(1.8, 6.5),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.90)
              ..style = PaintingStyle.fill,
          );
        }
      }

      // Magic Cauldron Reveal: render goodie image emerging from turbulence
      if (goodieImage != null) {
        CauldronRevealPainter.paintGoodieInBulb(
          canvas,
          goodieImage!,
          bulbCenter,
          bulbRadius,
          progress,
          shimmerProgress,
        );
      }
    }
  }

  /// Draws traveling caustic sunlight ripples and micro-bubbles along full connected river pipes
  void _drawTravelingCausticRipples(
    Canvas canvas,
    Offset from,
    Offset to,
    Offset u,
    double length,
    double halfW,
    double shimmerPhase,
  ) {
    final glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    // 2 traveling caustic glints moving downstream
    for (int g = 0; g < 2; g++) {
      final glintFrac = (shimmerPhase + (g * 0.50)) % 1.0;
      final pGlint = from + (u * (length * glintFrac));
      final glintWidth = (halfW * 0.45) * (1.0 + (sin((shimmerPhase + g) * pi * 2) * 0.25));
      final glintHeight = 2.2;

      canvas.save();
      canvas.translate(pGlint.dx, pGlint.dy);
      canvas.rotate(atan2(u.dy, u.dx));
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: glintWidth * 2.0, height: glintHeight),
        glintPaint,
      );
      canvas.restore();
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

  /// ✚ Draws the 4 Google-colored icons in the corner quadrants of a cross tile.
  /// NW=ruby (red), NE=sun (yellow), SW=droplet (blue), SE=basil (green).
  void _drawCrossGoogleSymbols(Canvas canvas, Size size, Offset center, double pipeWidth) {
    if (crossImages == null || crossImages!.length < 4) return;

    // Icon size = ~35% of quadrant space
    final quadrantSize = (size.width / 2 - pipeWidth / 2);
    final iconSize = quadrantSize * 0.65;
    if (iconSize < 4) return; // Too small to render

    // Quadrant centers: offset from tile center by half the space between pipe edge and tile edge
    final offset = (pipeWidth / 2 + quadrantSize / 2);
    final positions = [
      Offset(center.dx - offset, center.dy - offset), // NW
      Offset(center.dx + offset, center.dy - offset), // NE
      Offset(center.dx - offset, center.dy + offset), // SW
      Offset(center.dx + offset, center.dy + offset), // SE
    ];

    // Google brand colors for subtle glow behind each icon
    final glowColors = [
      const Color(0x30EA4335), // Red glow
      const Color(0x30FBBC04), // Yellow glow
      const Color(0x304285F4), // Blue glow
      const Color(0x3034A853), // Green glow
    ];

    for (int i = 0; i < 4; i++) {
      final img = crossImages![i];
      if (img == null) continue;

      final pos = positions[i];

      // Subtle colored glow circle behind icon
      final glowPaint = Paint()
        ..color = glowColors[i]
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(pos, iconSize * 0.45, glowPaint);

      // Draw the icon image centered in the quadrant
      final srcRect = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      final dstRect = Rect.fromCenter(center: pos, width: iconSize, height: iconSize);
      canvas.drawImageRect(img, srcRect, dstRect, Paint()..filterQuality = FilterQuality.high);
    }
  }

  @override
  bool shouldRepaint(covariant PipePainter oldDelegate) {
    return oldDelegate.tile != tile ||
        oldDelegate.theme != theme ||
        oldDelegate.flowProgress != flowProgress ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.shimmerProgress != shimmerProgress ||
        oldDelegate.goodieImage != goodieImage ||
        oldDelegate.crossImages != crossImages;
  }
}
