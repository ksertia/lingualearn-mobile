import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StepDiscoveryAudioPlayer extends StatefulWidget {
  final String title;
  final String audioUrl;
  final String answerText;

  const StepDiscoveryAudioPlayer({
    super.key,
    required this.title,
    required this.audioUrl,
    required this.answerText,
  });

  @override
  State<StepDiscoveryAudioPlayer> createState() =>
      _StepDiscoveryAudioPlayerState();
}

class _StepDiscoveryAudioPlayerState extends State<StepDiscoveryAudioPlayer>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  late final AnimationController _lottieController;
  late final AnimationController _barsController;

  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);
    _barsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      final playing = state == PlayerState.playing;
      setState(() => _isPlaying = playing);
      if (playing) {
        _lottieController.repeat();
        _barsController.repeat();
      } else {
        _lottieController.stop();
        _barsController.stop();
      }
      if (state == PlayerState.completed) {
        setState(() => _position = Duration.zero);
      }
    });

    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _lottieController.dispose();
    _barsController.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    setState(() => _isLoading = true);
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        if (_position >= _duration && _duration > Duration.zero) {
          await _player.seek(Duration.zero);
        }
        await _player.play(UrlSource(widget.audioUrl));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F00).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_pin,
                    size: 20, color: Color(0xFFFF8F00)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Mascotte + bulle audio en row
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Mascotte lottie animée quand l'audio joue
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Lottie.asset(
                    'assets/lottie/mascot.json',
                    controller: _lottieController,
                    onLoaded: (comp) {
                      _lottieController.duration = comp.duration;
                    },
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),

                // Bulle de dialogue avec contrôles audio
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Barres égaliseur animées
                            AnimatedBuilder(
                              animation: _barsController,
                              builder: (_, __) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: List.generate(5, (i) {
                                    final double phase = i * 0.55;
                                    final double t = _barsController.value;
                                    final double h = _isPlaying
                                        ? 8 +
                                            22 *
                                                ((sin(t * 2 * pi + phase) +
                                                        1) /
                                                    2)
                                        : 8;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 3),
                                      child: Container(
                                        width: 5,
                                        height: h,
                                        decoration: BoxDecoration(
                                          color: _isPlaying
                                              ? const Color(0xFFFF8F00)
                                              : Colors.grey[350],
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            // Bouton play/pause
                            GestureDetector(
                              onTap: _isLoading ? null : _togglePlay,
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFF8F00),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF8F00)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _isLoading
                                    ? const Padding(
                                        padding: EdgeInsets.all(13),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Icon(
                                        _isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Pointe de la bulle (gauche)
                      Positioned(
                        left: -6.5,
                        top: 36,
                        child: RotationTransition(
                          turns: const AlwaysStoppedAnimation(-45 / 360),
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                left:
                                    BorderSide(color: Colors.grey, width: 1.5),
                                top:
                                    BorderSide(color: Colors.grey, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 33,
                        child: Container(
                            width: 5, height: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Séparateur
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withValues(alpha: 0.5),
                  Colors.grey,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Traduction
          Expanded(
            flex: 1,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          "TRADUCTION",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          widget.answerText,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
