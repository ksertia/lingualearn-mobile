import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class StepDiscoveryVideo extends StatefulWidget {
  final String videoTitle;
  final String videoUrl;
  final VoidCallback onVideoFinished;
  final bool showTitle;

  const StepDiscoveryVideo({
    super.key,
    required this.videoTitle,
    required this.videoUrl,
    required this.onVideoFinished,
    this.showTitle = true,
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
        insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                padding: const EdgeInsets.fromLTRB(24, 44, 24, 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                      color: const Color(0xFFF27F22).withValues(alpha: 0.15),
                      width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: Offset(0, 14),
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
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Tu as terminé cette étape !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _rewardBadge(Icons.emoji_events, Colors.amber),
                        SizedBox(width: 10),
                        _rewardBadge(Icons.auto_awesome, Colors.green),
                        SizedBox(width: 10),
                        _rewardBadge(Icons.star_rounded, Colors.pinkAccent),
                      ],
                    ),
                    SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF27F22).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'Ton aventure continue, clique sur Continuer pour débloquer la suite.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF8A4A38),
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _replay();
                            },
                            child: Text(
                              'Revoir',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFF27F22),
                                  Color(0xFFF27F22)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF27F22)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onVideoFinished();
                                },
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    'Continuer',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
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
              top: -36,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.7, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, scale, child) => Transform.scale(
                  scale: scale,
                  child: child,
                ),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF27F22), Color(0xFFF27F22)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF27F22).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(Icons.celebration,
                      color: Colors.white, size: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rewardBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
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
        if (widget.showTitle) ...[
          SizedBox(height: 10),
          Text(
            widget.videoTitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
        ],
        Expanded(
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
      ],
    );
  }

  Widget _buildErrorScreen() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.white, size: 50),
          const SizedBox(height: 10),
          const Text('Erreur vidéo', style: TextStyle(color: Colors.white)),
          SizedBox(height: 10),
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
              color: Color(0xFFF27F22), size: 150),
        ),
      ),
    );
  }
}