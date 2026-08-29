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
      await controller.setVolume(0.0); // Mute video so game audio shines

      controller.addListener(() {
        if (mounted) setState(() {});
      });

      setState(() {
        _isVideoReady = true;
      });

      // Schedule the animated entrance after initial delay
      _delayTimer = Timer(widget.initialDelay, () {
        if (!mounted || !_isVideoReady || _controller == null) return;
        _controller!.play();
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
      ],
    );
  }
}
