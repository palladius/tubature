import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Renders a CauldronGoodie image inside an ampolla bulb with a
/// turbulence-to-clarity convergence animation.
class CauldronRevealPainter {
  /// Calculate image opacity based on flow progress phase
  static double convergenceOpacity(double flowProgress) {
    if (flowProgress < 0.30) return 0.0;  // Phase 0: no image
    if (flowProgress < 0.50) {
      // Phase 1: Turbulent Chaos — very faint (0.05 → 0.15)
      final t = (flowProgress - 0.30) / 0.20;
      return 0.05 + t * 0.10;
    }
    if (flowProgress < 0.75) {
      // Phase 2: Emerging Form — partial (0.15 → 0.50)
      final t = (flowProgress - 0.50) / 0.25;
      return 0.15 + t * 0.35;
    }
    if (flowProgress < 0.95) {
      // Phase 3: Convergence — clear (0.50 → 0.90)
      final t = (flowProgress - 0.75) / 0.20;
      return 0.50 + t * 0.40;
    }
    // Phase 4: Full Reveal (0.90 → 1.0)
    final t = (flowProgress - 0.95) / 0.05;
    return 0.90 + t * 0.10;
  }

  /// Calculate turbulence distortion intensity (1.0 = max chaos, 0.0 = calm)
  static double turbulenceIntensity(double flowProgress) {
    if (flowProgress < 0.30) return 1.0;
    if (flowProgress >= 0.95) return 0.0;
    return 1.0 - ((flowProgress - 0.30) / 0.65).clamp(0.0, 1.0);
  }

  /// Render the goodie image inside the ampolla bulb with convergence effect
  static void paintGoodieInBulb(
    Canvas canvas,
    ui.Image image,
    Offset bulbCenter,
    double bulbRadius,
    double flowProgress,
    double shimmerProgress,
  ) {
    final opacity = convergenceOpacity(flowProgress);
    if (opacity <= 0.0) return;
    
    final turbulence = turbulenceIntensity(flowProgress);
    final imageRadius = bulbRadius * 0.85; // slightly smaller than bulb
    
    canvas.save();
    
    // Circular clip to bulb
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: bulbCenter, radius: imageRadius)),
    );
    
    // Source rect (full image)
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    // Destination rect (fit in bulb circle)
    final dst = Rect.fromCircle(center: bulbCenter, radius: imageRadius);
    
    final paint = Paint()
      ..filterQuality = FilterQuality.medium;
    
    if (turbulence > 0.1) {
      // Draw multiple offset copies with low alpha for blur/turbulence effect
      final copies = (turbulence * 6).ceil().clamp(1, 8);
      final copyAlpha = (opacity / copies).clamp(0.02, 0.3);
      
      for (int i = 0; i < copies; i++) {
        final angle = (shimmerProgress * 2 * pi) + (i * 2 * pi / copies);
        final offsetDist = turbulence * imageRadius * 0.25;
        final offset = Offset(
          cos(angle) * offsetDist,
          sin(angle) * offsetDist,
        );
        
        canvas.drawImageRect(
          image,
          src,
          dst.shift(offset),
          paint..color = Color.fromRGBO(255, 255, 255, copyAlpha),
        );
      }
    } else {
      // Clean render with full opacity
      canvas.drawImageRect(
        image,
        src,
        dst,
        paint..color = Color.fromRGBO(255, 255, 255, opacity),
      );
    }
    
    // Phase 4 golden shimmer glow
    if (flowProgress >= 0.95) {
      final glowPulse = (sin(shimmerProgress * 4 * pi) * 0.3 + 0.7).clamp(0.0, 1.0);
      canvas.drawCircle(
        bulbCenter,
        imageRadius + 2.0,
        Paint()
          ..color = Color.fromRGBO(255, 215, 0, 0.3 * glowPulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );
    }
    
    canvas.restore();
  }
}
