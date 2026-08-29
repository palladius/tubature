import 'dart:math';
import 'package:flutter/material.dart';
import '../models/cauldron_goodie.dart';
import '../widgets/polaroid_widget.dart';

/// Fullscreen celebration splash overlay displaying discovered goodies
/// as a large, overlapping Picasa-style scattered Polaroid pile.
///
/// Features:
/// - Large Polaroid photos covering 70-80% of the screen.
/// - Overlapping stack with subtle random tilt (±15°–20°) and organic offsets.
/// - Cascade entrance animation slamming/dropping photos onto the pile.
/// - Interactive flick/tap on top photo to cycle through the pile.
/// - Requires explicit click on "Prossimo Livello ➡️" to prevent accidental skips.
class PolaroidMosaicOverlay extends StatefulWidget {
  final List<CauldronGoodie> goodies;
  final VoidCallback onNextLevel;
  final VoidCallback? onPlayAgain;
  final int? moveCount;
  final int? levelNumber;

  const PolaroidMosaicOverlay({
    super.key,
    required this.goodies,
    required this.onNextLevel,
    this.onPlayAgain,
    this.moveCount,
    this.levelNumber,
  });

  @override
  State<PolaroidMosaicOverlay> createState() => _PolaroidMosaicOverlayState();
}

class _PolaroidMosaicOverlayState extends State<PolaroidMosaicOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cascadeController;
  final List<double> _rotations = [];
  final List<Offset> _translations = [];

  // Track order of cards in the deck so user can tap top card to send to back
  late List<int> _deckOrder;

  @override
  void initState() {
    super.initState();

    final count = widget.goodies.length;
    _deckOrder = List.generate(count, (i) => i);

    // Precalculate deterministic organic tilts (±15°..20°) and slight offsets
    final rand = Random(42 + (widget.levelNumber ?? 1));
    for (int i = 0; i < count; i++) {
      // Tilt between -18° and +18° (~20% max tilt)
      final deg = (rand.nextDouble() * 32.0 - 16.0);
      _rotations.add(deg * pi / 180.0);
      // Small scatter offset in px
      final dx = (rand.nextDouble() * 30.0 - 15.0);
      final dy = (rand.nextDouble() * 24.0 - 12.0);
      _translations.add(Offset(dx, dy));
    }

    _cascadeController = AnimationController(
      duration: Duration(
        milliseconds: max(2000, count * 2000),
      ),
      vsync: this,
    );

    _cascadeController.forward();
  }

  @override
  void dispose() {
    _cascadeController.dispose();
    super.dispose();
  }

  /// Tap on top card sends it to the bottom of the deck so you can admire the next one!
  void _cycleTopCard() {
    if (_deckOrder.length <= 1) return;
    setState(() {
      final top = _deckOrder.removeLast();
      _deckOrder.insert(0, top);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.88),
      child: Stack(
        children: [
          // Background vignette with celebratory glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF3B1E54),
                    Color(0xFF10091D),
                  ],
                ),
              ),
            ),
          ),

          // Main column
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildCelebrationHeader(),
                const SizedBox(height: 8),
                if (widget.goodies.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Tocca la foto per sfogliare la collezione (${widget.goodies.length} foto) 📸👆',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return _buildOverlappingPile(constraints);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _buildBottomBar(),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '✨ MAGNIFICO! ✨',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFDF00),
            letterSpacing: 2.0,
            shadows: [
              Shadow(
                color: Color(0xFFFFA000),
                blurRadius: 18,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.moveCount != null
              ? 'Hai completato il livello in ${widget.moveCount} mosse! 🏆'
              : 'Ecco i tesori scoperti! 📸',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildOverlappingPile(BoxConstraints constraints) {
    if (widget.goodies.isEmpty) {
      return const Center(
        child: Text(
          'Nessun tesoro da mostrare',
          style: TextStyle(color: Colors.white60, fontSize: 16),
        ),
      );
    }

    final count = widget.goodies.length;

    // Card size: covers ~75-80% of available viewport
    final cardWidth = (constraints.maxWidth * 0.78).clamp(240.0, 440.0);
    final cardHeight = (constraints.maxHeight * 0.82).clamp(300.0, cardWidth * 1.28);

    return Center(
      child: SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: AnimatedBuilder(
          animation: _cascadeController,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: _deckOrder.asMap().entries.map((entry) {
                final stackIndex = entry.key; // 0 is bottom, last is top
                final goodieIndex = entry.value;
                final isTop = stackIndex == _deckOrder.length - 1;

                final goodie = widget.goodies[goodieIndex];
                final rot = _rotations.length > goodieIndex
                    ? _rotations[goodieIndex]
                    : 0.0;
                final trans = _translations.length > goodieIndex
                    ? _translations[goodieIndex]
                    : Offset.zero;

                // Each card drops every 2.0s with an 800ms landing animation
                final totalMs = max(2000.0, count * 2000.0);
                final start = (goodieIndex * 2000.0) / totalMs;
                final end = min(1.0, (goodieIndex * 2000.0 + 850.0) / totalMs);

                // If not yet time for this card to start dropping, keep it hidden
                final progress = _cascadeController.value;
                if (progress < start) {
                  return const SizedBox.shrink();
                }

                final dropProgress = CurvedAnimation(
                  parent: _cascadeController,
                  curve: Interval(start, end, curve: Curves.easeOutBack),
                ).value;

                final scale = (0.4 + dropProgress * 0.6).clamp(0.0, 1.0);
                final opacity = dropProgress.clamp(0.0, 1.0);
                final dropOffset = Offset(
                  trans.dx,
                  trans.dy + (1.0 - dropProgress) * -120.0, // Drops from top!
                );

                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: dropOffset,
                    child: Transform.scale(
                      scale: scale,
                      child: PolaroidWidget(
                        goodie: goodie,
                        rotationAngle: rot,
                        width: cardWidth,
                        height: cardHeight,
                        elevation: 10.0 + stackIndex * 3.0,
                        onTap: isTop ? _cycleTopCard : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.onPlayAgain != null) ...[
            OutlinedButton.icon(
              onPressed: widget.onPlayAgain,
              icon: const Icon(Icons.refresh, color: Colors.white70),
              label: const Text(
                'Rigioca',
                style: TextStyle(color: Colors.white70),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white30),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          ElevatedButton.icon(
            onPressed: widget.onNextLevel,
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black87, size: 24),
            label: const Text(
              'Prossimo Livello ➡️',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD54F),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 18,
              ),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
