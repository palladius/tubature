import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../logic/performance_config.dart';
import '../logic/puffin_login.dart';
import '../models/cauldron_goodie.dart';
import '../models/cauldron_goodies_catalog.dart';
import '../services/goodies_image_service.dart';
import 'leaderboard_screen.dart';
import 'polaroid_mosaic_overlay.dart';
import '../widgets/goodie_carousel_dialog.dart';

/// Victory overlay shown when the player completes a level.
///
/// Features confetti animation, multilingual celebration text,
/// move count, revealed goodies gallery, and next level / play again buttons.
class VictoryOverlay extends StatefulWidget {
  final int moveCount;
  final int? score;
  final List<CauldronGoodie> revealedGoodies;
  final VoidCallback onNextLevel;
  final VoidCallback onPlayAgain;

  const VictoryOverlay({
    super.key,
    required this.moveCount,
    this.score,
    this.revealedGoodies = const [],
    required this.onNextLevel,
    required this.onPlayAgain,
  });

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _confettiController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final Random _random = Random();

  // Draggable card position — lets user move it to admire cauldron goodies 🧪
  Offset _dragOffset = Offset.zero;

  // Random celebration text
  static const _celebrations = [
    '✨ MAGNIFICO! ✨',
    '🎉 GREAT JOB! 🎉',
    '🌟 BRAVO! 🌟',
    '🎊 WOW! 🎊',
    '💫 FANTASTICO! 💫',
    '🏆 PERFETTO! 🏆',
  ];

  late String _celebrationText;
  late List<_ConfettiPiece> _confetti;

  @override
  void initState() {
    super.initState();
    _celebrationText = _celebrations[_random.nextInt(_celebrations.length)];
    _confetti = List.generate(
      PerformanceConfig.victoryConfettiCount,
      (_) => _ConfettiPiece.random(_random),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    if (PerformanceConfig.isLowEnd) {
      // Single confetti burst on Raspberry Pi so idle CPU drops to 0% after 3s
      _confettiController.forward();
    } else {
      _confettiController.repeat();
    }

    _fadeController.forward();

    if (widget.revealedGoodies.isNotEmpty) {
      GoodiesImageService.preloadImages(widget.revealedGoodies).then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// Show goodies carousel overlay starting at the tapped goodie index 🎡
  void _openGoodiesCarousel(BuildContext context, int initialIndex) {
    GoodieCarouselDialog.show(
      context,
      goodies: widget.revealedGoodies,
      initialIndex: initialIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Semi-transparent backdrop — tap to reset card position
          GestureDetector(
            onTap: () => setState(() => _dragOffset = Offset.zero),
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),

          // Confetti layer (isolated in RepaintBoundary + IgnorePointer)
          IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      confetti: _confetti,
                      progress: _confettiController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),

          // Victory card — DRAGGABLE & RESPONSIVE! 🧪
          Center(
            child: Transform.translate(
              offset: _dragOffset,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _dragOffset += details.delta;
                  });
                },
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 380,
                      maxHeight: MediaQuery.of(context).size.height * 0.88,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Drag handle indicator ⬍
                            Container(
                              width: 40,
                              height: 5,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCCCCC),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _celebrationText,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Solved in ${widget.moveCount} moves!',
                              style: const TextStyle(
                                fontSize: 17,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListenableBuilder(
                              listenable: PuffinLogin.instance,
                              builder: (context, _) {
                                final user = PuffinLogin.instance.currentUser ??
                                    getPuffinProfileById('guest');
                                final resolvedScore = widget.score ??
                                    calculateTubatureScore(
                                      difficulty: 'Easy',
                                      totalTiles: 36,
                                      moves: widget.moveCount,
                                      levelsCompleted: 0,
                                    );
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF121528),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(color: user.color, width: 1.8),
                                      ),
                                      child: Text(
                                        '${user.emoji} ${user.shortName} • $resolvedScore pt',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: user.color,
                                        ),
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => LeaderboardScreen.showModal(context),
                                      icon: const Text('🏆', style: TextStyle(fontSize: 14)),
                                      label: const Text(
                                        'Hall of Fame',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF121528),
                                        side: const BorderSide(color: Color(0xFFFACC15), width: 1.8),
                                        backgroundColor: const Color(0xFFFEF9C3),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            // Goodies gallery 🧪
                            if (widget.revealedGoodies.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text(
                                '🧪 Discovered:',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF999999),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                alignment: WrapAlignment.center,
                                children: widget.revealedGoodies.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final goodie = entry.value;
                                  final ui.Image? img = GoodiesImageService.getImage(goodie.id);
                                  return GestureDetector(
                                    key: ValueKey('goodie_badge_${goodie.id}'),
                                    onTap: () => _openGoodiesCarousel(context, index),
                                    child: Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: goodie.isLegendary
                                              ? const Color(0xFFFFD700)
                                              : const Color(0xFFDDDDDD),
                                          width: goodie.isLegendary ? 2 : 1,
                                        ),
                                        boxShadow: goodie.isLegendary
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: ClipOval(
                                        child: img != null
                                            ? RawImage(image: img, fit: BoxFit.cover)
                                            : Image.asset(
                                                goodie.assetPath,
                                                fit: BoxFit.cover,
                                                errorBuilder: (ctx, err, stack) => Center(
                                                  child: Text(
                                                    goodie.emoji,
                                                    style: const TextStyle(fontSize: 20),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 220,
                                maxWidth: 260,
                                minHeight: 48,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final goodiesToShow = widget.revealedGoodies.isNotEmpty
                                        ? widget.revealedGoodies
                                        : CauldronGoodiesCatalog.all;
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => PolaroidMosaicOverlay(
                                          goodies: goodiesToShow,
                                          moveCount: widget.moveCount,
                                          onNextLevel: () {
                                            Navigator.of(ctx).pop();
                                            widget.onNextLevel();
                                          },
                                          onPlayAgain: () {
                                            Navigator.of(ctx).pop();
                                            widget.onPlayAgain();
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Text('📸', style: TextStyle(fontSize: 18)),
                                  label: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Mosaico Polaroid ✨',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF673AB7),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 220,
                                maxWidth: 260,
                                minHeight: 52,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: widget.onNextLevel,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 3,
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Next Level 🐉',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: widget.onPlayAgain,
                              child: const Text(
                                'Play Again 🔄',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPiece {
  final double x; // 0.0 to 1.0
  final double speed; // fall speed multiplier
  final double size;
  final Color color;
  final double wobble; // horizontal wobble amplitude

  const _ConfettiPiece({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.wobble,
  });

  static _ConfettiPiece random(Random rng) {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF9C27B0),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFFFFEB3B),
      const Color(0xFF00BCD4),
    ];
    return _ConfettiPiece(
      x: rng.nextDouble(),
      speed: 0.3 + rng.nextDouble() * 0.7,
      size: 4 + rng.nextDouble() * 8,
      color: colors[rng.nextInt(colors.length)],
      wobble: 0.01 + rng.nextDouble() * 0.03,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> confetti;
  final double progress;

  const _ConfettiPainter({required this.confetti, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in confetti) {
      final y = (progress * piece.speed * size.height * 1.5) % (size.height + 20) - 10;
      final x = piece.x * size.width +
          sin(progress * 2 * pi * 3 + piece.x * 10) * piece.wobble * size.width;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: piece.size, height: piece.size * 1.5),
          Radius.circular(2),
        ),
        Paint()..color = piece.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
