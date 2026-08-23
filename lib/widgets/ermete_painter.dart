import 'dart:math';
import 'package:flutter/material.dart';

/// Cartoon Canvas painter for Ermete (The Ferrarese Plumber from La Bassa)
/// Featuring a big prominent Ferrarese nose, plumber cap, bushy mustache,
/// and animated mouth flap synchronized to voice playback.
class ErmetePainter extends CustomPainter {
  final double mouthOpenProgress; // 0.0 = closed, 1.0 = wide open
  final double blinkProgress;     // 0.0 = open eyes, 1.0 = closed eyes
  final double eyebrowLift;       // Eyebrow emotional bounce
  final bool isHappy;             // Happy smile vs stressed frown

  const ErmetePainter({
    required this.mouthOpenProgress,
    this.blinkProgress = 0.0,
    this.eyebrowLift = 0.0,
    this.isHappy = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 120.0;

    // Head base position
    final headCenter = Offset(center.dx, center.dy + (8 * scale));
    final headRadius = 38 * scale;

    final skinColor = const Color(0xFFFFCC99);
    final skinShadow = const Color(0xFFE6A366);
    final capColor = const Color(0xFF2E7D32); // Forest green work cap
    final capBrimColor = const Color(0xFF1B5E20);
    final mustacheColor = const Color(0xFF3E2723); // Dark brown bristly mustache
    final noseColor = const Color(0xFFFFA07A); // Rosy big nose

    // 1. EAR (Left & Right)
    final earPaint = Paint()..color = skinShadow..style = PaintingStyle.fill;
    final earOutline = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2.0 * scale;
    
    // Left ear
    final leftEar = Offset(headCenter.dx - (36 * scale), headCenter.dy + (2 * scale));
    canvas.drawCircle(leftEar, 8 * scale, earPaint);
    canvas.drawCircle(leftEar, 8 * scale, earOutline);

    // Right ear
    final rightEar = Offset(headCenter.dx + (36 * scale), headCenter.dy + (2 * scale));
    canvas.drawCircle(rightEar, 8 * scale, earPaint);
    canvas.drawCircle(rightEar, 8 * scale, earOutline);

    // 2. HEAD BASE
    final headPaint = Paint()..color = skinColor..style = PaintingStyle.fill;
    final headOutline = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2.5 * scale;
    canvas.drawCircle(headCenter, headRadius, headPaint);
    canvas.drawCircle(headCenter, headRadius, headOutline);

    // 3. EYES
    final eyeY = headCenter.dy - (4 * scale);
    final leftEyeCenter = Offset(headCenter.dx - (16 * scale), eyeY);
    final rightEyeCenter = Offset(headCenter.dx + (16 * scale), eyeY);
    final eyeRadius = 7.5 * scale;

    if (blinkProgress < 0.8) {
      // Open eye whites
      final eyeWhitePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
      final eyeOutlinePaint = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 1.8 * scale;
      canvas.drawCircle(leftEyeCenter, eyeRadius, eyeWhitePaint);
      canvas.drawCircle(leftEyeCenter, eyeRadius, eyeOutlinePaint);
      canvas.drawCircle(rightEyeCenter, eyeRadius, eyeWhitePaint);
      canvas.drawCircle(rightEyeCenter, eyeRadius, eyeOutlinePaint);

      // Pupils (looking slightly forward/excited)
      final pupilPaint = Paint()..color = const Color(0xFF212121)..style = PaintingStyle.fill;
      canvas.drawCircle(leftEyeCenter + Offset(0, 1 * scale), 4 * scale, pupilPaint);
      canvas.drawCircle(rightEyeCenter + Offset(0, 1 * scale), 4 * scale, pupilPaint);

      // Sparkle glints
      final glintPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
      canvas.drawCircle(leftEyeCenter + Offset(-1.5 * scale, -1.5 * scale), 1.5 * scale, glintPaint);
      canvas.drawCircle(rightEyeCenter + Offset(-1.5 * scale, -1.5 * scale), 1.5 * scale, glintPaint);
    } else {
      // Closed happy blink eyes (curved lines)
      final blinkPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * scale
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: leftEyeCenter, radius: eyeRadius * 0.8), pi * 0.2, pi * 0.6, false, blinkPaint);
      canvas.drawArc(Rect.fromCircle(center: rightEyeCenter, radius: eyeRadius * 0.8), pi * 0.2, pi * 0.6, false, blinkPaint);
    }

