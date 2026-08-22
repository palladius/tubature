import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/level_theme.dart';

/// Painting types for creatures
enum CreatureType {
  /// Dragon Source — breathes magic into pipes
  dragon,
  /// Wizard Source — casts spell into pipes
  wizard,
  /// Planet/Rocket Source — launches energy into pipes
  rocket,
  /// Gems Sink — receives dragon's magic
  gems,
  /// Dungeon Sink — receives wizard's spell
  dungeon,
  /// Star cruiser Sink — receives space energy
  starship,
}

/// CustomPainter that renders cute creature icons for Source and Sink tiles.
///
/// These are drawn as simple, bold vector shapes using Canvas operations.
/// Think emoji-style — recognizable at small sizes, charming for kids.
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
      case CreatureType.rocket:
        _paintRocket(canvas, size, center, radius);
      case CreatureType.gems:
        _paintGems(canvas, size, center, radius);
      case CreatureType.dungeon:
        _paintDungeon(canvas, size, center, radius);
      case CreatureType.starship:
        _paintStarship(canvas, size, center, radius);
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

  /// 🚀 Rocket/Planet — circle with ring (Saturn-like)
  void _paintRocket(Canvas canvas, Size size, Offset center, double radius) {
    final color = isConnected ? theme.flowColor : theme.pipeDisconnected;
    final darkColor = isConnected ? theme.flowColorDark : theme.pipeStroke;

    // Planet body
    canvas.drawCircle(center, radius * 0.75, Paint()..color = color);
    canvas.drawCircle(
        center,
        radius * 0.75,
        Paint()
          ..color = darkColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Ring (ellipse around the planet)
    final ringRect = Rect.fromCenter(
        center: center, width: radius * 2.2, height: radius * 0.7);
    canvas.drawOval(
        ringRect,
        Paint()
          ..color = darkColor.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);

    // Small crater dots
    canvas.drawCircle(
        center.translate(-radius * 0.2, -radius * 0.15),
        radius * 0.1,
        Paint()..color = Colors.white.withValues(alpha: 0.4));
    canvas.drawCircle(
        center.translate(radius * 0.25, radius * 0.2),
        radius * 0.08,
        Paint()..color = Colors.white.withValues(alpha: 0.3));
  }

  /// 💎 Gems/Treasure — diamond shape with sparkles
  void _paintGems(Canvas canvas, Size size, Offset center, double radius) {
    final color = isConnected ? theme.flowColor : theme.pipeDisconnected;
    final darkColor = isConnected ? theme.flowColorDark : theme.pipeStroke;

    // Main diamond
    final gemPath = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius * 0.7, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius * 0.7, center.dy)
      ..close();
    canvas.drawPath(gemPath, Paint()..color = color);
    canvas.drawPath(
        gemPath,
        Paint()
          ..color = darkColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Inner facet lines
    canvas.drawLine(
        Offset(center.dx - radius * 0.7, center.dy),
        Offset(center.dx, center.dy - radius * 0.4),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..strokeWidth = 1.5);
    canvas.drawLine(
        Offset(center.dx + radius * 0.7, center.dy),
        Offset(center.dx, center.dy - radius * 0.4),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..strokeWidth = 1.5);

    // Sparkle dots
    if (isConnected) {
      _drawStar(canvas, Offset(center.dx + radius * 0.6, center.dy - radius * 0.6),
          radius * 0.12, const Color(0xFFFFD54F));
      _drawStar(canvas, Offset(center.dx - radius * 0.5, center.dy - radius * 0.7),
          radius * 0.08, Colors.white);
    }
  }

  /// 🏰 Dungeon door — arched doorway
  void _paintDungeon(Canvas canvas, Size size, Offset center, double radius) {
    final color = isConnected ? theme.flowColor : theme.pipeDisconnected;
    final darkColor = isConnected ? theme.flowColorDark : theme.pipeStroke;

    // Door frame (rectangle + arch)
    final doorRect = RRect.fromRectAndCorners(
      Rect.fromCenter(center: center, width: radius * 1.4, height: radius * 1.8),
      topLeft: Radius.circular(radius * 0.7),
      topRight: Radius.circular(radius * 0.7),
    );
    canvas.drawRRect(doorRect, Paint()..color = darkColor);

    // Inner door (slightly smaller, colored)
    final innerRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
          center: center.translate(0, 1),
          width: radius * 1.1,
          height: radius * 1.5),
      topLeft: Radius.circular(radius * 0.55),
      topRight: Radius.circular(radius * 0.55),
    );
    canvas.drawRRect(innerRect, Paint()..color = color);

    // Door handle
    canvas.drawCircle(
        Offset(center.dx + radius * 0.25, center.dy + radius * 0.2),
        radius * 0.1,
        Paint()..color = const Color(0xFFFFD54F));
  }

  /// 🚀 Star cruiser — simple spaceship shape
  void _paintStarship(Canvas canvas, Size size, Offset center, double radius) {
    final color = isConnected ? theme.flowColor : theme.pipeDisconnected;
    final darkColor = isConnected ? theme.flowColorDark : theme.pipeStroke;

    // Main body (elongated diamond)
    final shipPath = Path()
      ..moveTo(center.dx, center.dy - radius * 1.1)
      ..lineTo(center.dx + radius * 0.5, center.dy + radius * 0.3)
      ..lineTo(center.dx, center.dy + radius * 0.8)
      ..lineTo(center.dx - radius * 0.5, center.dy + radius * 0.3)
      ..close();
    canvas.drawPath(shipPath, Paint()..color = color);
    canvas.drawPath(
        shipPath,
        Paint()
          ..color = darkColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Wings
    for (final sign in [-1.0, 1.0]) {
      final wingPath = Path()
        ..moveTo(center.dx + radius * 0.5 * sign, center.dy + radius * 0.3)
        ..lineTo(center.dx + radius * 1.0 * sign, center.dy + radius * 0.8)
        ..lineTo(center.dx + radius * 0.3 * sign, center.dy + radius * 0.6)
        ..close();
      canvas.drawPath(wingPath, Paint()..color = darkColor.withValues(alpha: 0.7));
    }

    // Cockpit window
    canvas.drawCircle(
        Offset(center.dx, center.dy - radius * 0.3),
        radius * 0.15,
        Paint()..color = const Color(0xFF90CAF9));
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
