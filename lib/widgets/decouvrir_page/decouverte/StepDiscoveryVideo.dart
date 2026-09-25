import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

const Color _kOrange = Color(0xFFF27F22);

enum _DownloadState { none, downloading, downloaded, error }

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
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<bool>? _bufferingSubscription;
  Timer? _hideControlsTimer;

  bool _hasError = false;
  bool _isLoading = true;
  bool _isBuffering = false;
  bool _dialogShown = false;
  bool _isPlaying = false;
  bool _controlsVisible = true;
  double _overlayOpacity = 0.0;
  Duration _duration = Duration.zero;
  late String _fixedUrl;

  _DownloadState _downloadState = _DownloadState.none;
  double _downloadProgress = 0;
  String? _downloadedPath;
  CancelToken? _downloadCancelToken;

  @override
  void initState() {
    super.initState();
    _controller = VideoController(_player);
    _fixedUrl = _formatVideoUrl(widget.videoUrl);
    _initVideo(widget.videoUrl);
    _checkIfDownloaded();
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
    _disposeStreams();
    setState(() {
      _hasError = false;
      _isLoading = true;
      _dialogShown = false;
      _overlayOpacity = 0.0;
      _duration = Duration.zero;
    });

    _fixedUrl = _formatVideoUrl(url);

    try {
      await _player.open(Media(_fixedUrl), play: false);

      _durationSubscription = _player.stream.duration.listen((duration) {
        if (duration > Duration.zero && mounted) {
          setState(() => _duration = duration);
        }
      });

      _positionSubscription = _player.stream.position.listen((position) {
        if (!mounted) return;
        if (_duration > Duration.zero &&
            position >= _duration - const Duration(milliseconds: 200) &&
            !_dialogShown) {
          _dialogShown = true;
          _player.pause();
          setState(() => _overlayOpacity = 1.0);
          _showVictoryDialog();
        }
      });

      _playingSubscription = _player.stream.playing.listen((playing) {
        if (!mounted) return;
        setState(() => _isPlaying = playing);
        if (playing) _scheduleHideControls();
      });

      _bufferingSubscription = _player.stream.buffering.listen((buffering) {
        if (mounted) setState(() => _isBuffering = buffering);
      });

      await _player.play();
      if (!mounted) return;
      setState(() {
        _hasError = false;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
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

  // ── Contrôles de lecture ─────────────────────────────────────────────────

  void _togglePlayPause() {
    if (_isPlaying) {
      _player.pause();
      _hideControlsTimer?.cancel();
      setState(() => _controlsVisible = true);
    } else {
      _player.play();
    }
  }

  void _toggleControlsVisibility() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible && _isPlaying) _scheduleHideControls();
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) setState(() => _controlsVisible = false);
    });
  }

  // ── Téléchargement ───────────────────────────────────────────────────────

  String _sanitizedFileName() {
    final base = widget.videoTitle.trim().isNotEmpty
        ? widget.videoTitle.trim()
        : 'video';
    final safe = base
        .replaceAll(RegExp(r'[^\w\séèêàâîïôöùûüç-]', unicode: true), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    final ext = _guessExtension();
    return '${safe}_${_fixedUrl.hashCode.toRadixString(16)}$ext';
  }

  String _guessExtension() {
    final path = Uri.tryParse(_fixedUrl)?.path ?? '';
    final dot = path.lastIndexOf('.');
    if (dot != -1 && path.length - dot <= 5) {
      return path.substring(dot);
    }
    return '.mp4';
  }

  Future<String> _localVideoPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final videosDir = Directory('${dir.path}/videos');
    if (!await videosDir.exists()) {
      await videosDir.create(recursive: true);
    }
    return '${videosDir.path}/${_sanitizedFileName()}';
  }

  Future<void> _checkIfDownloaded() async {
    try {
      final path = await _localVideoPath();
      if (await File(path).exists()) {
        if (!mounted) return;
        setState(() {
          _downloadState = _DownloadState.downloaded;
          _downloadedPath = path;
        });
      }
    } catch (_) {
      // Ignore : on retombera simplement sur l'état "non téléchargée".
    }
  }

  Future<void> _handleDownloadTap() async {
    if (_downloadState == _DownloadState.downloaded && _downloadedPath != null) {
      Share.shareXFiles([XFile(_downloadedPath!)], text: widget.videoTitle);
      return;
    }
    if (_downloadState == _DownloadState.downloading) return;
    await _downloadVideo();
  }

  Future<void> _downloadVideo() async {
    setState(() {
      _downloadState = _DownloadState.downloading;
      _downloadProgress = 0;
    });
    _downloadCancelToken = CancelToken();
    try {
      final savePath = await _localVideoPath();
      await Dio().download(
        _fixedUrl,
        savePath,
        cancelToken: _downloadCancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );
      if (!mounted) return;
      setState(() {
        _downloadState = _DownloadState.downloaded;
        _downloadedPath = savePath;
      });
      Get.snackbar(
        'Téléchargée',
        'La vidéo est disponible hors-ligne.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF3C7D00),
        colorText: Colors.white,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _downloadState = _DownloadState.error);
      Get.snackbar(
        'Oups',
        'Le téléchargement de la vidéo a échoué.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ── Victoire / relecture ─────────────────────────────────────────────────

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
                      color: _kOrange.withValues(alpha: 0.15), width: 1.5),
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
                        color: _kOrange.withValues(alpha: 0.08),
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
                                colors: [_kOrange, _kOrange],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: _kOrange.withValues(alpha: 0.35),
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
                      colors: [_kOrange, _kOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: _kOrange.withValues(alpha: 0.35),
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

  void _disposeStreams() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playingSubscription?.cancel();
    _bufferingSubscription?.cancel();
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _downloadCancelToken?.cancel();
    _disposeStreams();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: _hasError
          ? _buildErrorScreen()
          : Stack(
              fit: StackFit.expand,
              children: [
                Video(controller: _controller, fit: BoxFit.cover),
                if (!_isLoading)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleControlsVisibility,
                    child: AnimatedOpacity(
                      opacity: _controlsVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: IgnorePointer(
                        ignoring: !_controlsVisible,
                        child: _buildControlsLayer(),
                      ),
                    ),
                  ),
                if (_isLoading || _isBuffering) _buildLoadingLayer(),
                _buildVictoryStarOverlay(),
              ],
            ),
    );
  }

  // ── Couches d'UI ─────────────────────────────────────────────────────────

  Widget _buildControlsLayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Bouton téléchargement, flottant en haut à droite.
        Positioned(
          top: 12,
          right: 12,
          child: _buildDownloadButton(),
        ),

        // Bouton lecture/pause central.
        Center(
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.38),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5), width: 1.4),
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return GestureDetector(
      onTap: _handleDownloadTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.40),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: _downloadState == _DownloadState.downloading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  value: _downloadProgress > 0 ? _downloadProgress : null,
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                _downloadState == _DownloadState.downloaded
                    ? Icons.download_done_rounded
                    : Icons.download_rounded,
                color: Colors.white,
                size: 18,
              ),
      ),
    );
  }

  Widget _buildLoadingLayer() {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _kOrange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: _kOrange,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _isLoading ? 'Chargement de la vidéo…' : 'Mise en mémoire tampon…',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictoryStarOverlay() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _overlayOpacity,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          alignment: Alignment.center,
          child: const Icon(Icons.star, color: _kOrange, size: 150),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Container(
      color: const Color(0xFF1A1A1A),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _kOrange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.videocam_off_rounded,
                color: _kOrange, size: 34),
          ),
          const SizedBox(height: 14),
          const Text('Impossible de lire la vidéo',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _retryVideo,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
