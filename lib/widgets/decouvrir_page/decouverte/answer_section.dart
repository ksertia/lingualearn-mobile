import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AnswerSection extends StatefulWidget {
  final String? answerType;
  final String? answerValue;

  const AnswerSection({super.key, this.answerType, this.answerValue});

  @override
  State<AnswerSection> createState() => _AnswerSectionState();
}

class _AnswerSectionState extends State<AnswerSection> {
  AudioPlayer? _player;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isCompleted = false;

  bool get _isAudio =>
      widget.answerType == 'audio' &&
      (widget.answerValue?.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    if (_isAudio) _initPlayer();
  }

  void _initPlayer() {
    _player = AudioPlayer();
    _player!.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _isPlaying = s == PlayerState.playing);
      if (s == PlayerState.completed) {
        setState(() {
          _isPlaying = false;
          _isCompleted = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_player == null) return;
    setState(() => _isLoading = true);
    try {
      if (_isPlaying) {
        await _player!.pause();
      } else {
        if (_isCompleted) {
          await _player!.seek(Duration.zero);
          _isCompleted = false;
        }
        await _player!.play(UrlSource(widget.answerValue!));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = widget.answerValue?.isNotEmpty ?? false;
    if (!hasContent) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8F0), Color(0xFFFFFBF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF8F00).withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8F00).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label centré avec séparateurs décoratifs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dividerLine(),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F00).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isAudio
                          ? Icons.volume_up_rounded
                          : Icons.translate_rounded,
                      size: 13,
                      color: const Color(0xFFFF8F00),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isAudio ? 'PRONONCIATION' : 'TRADUCTION',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF8F00),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _dividerLine(),
            ],
          ),

          const SizedBox(height: 16),

          if (_isAudio) _buildAudioContent() else _buildTextContent(),
        ],
      ),
    );
  }

  Widget _dividerLine() => Container(
        width: 32,
        height: 1.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFFFF8F00).withValues(alpha: 0.45),
            ],
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildTextContent() {
    return Text(
      widget.answerValue!,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A1A1A),
        height: 1.3,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildAudioContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _isLoading ? null : _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8F00), Color(0xFFFFB74D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8F00)
                      .withValues(alpha: _isPlaying ? 0.55 : 0.28),
                  blurRadius: _isPlaying ? 20 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(13),
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
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
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isPlaying ? 'Lecture en cours...' : 'Appuyer pour écouter',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color:
                    _isPlaying ? const Color(0xFFFF8F00) : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Prononciation audio',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }
}
