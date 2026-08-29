import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cauldron_goodie.dart';
import '../services/goodies_image_service.dart';
import '../widgets/polaroid_widget.dart';

/// Fullscreen celebration splash overlay displaying unlocked goodies
/// as a Picasa-style scattered Polaroid mosaic pile with cascade entrance.
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
  late final FocusNode _focusNode;
  late final AnimationController _cascadeController;
  final List<double> _rotations = [];
  final List<Offset> _translations = [];
  CauldronGoodie? _selectedGoodie;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Precalculate deterministic organic tilts and offsets for the mosaic
    final rand = Random(12345 + (widget.levelNumber ?? 1));
    for (int i = 0; i < widget.goodies.length; i++) {
      // Tilt between -25° and +25° (within ±30°)
      final deg = (rand.nextDouble() * 50.0 - 25.0);
      _rotations.add(deg * pi / 180.0);
      // Small organic shift
      final dx = (rand.nextDouble() * 16.0 - 8.0);
      final dy = (rand.nextDouble() * 16.0 - 8.0);
      _translations.add(Offset(dx, dy));
    }

    _cascadeController = AnimationController(
      duration: Duration(
        milliseconds: max(600, min(2000, 350 + widget.goodies.length * 150)),
      ),
      vsync: this,
    );

    _cascadeController.forward();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _cascadeController.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        widget.onNextLevel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {
          if (_selectedGoodie != null) {
            setState(() => _selectedGoodie = null);
          }
        },
        child: Material(
          color: Colors.black.withValues(alpha: 0.85),
          child: Stack(
            children: [
              // Subtle background gradient vignette
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Color(0xFF2D1B4E),
                        Color(0xFF0F0B1A),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content column
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildCelebrationHeader(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildMosaicArea(),
                    ),
                    const SizedBox(height: 12),
                    _buildBottomBar(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Zoomed goodie detail popup if tapped
              if (_selectedGoodie != null) _buildSelectedGoodieModal(),
            ],
          ),
        ),
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
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFDF00),
            letterSpacing: 2.0,
            shadows: [
              Shadow(
                color: Color(0xFFFFA000),
                blurRadius: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.moveCount != null
              ? 'Hai completato il livello in ${widget.moveCount} mosse! 🏆'
              : 'Hai sbloccato nuovi tesori per la tua collezione! 📸',
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildMosaicArea() {
    if (widget.goodies.isEmpty) {
      return const Center(
        child: Text(
          'Nessun badge da mostrare',
          style: TextStyle(color: Colors.white60, fontSize: 16),
        ),
      );
    }

    final count = widget.goodies.length;

    return AnimatedBuilder(
      animation: _cascadeController,
      builder: (context, child) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 20,
              runSpacing: 24,
              children: List.generate(count, (index) {
                final goodie = widget.goodies[index];
                final rot = _rotations.length > index ? _rotations[index] : 0.0;
                final trans = _translations.length > index
                    ? _translations[index]
                    : Offset.zero;

                // Staggered interval for drop-in cascade
                final start = (index / count) * 0.6;
                final end = min(1.0, start + 0.4);
                final itemProgress = CurvedAnimation(
                  parent: _cascadeController,
                  curve: Interval(start, end, curve: Curves.easeOutBack),
                ).value;

                final scale = (0.3 + itemProgress * 0.7).clamp(0.0, 1.0);
                final opacity = itemProgress.clamp(0.0, 1.0);

                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: trans * itemProgress,
                    child: Transform.scale(
                      scale: scale,
                      child: PolaroidWidget(
                        goodie: goodie,
                        rotationAngle: rot,
                        width: 140,
                        height: 180,
                        onTap: () {
                          setState(() {
                            _selectedGoodie = goodie;
                          });
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
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
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          ElevatedButton.icon(
            onPressed: widget.onNextLevel,
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black87),
            label: const Text(
              'Prossimo Livello ➡️ [Spazio]',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD54F),
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 16,
              ),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedGoodieModal() {
    final goodie = _selectedGoodie!;
    final cachedImg = GoodiesImageService.getImage(goodie.id);

    return GestureDetector(
      onTap: () => setState(() => _selectedGoodie = null),
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: GestureDetector(
          onTap: () {}, // Prevent click propagation
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PolaroidWidget(
                goodie: goodie,
                rotationAngle: 0.0,
                width: 240,
                height: 300,
                preloadedImage: cachedImg,
                elevation: 16,
              ),
              const SizedBox(height: 16),
              Text(
                '${goodie.emoji} ${goodie.displayName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: goodie.rarity.color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: goodie.rarity.color),
                ),
                child: Text(
                  goodie.rarity.label,
                  style: TextStyle(
                    color: goodie.rarity.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => setState(() => _selectedGoodie = null),
                icon: const Icon(Icons.close, color: Colors.white70),
                label: const Text(
                  'Chiudi',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
