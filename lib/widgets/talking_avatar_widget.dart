import 'dart:async';
import 'package:flutter/material.dart';
import '../models/voice_entry.dart';
import '../services/audio_service.dart';
import 'ermete_painter.dart';

/// Floating picture-in-picture widget featuring Ermete (The Ferrarese Plumber)
/// speaking authentic voice lines with animated mouth flapping and comic speech bubbles.
class TalkingAvatarWidget extends StatefulWidget {
  final VoidCallback? onDismissed;

  const TalkingAvatarWidget({super.key, this.onDismissed});

  @override
  State<TalkingAvatarWidget> createState() => _TalkingAvatarWidgetState();
}

class _TalkingAvatarWidgetState extends State<TalkingAvatarWidget> with TickerProviderStateMixin {
  VoiceEntry? _currentVoice;
  bool _isVisible = false;
  Timer? _speechTimer;
  Timer? _dismissTimer;

  // Mouth Flap Controller (cycles 0.0 -> 1.0 -> 0.0 during speech)
  late AnimationController _mouthController;
  late Animation<double> _mouthAnimation;

  // Eye Blink Controller
  late AnimationController _blinkController;

  // Slide & Scale Transition Controller
  late AnimationController _entranceController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _mouthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _mouthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mouthController, curve: Curves.easeInOut),
    );

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
    _scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    // Wire global AudioService voice listener
    AudioService.onVoiceStarted = _handleVoiceStarted;
  }

  void _handleVoiceStarted(VoiceEntry voice) {
    if (!mounted) return;

    _speechTimer?.cancel();
    _dismissTimer?.cancel();
    setState(() {
      _currentVoice = voice;
      _isVisible = true;
    });

    _entranceController.forward(from: 0.0);
    _mouthController.repeat(reverse: true);

    // Estimate voice duration based on line (~2.2s - 3.2s)
    final durationMs = voice.id == 'majjal-ac-du-bal' ? 2800 : 2400;

    // Stop mouth flapping when speech finishes
    _speechTimer = Timer(Duration(milliseconds: durationMs), () {
      if (mounted) {
        _mouthController.stop();
        _mouthController.reset();
      }
    });

    // Dismiss avatar overlay shortly after speech
    _dismissTimer = Timer(Duration(milliseconds: durationMs + 1200), () {
      if (mounted) {
        _entranceController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _isVisible = false;
            });
            widget.onDismissed?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _speechTimer?.cancel();
    _dismissTimer?.cancel();
    _mouthController.dispose();
    _blinkController.dispose();
    _entranceController.dispose();
    if (AudioService.onVoiceStarted == _handleVoiceStarted) {
      AudioService.onVoiceStarted = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _currentVoice == null) return const SizedBox.shrink();

    final voice = _currentVoice!;

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.bottomRight,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 80, right: 16, left: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: voice.isEasterEgg
                ? const Color(0xFFFFD700)
                : (voice.isGood ? const Color(0xFF4ADE80) : const Color(0xFFF87171)),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Ermete Animated Avatar Head
            AnimatedBuilder(
              animation: Listenable.merge([_mouthAnimation, _blinkController]),
              builder: (context, _) {
                final blinkVal = (_blinkController.value > 0.92) ? 1.0 : 0.0;
                return SizedBox(
                  width: 64,
                  height: 64,
                  child: CustomPaint(
                    painter: ErmetePainter(
                      mouthOpenProgress: _mouthAnimation.value,
                      blinkProgress: blinkVal,
                      isHappy: voice.isGood,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),

            // 2. Comic Speech Bubble Content
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Speaker tag
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        voice.isEasterEgg ? '🥚 ERMETE (EASTER EGG)' : '🔧 ERMETE DA FERRARA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: voice.isEasterEgg ? const Color(0xFFFFD700) : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.volume_up_rounded, size: 13, color: Color(0xFF38BDF8)),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Dialect line (large & bold)
                  Text(
                    '« ${voice.displayName} »',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'sans-serif',
                    ),
                  ),

                  // Italian subtitle
                  Text(
                    voice.meaningIt,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