    // 4. BUSHY EYEBROWS (Animated bounce)
    final browY = eyeY - (10 * scale) - (eyebrowLift * 4 * scale);
    final browPaint = Paint()
      ..color = mustacheColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scale
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(leftEyeCenter.dx - (8 * scale), browY + (1 * scale)),
      Offset(leftEyeCenter.dx + (8 * scale), browY - (2 * scale)),
      browPaint,
    );
    canvas.drawLine(
      Offset(rightEyeCenter.dx - (8 * scale), browY - (2 * scale)),
      Offset(rightEyeCenter.dx + (8 * scale), browY + (1 * scale)),
      browPaint,
    );

    // 5. ANIMATED MOUTH (Phoneme Flapping behind mustache)
    final mouthY = headCenter.dy + (16 * scale);
    final mouthCenter = Offset(headCenter.dx, mouthY);
    final mouthHeight = (4 * scale) + (mouthOpenProgress * 14 * scale);
    final mouthWidth = (14 * scale) + (mouthOpenProgress * 4 * scale);

    if (mouthOpenProgress > 0.1) {
      // Open mouth cavity (dark red)
      final mouthCavity = Paint()..color = const Color(0xFF800000)..style = PaintingStyle.fill;
      final mouthPath = Path()
        ..addOval(Rect.fromCenter(center: mouthCenter, width: mouthWidth, height: mouthHeight));
      canvas.drawPath(mouthPath, mouthCavity);

      // Pink tongue
      final tonguePaint = Paint()..color = const Color(0xFFFF6B81)..style = PaintingStyle.fill;
      canvas.drawCircle(mouthCenter + Offset(0, mouthHeight * 0.25), mouthWidth * 0.3, tonguePaint);

      // Top teeth
      final teethPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromCenter(center: mouthCenter - Offset(0, mouthHeight * 0.3), width: mouthWidth * 0.6, height: mouthHeight * 0.25),
        teethPaint,
      );
    } else {
      // Closed mouth line
      final closedMouth = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * scale
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(mouthCenter - Offset(6 * scale, 0), mouthCenter + Offset(6 * scale, 0), closedMouth);
    }

    // 6. GIANT FERRARESE NOSE (Prominent & Rosy 👃)
    final noseCenter = Offset(headCenter.dx, headCenter.dy + (4 * scale));
    final noseRadiusX = 14 * scale;
    final noseRadiusY = 17 * scale;

    final nosePath = Path()
      ..moveTo(noseCenter.dx - (noseRadiusX * 0.8), noseCenter.dy - (noseRadiusY * 0.6))
      ..cubicTo(
        noseCenter.dx - (noseRadiusX * 1.3), noseCenter.dy + (noseRadiusY * 0.6),
        noseCenter.dx - (noseRadiusX * 0.4), noseCenter.dy + noseRadiusY,
        noseCenter.dx, noseCenter.dy + noseRadiusY,
      )
      ..cubicTo(
        noseCenter.dx + (noseRadiusX * 0.4), noseCenter.dy + noseRadiusY,
        noseCenter.dx + (noseRadiusX * 1.3), noseCenter.dy + (noseRadiusY * 0.6),
        noseCenter.dx + (noseRadiusX * 0.8), noseCenter.dy - (noseRadiusY * 0.6),
      )
      ..close();

    final nosePaint = Paint()..color = noseColor..style = PaintingStyle.fill;
    final noseOutline = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2.2 * scale;
    canvas.drawPath(nosePath, nosePaint);
    canvas.drawPath(nosePath, noseOutline);

    // Nose bridge highlight
    final noseGlint = Paint()..color = Colors.white.withValues(alpha: 0.55)..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: noseCenter + Offset(-3 * scale, -2 * scale), width: 5 * scale, height: 8 * scale),
      noseGlint,
    );

    // 7. THICK BRISTLY FERRARESE MUSTACHE
    final mustacheY = noseCenter.dy + (10 * scale);
    final mustachePath = Path()
      // Left mustache wing
      ..moveTo(headCenter.dx, mustacheY)
      ..cubicTo(
        headCenter.dx - (14 * scale), mustacheY - (3 * scale),
        headCenter.dx - (26 * scale), mustacheY + (12 * scale),
        headCenter.dx - (32 * scale), mustacheY + (8 * scale),
      )
      ..cubicTo(
        headCenter.dx - (24 * scale), mustacheY + (18 * scale),
        headCenter.dx - (10 * scale), mustacheY + (12 * scale),
        headCenter.dx, mustacheY + (6 * scale),
      )
      // Right mustache wing
      ..cubicTo(
        headCenter.dx + (10 * scale), mustacheY + (12 * scale),
        headCenter.dx + (24 * scale), mustacheY + (18 * scale),
        headCenter.dx + (32 * scale), mustacheY + (8 * scale),
      )
      ..cubicTo(
        headCenter.dx + (26 * scale), mustacheY + (12 * scale),
        headCenter.dx + (14 * scale), mustacheY - (3 * scale),
        headCenter.dx, mustacheY,
      )
      ..close();

    final mustachePaint = Paint()..color = mustacheColor..style = PaintingStyle.fill;
    final mustacheOutline = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2.2 * scale;
    canvas.drawPath(mustachePath, mustachePaint);
    canvas.drawPath(mustachePath, mustacheOutline);

    // 8. DISHEVELED PLUMBER CAP (Tilted with backward/side brim)
    final capY = headCenter.dy - (26 * scale);
    final capPath = Path()
      ..moveTo(headCenter.dx - (38 * scale), capY + (12 * scale))
      ..cubicTo(
        headCenter.dx - (36 * scale), capY - (22 * scale),
        headCenter.dx + (36 * scale), capY - (22 * scale),
        headCenter.dx + (38 * scale), capY + (12 * scale),
      )
      ..close();

    final capPaint = Paint()..color = capColor..style = PaintingStyle.fill;
    final capOutline = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2.5 * scale;
    canvas.drawPath(capPath, capPaint);
    canvas.drawPath(capPath, capOutline);

    // Cap Brim
    final brimRect = Rect.fromCenter(center: Offset(headCenter.dx - (4 * scale), capY + (10 * scale)), width: 84 * scale, height: 16 * scale);
    final brimPaint = Paint()..color = capBrimColor..style = PaintingStyle.fill;
    canvas.drawOval(brimRect, brimPaint);
    canvas.drawOval(brimRect, capOutline);

    // Grease spot on cap
    final greasePaint = Paint()..color = Colors.black38..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(headCenter.dx + (14 * scale), capY - (4 * scale)), 5 * scale, greasePaint);
  }

  @override
  bool shouldRepaint(covariant ErmetePainter oldDelegate) {
    return oldDelegate.mouthOpenProgress != mouthOpenProgress ||
        oldDelegate.blinkProgress != blinkProgress ||
        oldDelegate.eyebrowLift != eyebrowLift ||
        oldDelegate.isHappy != isHappy;
  }
}
