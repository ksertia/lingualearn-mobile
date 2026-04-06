import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class StepDiscoveryVideo extends StatefulWidget {
  final String videoTitle;
  final String videoUrl;
  final VoidCallback onVideoFinished;

  const StepDiscoveryVideo({
    super.key,
    required this.videoTitle,
    required this.videoUrl,
    required this.onVideoFinished,
  });

  @override
  State<StepDiscoveryVideo> createState() => _StepDiscoveryVideoState();
}

class _StepDiscoveryVideoState extends State<StepDiscoveryVideo> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasFinished = false;
  bool _hasError = false;
  double _overlayOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _hasError = false;
          });
          _controller.play();
        }
      }).catchError((error) {
        debugPrint("🚨 Erreur décodeur : $error");
        if (mounted) {
          setState(() {
            _hasError = true;
            _hasFinished = true;
            _overlayOpacity = 1.0;
          });
        }
      });

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (_isInitialized &&
        _controller.value.position >= _controller.value.duration &&
        !_hasFinished) {
      setState(() {
        _hasFinished = true;
      });
      _controller.pause();
      _animateOverlay(1.0);
    }
  }

  void _animateOverlay(double target) {
    setState(() {
      _overlayOpacity = target;
    });
  }

  void _replayVideo() {
    if (_hasError) {
      _initializePlayer();
    } else {
      setState(() {
        _hasFinished = false;
      });
      _controller.seekTo(Duration.zero);
      _controller.play();
      _animateOverlay(0.0);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Text(
          widget.videoTitle,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15.h),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
                    child: _isInitialized
                        ? SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              clipBehavior: Clip.hardEdge,
                              child: SizedBox(
                                width: _controller.value.size.width,
                                height: _controller.value.size.height,
                                child: VideoPlayer(_controller),
                              ),
                            ),
                          )
                        : _hasError
                            ? Icon(Icons.error_outline, color: Colors.white, size: 50.sp)
                            : const CircularProgressIndicator(color: Colors.white),
                  ),
                  if (_hasFinished)
                    AnimatedOpacity(
                      opacity: _overlayOpacity,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _replayVideo,
                              child: Container(
                                padding: EdgeInsets.all(20.w),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _hasError ? Icons.refresh : Icons.replay,
                                  size: 40.sp,
                                  color: const Color(0xFF000099),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              _hasError ? 'Erreur de lecture' : 'Revoir la vidéo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
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
        ),
      ],
    );
  }
}