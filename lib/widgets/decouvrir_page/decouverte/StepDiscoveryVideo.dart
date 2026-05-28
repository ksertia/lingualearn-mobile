import 'dart:async';

// import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
  final Player _player = Player();
  late final VideoController _controller;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  bool _hasError = false;
  bool _isLoading = true;
  bool _dialogShown = false;
  bool _isReady = false;
  double _overlayOpacity = 0.0;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = VideoController(_player);
    _initializeFfmpeg();
    _initVideo(widget.videoUrl);
  }

  void _initializeFfmpeg() {
    try {
      // FFmpegKit.execute('-version').then((_) {}, onError: (_) {});
    } catch (_) {
      // Ignore initialization errors; this is only a warm-up path.
    }
  }

  String _formatVideoUrl(String path,
      {bool forceHttps = false, bool forcePort4001 = false}) {
    final trimmed = path.trim();
    Uri uri;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      uri = Uri.parse(trimmed);
    } else {
      String base = 'http://213.32.120.11:4000';
      if (forcePort4001) base = base.replaceAll(':4000', ':4001');
      uri = Uri.parse(base + (trimmed.startsWith('/') ? trimmed : '/$trimmed'));
    }

    final scheme = forceHttps ? 'https' : uri.scheme;
    int port = uri.port;
    if (forcePort4001) port = 4001;

    return Uri.encodeFull(uri.replace(scheme: scheme, port: port).toString());
  }

  Future<void> _initVideo(String url) async {
    _disposePlayer();
    setState(() {
      _hasError = false;
      _isLoading = true;
      _isReady = false;
      _dialogShown = false;
      _overlayOpacity = 0.0;
      _duration = Duration.zero;
    });

    final fixedUrl = _formatVideoUrl(url);

    try {
      await _player.open(Media(fixedUrl), play: false);
      _durationSubscription = _player.stream.duration.listen((duration) {
        if (duration != null && duration > Duration.zero) {
          setState(() {
            _duration = duration;
          });
        }
      });

      _positionSubscription = _player.stream.position.listen((position) {
        if (_duration > Duration.zero &&
            position >= _duration - const Duration(milliseconds: 200) &&
            !_dialogShown) {
          _dialogShown = true;
          _player.pause();
          setState(() {
            _overlayOpacity = 1.0;
          });
          _showVictoryDialog();
        }
      });

      await _player.play();
      setState(() {
        _hasError = false;
        _isLoading = false;
        _isReady = true;
      });
    } catch (_) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _retryVideo() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
      _overlayOpacity = 0.0;
      _dialogShown = false;
    });
    await _initVideo(widget.videoUrl);
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: 1.0),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: child,
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(24.w, 56.h, 24.w, 22.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6750A4), Color(0xFF7F3DFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withAlpha(56),
                      blurRadius: 24.r,
                      offset: Offset(0, 14.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Félicitations 🎉',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Tu as terminé cette étape !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events,
                            color: Colors.amberAccent, size: 28.sp),
                        SizedBox(width: 8.w),
                        Icon(Icons.auto_awesome,
                            color: Colors.lightGreenAccent, size: 28.sp),
                        SizedBox(width: 8.w),
                        Icon(Icons.star, color: Colors.pinkAccent, size: 28.sp),
                      ],
                    ),
                    SizedBox(height: 22.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Text(
                        'Ton aventure continue, clique sur Continuer pour débloquer la suite.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.92),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _replay();
                            },
                            child: Text(
                              'Revoir',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amberAccent.shade700,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onVideoFinished();
                            },
                            child: Text(
                              'Continuer',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -36.h,
              child: CircleAvatar(
                radius: 36.r,
                backgroundColor: Colors.white,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.7, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                  child: Icon(Icons.celebration,
                      color: const Color(0xFF7F3DFF), size: 40.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _replay() {
    if (_hasError) return;
    setState(() {
      _dialogShown = false;
      _overlayOpacity = 0.0;
    });
    _player.seek(Duration.zero);
    _player.play();
  }

  void _disposePlayer() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _player.pause();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _player.dispose();
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
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15.h),
        Expanded(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: _hasError
                  ? _buildErrorScreen()
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: Colors.black,
                          child: Video(
                            controller: _controller,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        else
                          _buildOverlay(),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorScreen() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 50.sp),
          const SizedBox(height: 10),
          const Text('Erreur vidéo', style: TextStyle(color: Colors.white)),
          SizedBox(height: 10.h),
          ElevatedButton(
            onPressed: _retryVideo,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _overlayOpacity,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          alignment: Alignment.center,
          child: Icon(Icons.star,
              color: Colors.yellow.withOpacity(0.3), size: 150.sp),
        ),
      ),
    );
  }
}