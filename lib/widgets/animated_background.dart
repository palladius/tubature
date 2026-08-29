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

  const AnimatedBackground({
    super.key,
    required this.isLandscape,
    this.initialDelay = const Duration(milliseconds: 2500),
    this.fadeDuration = const Duration(milliseconds: 600),
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _delayTimer;
  bool _isVideoReady = false;
  String? _currentVideoAsset;

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
    final asset = _videoAsset;
    _currentVideoAsset = asset;

    try {
      final controller = VideoPlayerController.asset(asset);
      _controller = controller;

      await controller.initialize();
      if (!mounted || _currentVideoAsset != asset) {
        controller.dispose();
        return;
      }

      await controller.setLooping(true);
      await controller.setVolume(1.0); // Enable video audio track

      controller.addListener(() {
        if (mounted) setState(() {});
      });

      setState(() {
        _isVideoReady = true;
      });

      // Schedule the animated entrance after initial delay
      _delayTimer = Timer(widget.initialDelay, () async {
        if (!mounted || !_isVideoReady || _controller == null) return;
        try {
          await _controller!.play();
        } catch (e) {
          // If browser blocks unmuted autoplay, mute and play, then unmute on user interaction
          if (kDebugMode) {
            print('Autoplay with sound restricted, falling back to muted: $e');
          }
          await _controller?.setVolume(0.0);
          await _controller?.play();
        }
        _fadeController.forward();
      });
    } catch (e) {
      // Graceful fallback to static image if video is not available or fails
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
    final isMuted = _controller?.value.volume == 0.0;

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
        if (_controller != null && _isVideoReady)
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_controller == null) return;
                    final newVolume = isMuted ? 1.0 : 0.0;
                    _controller!.setVolume(newVolume);
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          size: 16,
                          color: isMuted ? Colors.white70 : const Color(0xFFFFD54F),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isMuted ? 'Muted (Tap to unmute)' : 'Sound On',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isMuted ? Colors.white70 : const Color(0xFFFFD54F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
