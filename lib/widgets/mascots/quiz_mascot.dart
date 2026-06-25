import 'package:flutter/material.dart';
import 'package:tibi/widgets/mascots/kadoua_mascot.dart';
import 'package:tibi/widgets/mascots/audio_mascots.dart';
import 'package:tibi/widgets/mascots/zaki_mascot.dart';

// Humeur unifiée pour les quiz
enum QuizMascotMood { speaking, correct, incorrect }

// Sélecteur de mascotte : questionIndex % 4 → 0=Kadoua, 1=Awa, 2=Tiga, 3=Zaki
class QuizMascotSelector extends StatelessWidget {
  final int questionIndex;
  final QuizMascotMood mood;
  final double size;

  const QuizMascotSelector({
    super.key,
    required this.questionIndex,
    this.mood = QuizMascotMood.speaking,
    this.size = 100,
  });

  AudioMascotMood _toAudioMood() {
    switch (mood) {
      case QuizMascotMood.speaking:
        return AudioMascotMood.speaking;
      case QuizMascotMood.correct:
        return AudioMascotMood.happy;
      case QuizMascotMood.incorrect:
        return AudioMascotMood.sad;
    }
  }

  KadouaMood _toKadouaMood() {
    switch (mood) {
      case QuizMascotMood.speaking:
        return KadouaMood.speaking;
      case QuizMascotMood.correct:
        return KadouaMood.correct;
      case QuizMascotMood.incorrect:
        return KadouaMood.incorrect;
    }
  }

  ZakiMood _toZakiMood() {
    switch (mood) {
      case QuizMascotMood.speaking:
        return ZakiMood.happy;
      case QuizMascotMood.correct:
        return ZakiMood.celebrating;
      case QuizMascotMood.incorrect:
        return ZakiMood.sad;
    }
  }

  AudioMascotSize _audioSize() {
    if (size <= 72) return AudioMascotSize.sm;
    if (size <= 100) return AudioMascotSize.md;
    if (size <= 130) return AudioMascotSize.lg;
    return AudioMascotSize.xl;
  }

  KadouaSize _kadouaSize() {
    if (size <= 72) return KadouaSize.sm;
    if (size <= 100) return KadouaSize.md;
    if (size <= 130) return KadouaSize.lg;
    return KadouaSize.xl;
  }

  ZakiSize _zakiSize() {
    if (size <= 64) return ZakiSize.sm;
    if (size <= 88) return ZakiSize.md;
    if (size <= 120) return ZakiSize.lg;
    return ZakiSize.xl;
  }

  @override
  Widget build(BuildContext context) {
    final idx = questionIndex % 4;
    Widget mascot;
    switch (idx) {
      case 0:
        mascot = KadouaMascot(
          key: const ValueKey('kadoua'),
          mood: _toKadouaMood(),
          size: _kadouaSize(),
        );
        break;
      case 1:
        mascot = AwaMascot(
          key: const ValueKey('awa'),
          mood: _toAudioMood(),
          size: _audioSize(),
        );
        break;
      case 2:
        mascot = TigaMascot(
          key: const ValueKey('tiga'),
          mood: _toAudioMood(),
          size: _audioSize(),
        );
        break;
      default:
        mascot = ZakiMascot(
          key: const ValueKey('zaki'),
          mood: _toZakiMood(),
          size: _zakiSize(),
        );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: anim, child: child),
      ),
      child: mascot,
    );
  }
}
