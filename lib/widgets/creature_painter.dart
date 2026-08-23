import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/level_theme.dart';

/// Painting types for fantasy source creatures
enum CreatureType {
  /// 🐉 Dragon Source — breathes magic into pipes
  dragon,
  /// 🧙 Wizard Source — casts spells into pipes
  wizard,
  /// 💎 Crystal Gemstone Source — radiates magical fluid into pipes
  crystal,
}

/// CustomPainter that renders cute fantasy creature icons for Source tiles.
///
/// Drawn as simple, bold vector shapes using Canvas operations.
/// Recognized at small sizes, charming for kids.
class CreaturePainter extends CustomPainter {
  final CreatureType creatureType;
  final LevelTheme theme;
  final bool isConnected;

  const CreaturePainter({
    required this.creatureType,
    required this.theme,
    required this.isConnected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    switch (creatureType) {
      case CreatureType.dragon:
        _paintDragon(canvas, size, center, radius);
      case CreatureType.wizard:
        _paintWizard(canvas, size, center, radius);
      case CreatureType.crystal:
        _paintCrystal(canvas, size, center, radius);
    }
  }

  /// 🐉 Baby dragon — round body, small wings, cute eyes
  void _paintDragon(Canvas canvas, Size size, Offset center, double radius) {
    final color = isConnected ? theme.flowColor : theme.pipeDisconnected;
    final darkColor = isConnected ? theme.flowColorDark : theme.pipeStroke;

    // Body (round)
    canvas.drawCircle(
        center, radius, Paint()..color = color);
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = darkColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Eyes (two white dots with black pupils)
    final eyeSize = radius * 0.2;
    final eyeOffsetX = radius * 0.35;
    final eyeOffsetY = radius * -0.15;

    for (final sign in [-1.0, 1.0]) {
      final eyeCenter =
          Offset(center.dx + eyeOffsetX * sign, center.dy + eyeOffsetY);
      canvas.drawCircle(eyeCenter, eyeSize, Paint()..color = Colors.white);
      canvas.drawCircle(
          eyeCenter.translate(sign * 1, 1),
          eyeSize * 0.5,
          Paint()..color = const Color(0xFF222222));
    }

    // Small wings (triangles on each side)
    final wingPaint = Paint()..color = color.withValues(alpha: 0.6);
    for (final sign in [-1.0, 1.0]) {
      final wingPath = Path()
        ..moveTo(center.dx + radius * 0.7 * sign, center.dy - radius * 0.3)
        ..lineTo(center.dx + radius * 1.3 * sign, center.dy - radius * 0.8)
        ..lineTo(center.dx + radius * 1.1 * sign, center.dy + radius * 0.1)
        ..close();
      canvas.drawPath(wingPath, wingPaint);
      canvas.drawPath(
          wingPath,
          Paint()
            ..color = darkColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }

    // Small horns
    final hornPaint = Paint()..color = const Color(0xFFFFD54F);
    for (final sign in [-0.5, 0.5]) {
      canvas.drawCircle(
          Offset(center.dx + radius * sign, center.dy - radius * 0.85),
          radius * 0.12,
          hornPaint);
    }
  }

  /// 🧙 Wizard — pointy hat, round body, stars
  void _paintWizard(Canvas canvas, Size size, Offset center, double radius) {
    final color = isConnected ? theme.flowColor : theme.pipeDisconnected;
    final darkColor = isConnected ? theme.flowColorDark : theme.pipeStroke;

    // Body (round, slightly lower)
    final bodyCenter = Offset(center.dx, center.dy + radius * 0.2);
    canvas.drawCircle(bodyCenter, radius * 0.85, Paint()..color = color);
    canvas.drawCircle(
        bodyCenter,
        radius * 0.85,
        Paint()
          ..color = darkColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Pointy hat (triangle)
    final hatPath = Path()
      ..moveTo(center.dx, center.dy - radius * 1.4)
      ..lineTo(center.dx - radius * 0.7, center.dy - radius * 0.3)
      ..lineTo(center.dx + radius * 0.7, center.dy - radius * 0.3)
      ..close();
    canvas.drawPath(hatPath, Paint()..color = darkColor);
    // Star on hat
    _drawStar(canvas, Offset(center.dx, center.dy - radius * 0.9),
        radius * 0.15, const Color(0xFFFFD54F));

    // Eyes
    final eyeSize = radius * 0.15;
    for (final sign in [-1.0, 1.0]) {
      final eyeCenter =
          Offset(bodyCenter.dx + radius * 0.3 * sign, bodyCenter.dy - radius * 0.1);
      canvas.drawCircle(eyeCenter, eyeSize, Paint()..color = Colors.white);
      canvas.drawCircle(
          eyeCenter, eyeSize * 0.5, Paint()..color = const Color(0xFF222222));
    }
  }

  /// 💎 Cut Gemstone Crystal — sparkling faceted diamond shape
  void _paintCrystal(Canvas canvas, Size size, Offset center, double radius) {
    final color = isConnected ? theme.flowColor : theme.pipeDisconnected;
    final darkColor = isConnected ? theme.flowColorDark : theme.pipeStroke;
    final lightColor = isConnected ? theme.flowColorLight : const Color(0xFFE0E0E0);

    final r = radius * 0.95;

    // Diamond polygon points
    final top = Offset(center.dx, center.dy - r * 1.1);
    final right = Offset(center.dx + r, center.dy - r * 0.1);
    final bottom = Offset(center.dx, center.dy + r * 1.1);
    final left = Offset(center.dx - r, center.dy - r * 0.1);
    final innerTop = Offset(center.dx, center.dy - r * 0.3);

    final mainGemPath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();

    // Fill base gem
    canvas.drawPath(mainGemPath, Paint()..color = color);
    canvas.drawPath(
        mainGemPath,
        Paint()
          ..color = darkColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0);

    // Facet lines
    final facetPaint = Paint()
      ..color = darkColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawLine(top, innerTop, facetPaint);
    canvas.drawLine(left, innerTop, facetPaint);
    canvas.drawLine(right, innerTop, facetPaint);
    canvas.drawLine(bottom, innerTop, facetPaint);

    // Top-left facet highlight
    final highlightFacet = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(innerTop.dx, innerTop.dy)
      ..close();
    canvas.drawPath(
        highlightFacet,
        Paint()
          ..color = lightColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill);

    // Specular sparkle star on top facet
    if (isConnected) {
      _drawStar(
        canvas,
        Offset(center.dx - r * 0.35, center.dy - r * 0.45),
        r * 0.25,
        Colors.white,
      );
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final outerX = center.dx + radius * math.cos(angle);
      final outerY = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      final innerAngle = angle + math.pi / 4;
      final innerX = center.dx + radius * 0.4 * math.cos(innerAngle);
      final innerY = center.dy + radius * 0.4 * math.sin(innerAngle);
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CreaturePainter oldDelegate) {
    return creatureType != oldDelegate.creatureType ||
        isConnected != oldDelegate.isConnected ||
        theme != oldDelegate.theme;
  }
}
