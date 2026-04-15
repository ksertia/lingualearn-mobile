import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
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
  VideoPlayerController? _controller;

  bool _hasError = false;
  bool _isLoaded = false;

  bool _triedHttpsFallback = false;
  bool _triedPortFallback = false;

  double _overlayOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _initVideo(widget.videoUrl);
  }

  // 🔥 SAME LOGIC AS IMAGE
  String _formatVideoUrl(String path,
      {bool forceHttps = false, bool forcePort4001 = false}) {
    final trimmed = path.trim();

    Uri uri;

    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      uri = Uri.parse(trimmed);
    } else {
      String base = "http://213.32.120.11:4000";

      if (forcePort4001) {
        base = base.replaceAll(":4000", ":4001");
      }

      uri = Uri.parse(
        base + (trimmed.startsWith("/") ? trimmed : "/$trimmed"),
      );
    }

    if (kIsWeb) {
      final base = Uri.base;
      if (uri.host == base.host &&
          uri.port == base.port &&
          uri.scheme != base.scheme) {
        debugPrint(
          '🎬 VIDEO SCHEME NORMALIZED: ${uri.toString()} -> ${uri.replace(scheme: base.scheme)}',
        );
        uri = uri.replace(scheme: base.scheme);
      }
    }

    final scheme = forceHttps ? "https" : uri.scheme;

    int port = uri.port;
    if (forcePort4001) port = 4001;

    return Uri.encodeFull(uri.replace(scheme: scheme, port: port).toString());
  }

  void _initVideo(String url) async {
    _dispose();

    final fixedUrl = _formatVideoUrl(
      url,
      forceHttps: false,
      forcePort4001: false,
    );

    debugPrint("🎬 VIDEO LOAD: $fixedUrl");

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(fixedUrl));

      _controller!.addListener(_videoListener);

      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _hasError = false;
        _isLoaded = true;
      });

      _controller!.play();
    } catch (e) {
      debugPrint("🚨 VIDEO ERROR: $e");
      _handleError();
    }
  }

  // 🔥 SAME FALLBACK SYSTEM AS IMAGE
  void _handleError() {
    if (!_triedPortFallback) {
      _triedPortFallback = true;

      final fallback = _formatVideoUrl(
        widget.videoUrl,
        forcePort4001: true,
      );

      _initVideo(fallback);
      return;
    }

    if (!_triedHttpsFallback) {
      _triedHttpsFallback = true;

      final fallback = _formatVideoUrl(
        widget.videoUrl,
        forceHttps: true,
      );

      _initVideo(fallback);
      return;
    }

    setState(() {
      _hasError = true;
    });
  }

  void _videoListener() {
    final c = _controller;

    if (c == null || !c.value.isInitialized) return;

    if (c.value.position >= c.value.duration &&
        c.value.duration.inMilliseconds > 0) {
      c.pause();

      setState(() {
        _overlayOpacity = 1.0;
      });

      widget.onVideoFinished();
    }
  }

  void _replay() {
    if (_controller == null) return;

    setState(() {
      _overlayOpacity = 0.0;
    });

    _controller!.seekTo(Duration.zero);
    _controller!.play();
  }

  void _dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Text(
          widget.videoTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15.h),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Center(child: _buildVideo()),
                  if (_overlayOpacity > 0) _buildOverlay(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideo() {
    final c = _controller;

    if (_hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 50.sp),
          SizedBox(height: 10.h),
          Text(
            "Erreur vidéo",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 15.h),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _triedHttpsFallback = false;
                _triedPortFallback = false;
              });
              _initVideo(widget.videoUrl);
            },
            child: const Text("Réessayer"),
          ),
        ],
      );
    }

    if (c != null && c.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: c.value.size.width,
            height: c.value.size.height,
            child: VideoPlayer(c),
          ),
        ),
      );
    }

    return const CircularProgressIndicator(color: Colors.white);
  }

  Widget _buildOverlay() {
    return AnimatedOpacity(
      opacity: _overlayOpacity,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: _replay,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.replay,
                  size: 40.sp,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10.h),
              const Text(
                "Revoir la vidéo",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
