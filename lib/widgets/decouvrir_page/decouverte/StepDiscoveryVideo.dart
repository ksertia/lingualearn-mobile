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
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _initVideo(widget.videoUrl);
  }

  // --- LOGIQUE DE FORMATAGE D'URL ---
  String _formatVideoUrl(String path,
      {bool forceHttps = false, bool forcePort4001 = false}) {
    final trimmed = path.trim();
    Uri uri;

    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      uri = Uri.parse(trimmed);
    } else {
      String base = "http://213.32.120.11:4000";
      if (forcePort4001) base = base.replaceAll(":4000", ":4001");
      uri = Uri.parse(base + (trimmed.startsWith("/") ? trimmed : "/$trimmed"));
    }

    if (kIsWeb) {
      final base = Uri.base;
      if (uri.host == base.host &&
          uri.port == base.port &&
          uri.scheme != base.scheme) {
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
    final fixedUrl = _formatVideoUrl(url);

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(fixedUrl));
      _controller!.addListener(_videoListener);
      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _hasError = false;
        _isLoaded = true;
        _dialogShown = false;
        _overlayOpacity = 0.0;
      });

      _controller!.play();
    } catch (e) {
      _handleError();
    }
  }

  void _handleError() {
    if (!_triedPortFallback) {
      _triedPortFallback = true;
      _initVideo(_formatVideoUrl(widget.videoUrl, forcePort4001: true));
      return;
    }
    if (!_triedHttpsFallback) {
      _triedHttpsFallback = true;
      _initVideo(_formatVideoUrl(widget.videoUrl, forceHttps: true));
      return;
    }
    setState(() => _hasError = true);
  }

  void _videoListener() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    if (c.value.position >= c.value.duration &&
        c.value.duration.inMilliseconds > 0) {
      if (!_dialogShown) {
        _dialogShown = true;
        c.pause();
        setState(() => _overlayOpacity = 1.0);
        _showVictoryDialog();
      }
    }
  }

  // --- LE POPUP SUPER LUDIQUE ---
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
                  gradient: LinearGradient(
                    colors: [Color(0xFF6750A4), Color(0xFF7F3DFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.22),
                      blurRadius: 24.r,
                      offset: Offset(0, 14.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Félicitations 🎉",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Tu as terminé cette étape !",
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
                        "Ton aventure continue, clique sur Continuer pour débloquer la suite.",
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
                              side: BorderSide(color: Colors.white54),
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
                              "Revoir",
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
                              "Continuer",
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
                      color: Color(0xFF7F3DFF), size: 40.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _replay() {
    if (_controller == null) return;
    setState(() {
      _dialogShown = false;
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
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15.h),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 16.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(child: _buildVideo()),
                  _buildOverlay(), // Le filtre qui s'active à la fin
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
          Text("Erreur vidéo", style: TextStyle(color: Colors.white)),
          SizedBox(height: 10.h),
          ElevatedButton(
              onPressed: () => _initVideo(widget.videoUrl),
              child: const Text("Réessayer")),
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
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildOverlay() {
    return IgnorePointer(
      // Laisse passer les clics vers le Dialog
      child: AnimatedOpacity(
        opacity: _overlayOpacity,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black
              .withOpacity(0.5), // Assombrit la vidéo derrière le popup
          alignment: Alignment.center,
          child: Icon(Icons.star,
              color: Colors.yellow.withOpacity(0.3), size: 150.sp),
        ),
      ),
    );
  }
}
