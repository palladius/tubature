import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/cauldron_goodie.dart';
import '../services/goodies_image_service.dart';

/// A vintage Polaroid-style photo card widget.
///
/// Features:
/// - Classic Polaroid white frame with thick bottom chin for title
/// - Photo area displaying goodie image / asset or custom content
/// - Rotation angle clamped within ±30° (±pi/6 radians)
/// - Realistic drop shadows for depth and organic layering
/// - Tap interaction support
class PolaroidWidget extends StatelessWidget {
  final CauldronGoodie? goodie;
  final String? title;
  final ui.Image? preloadedImage;
  final double rotationAngle;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final double elevation;

  /// Maximum allowed rotation angle in radians (30 degrees).
  static const double maxRotationAngle = 30.0 * pi / 180.0;

  const PolaroidWidget({
    super.key,
    this.goodie,
    this.title,
    this.preloadedImage,
    this.rotationAngle = 0.0,
    this.width = 140,
    this.height = 175,
    this.onTap,
    this.elevation = 8.0,
  });

  /// The rotation angle clamped to [-maxRotationAngle, +maxRotationAngle].
  double get clampedRotationAngle =>
      rotationAngle.clamp(-maxRotationAngle, maxRotationAngle);

  String get effectiveTitle =>
      title ?? goodie?.displayName ?? '';

  @override
  Widget build(BuildContext context) {
    final clampedAngle = clampedRotationAngle;
    final cachedImg = preloadedImage ??
        (goodie != null ? GoodiesImageService.getImage(goodie!.id) : null);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Transform.rotate(
        angle: clampedAngle,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F5),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: elevation * 1.5,
                spreadRadius: 1,
                offset: Offset(
                  sin(clampedAngle) * 3 + 2,
                  elevation * 0.7,
                ),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            width * 0.05,
            width * 0.05,
            width * 0.05,
            width * 0.10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E28),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  padding: EdgeInsets.all(width * 0.04),
                  child: _buildPhotoContent(cachedImg),
                ),
              ),
              SizedBox(height: width * 0.04),
              // Bottom chin caption
              SizedBox(
                height: (width * 0.12).clamp(24.0, 48.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (goodie != null) ...[
                        Text(
                          goodie!.emoji,
                          style: TextStyle(
                            fontSize: (width * 0.065).clamp(14.0, 24.0),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          effectiveTitle,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Caveat',
                            fontSize: (width * 0.065).clamp(14.0, 22.0),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C2C2C),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoContent(ui.Image? img) {
    if (img != null) {
      return RawImage(
        image: img,
        fit: BoxFit.contain,
      );
    }

    if (goodie != null) {
      return Image.asset(
        goodie!.assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }

    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Text(
        goodie?.emoji ?? '✨',
        style: const TextStyle(fontSize: 32),
      ),
    );
  }
}
