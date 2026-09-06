import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Animated background that starts with a static image and smoothly
/// transitions into a lively looping video animation after an initial delay.
class AnimatedBackground extends StatefulWidget {
  final bool isLandscape;
  final Duration initialDelay;
  final Duration fadeDuration;
  final VoidCallback? onAnimationStarted;

  const AnimatedBackground({
    super.key,
    required this.isLandscape,
    this.initialDelay = const Duration(seconds: 2),
    this.fadeDuration = const Duration(milliseconds: 600),
    this.onAnimationStarted,
  });

  @override
  State<AnimatedBackground> createState() => AnimatedBackgroundState();
}

class AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _delayTimer;
  bool _isVideoReady = false;
  bool _isStopped = false;
  String? _currentVideoAsset;

  /// Stops any pending timer, pauses video playback, and mutes video audio.
  void stop() {
    _isStopped = true;
    _delayTimer?.cancel();
    _delayTimer = null;
    if (_controller != null) {
      _controller!.pause();
      _controller!.setVolume(0.0);
    }
    if (mounted) setState(() {});
  }

  String get _imageAsset => widget.isLandscape
      ? 'assets/images/home_background_wide.jpg'
      : 'assets/images/home_background.jpg';

  String get _videoAsset => widget.isLandscape
      ? 'assets/videos/home_background_wide.mp4'
      : 'assets/videos/home_background_portrait.mp4';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _initVideo();
  }

  @override
  void didUpdateWidget(covariant AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLandscape != widget.isLandscape) {
      _cleanupCurrentVideo();
      _initVideo();
    }
  }

  void _cleanupCurrentVideo() {
    _delayTimer?.cancel();
    _delayTimer = null;
    _fadeController.reset();
    _isVideoReady = false;
    _controller?.dispose();
    _controller = null;
    _currentVideoAsset = null;
  }

  Future<void> _initVideo() async {
    if (_isStopped) return;
    final asset = _videoAsset;
    _currentVideoAsset = asset;

    try {
      final controller = VideoPlayerController.asset(asset);
      _controller = controller;

      await controller.initialize();
      if (!mounted || _currentVideoAsset != asset || _isStopped) {
        controller.dispose();
        return;
      }

      // Bugfix: Play video and audio once, freeze on final frame, never loop infinitely!
      await controller.setLooping(false);
      await controller.setVolume(1.0);

      controller.addListener(() {
        if (!mounted) return;
        final position = controller.value.position;
        final duration = controller.value.duration;

        // Smooth cross-fade transition back to the pristine original artwork in the last 1.2s
        if (duration > const Duration(seconds: 3) &&
            position >= duration - const Duration(milliseconds: 1200)) {
          if (_fadeController.status != AnimationStatus.reverse &&
              _fadeController.status != AnimationStatus.dismissed) {
            _fadeController.reverse();
          }
        }

        if (controller.value.isCompleted ||
            (duration > Duration.zero && position >= duration)) {
          controller.pause();
          if (_fadeController.status != AnimationStatus.dismissed &&
              _fadeController.status != AnimationStatus.reverse) {
            _fadeController.reverse();
          }
        }
        setState(() {});
      });

      setState(() {
        _isVideoReady = true;
      });

      // Schedule the animated entrance after initial delay (2 seconds)
      _delayTimer = Timer(widget.initialDelay, () async {
        if (!mounted || !_isVideoReady || _controller == null || _isStopped) return;
        try {
          await _controller!.setVolume(1.0);
          await _controller!.play();
        } catch (e) {
          // If browser blocks unmuted autoplay, mute and play visually
          if (kDebugMode) {
            print('Autoplay with sound restricted, falling back to muted: $e');
          }
          await _controller?.setVolume(0.0);
          await _controller?.play();
        }
        _fadeController.forward();
        widget.onAnimationStarted?.call();
      });
    } catch (e) {
      if (kDebugMode) {
        print('AnimatedBackground video not loaded for $asset: $e');
      }
    }
  }

  @override
  void dispose() {
    _cleanupCurrentVideo();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMuted = _controller == null || _controller!.value.volume == 0.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Base Static Image (always displayed immediately)
        Image.asset(
          _imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E2D2F), Color(0xFF0F171A)],
              ),
            ),
          ),
        ),

        // 2. Video Player with smooth FadeTransition
        if (_controller != null && _isVideoReady)
          FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width > 0
                      ? _controller!.value.size.width
                      : 1920,
                  height: _controller!.value.size.height > 0
                      ? _controller!.value.size.height
                      : 1080,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          ),

        // 3. Audio Toggle Indicator (Top-Left corner)
        if (_controller != null && _isVideoReady && !_isStopped)
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    if (_controller == null) return;
                    final isEnded = _controller!.value.isCompleted ||
                        (_controller!.value.duration > Duration.zero &&
                            _controller!.value.position >= _controller!.value.duration);

                    if (isEnded) {
                      // Replay from beginning with full sound and fade in
                      await _controller!.setVolume(1.0);
                      await _controller!.seekTo(Duration.zero);
                      await _controller!.play();
                      _fadeController.forward();
                    } else if (isMuted) {
                      // Unmute and ensure playing
                      await _controller!.setVolume(1.0);
                      if (!_controller!.value.isPlaying) {
                        await _controller!.play();
                        _fadeController.forward();
                      }
                    } else {
                      // Mute
                      await _controller!.setVolume(0.0);
                    }
                    if (mounted) setState(() {});
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Builder(builder: (context) {
                    final isEnded = _controller!.value.isCompleted ||
                        (_controller!.value.duration > Duration.zero &&
                            _controller!.value.position >= _controller!.value.duration);

                    final IconData icon;
                    final String label;
                    final Color color;

                    if (isEnded) {
                      icon = Icons.replay_rounded;
                      label = 'Replay Video 🔊';
                      color = const Color(0xFFFFD54F);
                    } else if (isMuted) {
                      icon = Icons.volume_off_rounded;
                      label = 'Muted 🔇 (Tap for Sound 🔊)';
                      color = const Color(0xFFFF9800);
                    } else {
                      icon = Icons.volume_up_rounded;
                      label = 'Sound On 🔊 (Tap to Mute)';
                      color = const Color(0xFFFFD54F);
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isMuted
                              ? const Color(0xFFFF9800)
                              : const Color(0xFFFFD54F),
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 16, color: color),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
