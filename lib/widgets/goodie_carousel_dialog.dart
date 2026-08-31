import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cauldron_goodie.dart';
import '../services/audio_service.dart';
import '../services/goodies_image_service.dart';

/// Interactive modal carousel dialog to browse discovered/catalog goodies in a loop. 🎡
///
/// Supports:
/// - Next / Previous in loop (`<` and `>` buttons)
/// - Horizontal swipe gestures (swipe left for next, swipe right for previous)
/// - Keyboard arrow keys (Left / Right)
/// - Automatic sound playback on discovery / goodie change (e.g. Majjal 🐷 & Motorino 🛵)
/// - Replay sound on tap
class GoodieCarouselDialog extends StatefulWidget {
  final List<CauldronGoodie> goodies;
  final int initialIndex;

  const GoodieCarouselDialog({
    super.key,
    required this.goodies,
    this.initialIndex = 0,
  });

  /// Helper to display the carousel dialog.
  static Future<void> show(
    BuildContext context, {
    required List<CauldronGoodie> goodies,
    int initialIndex = 0,
  }) {
    if (goodies.isEmpty) return Future.value();
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => GoodieCarouselDialog(
        goodies: goodies,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  State<GoodieCarouselDialog> createState() => _GoodieCarouselDialogState();
}

class _GoodieCarouselDialogState extends State<GoodieCarouselDialog> {
  late int _currentIndex;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.goodies.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _playCurrentAudio();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  CauldronGoodie get _currentGoodie => widget.goodies[_currentIndex];

  void _goToPrevious() {
    if (widget.goodies.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + widget.goodies.length) % widget.goodies.length;
    });
    _playCurrentAudio();
  }

  void _goToNext() {
    if (widget.goodies.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.goodies.length;
    });
    _playCurrentAudio();
  }

  void _playCurrentAudio() {
    final goodie = _currentGoodie;
    if (goodie.hasAudio && goodie.audioPath != null) {
      AudioService.playAssetFile(goodie.audioPath!);
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        _goToPrevious();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD ||
          event.logicalKey == LogicalKeyboardKey.space) {
        _goToNext();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goodie = _currentGoodie;
    final img = GoodiesImageService.getImage(goodie.id);
    final rarityColor = goodie.rarity.color == Colors.black ? const Color(0xFFDDDDDD) : goodie.rarity.color;
    final total = widget.goodies.length;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: GestureDetector(
            // Prevent tapping inside card from immediately closing dialog
            onTap: () {},
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -120) {
                // Swiped Left -> Next item in loop
                _goToNext();
              } else if (velocity > 120) {
                // Swiped Right -> Previous item in loop
                _goToPrevious();
              }
            },
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E28),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: rarityColor.withValues(alpha: 0.8),
                  width: goodie.isLegendary ? 3 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: rarityColor.withValues(alpha: goodie.isLegendary ? 0.45 : 0.25),
                    blurRadius: goodie.isLegendary ? 30 : 16,
                    spreadRadius: goodie.isLegendary ? 4 : 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top bar: Counter badge & Close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / $total',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Carousel content with Left & Right nav buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left Button (<)
                      if (total > 1)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: _goToPrevious,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                                border: Border.all(color: Colors.white24, width: 1),
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 48),

                      const SizedBox(width: 12),

                      // Central Coin Avatar
                      Expanded(
                        child: Center(
                          child: GestureDetector(
                            onTap: _playCurrentAudio,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) => ScaleTransition(
                                scale: anim,
                                child: FadeTransition(opacity: anim, child: child),
                              ),
                              child: Container(
                                key: ValueKey<String>(goodie.id),
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: rarityColor,
                                    width: goodie.isLegendary ? 4 : 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: rarityColor.withValues(
                                        alpha: goodie.isLegendary ? 0.6 : 0.3,
                                      ),
                                      blurRadius: goodie.isLegendary ? 24 : 14,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: img != null
                                      ? RawImage(image: img, fit: BoxFit.cover)
                                      : Center(
                                          child: Text(
                                            goodie.emoji,
                                            style: const TextStyle(fontSize: 72),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Right Button (>)
                      if (total > 1)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: _goToNext,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                                border: Border.all(color: Colors.white24, width: 1),
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Goodie Name & Sound Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          goodie.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (goodie.hasAudio) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _playCurrentAudio,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                              border: Border.all(
                                color: const Color(0xFF4CAF50),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.volume_up_rounded,
                              color: Color(0xFF81C784),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Rarity Badge Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: rarityColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: rarityColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      goodie.rarity.label.toUpperCase(),
                      style: TextStyle(
                        color: rarityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Dot indicators (when total <= 12)
                  if (total > 1 && total <= 12)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      children: List.generate(total, (i) {
                        final isActive = i == _currentIndex;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _currentIndex = i);
                            _playCurrentAudio();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isActive ? 16 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isActive ? rarityColor : Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),

                  const SizedBox(height: 12),

                  // Footer hint
                  const Text(
                    'Swipe or tap arrows to navigate • Tap to replay sound',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
