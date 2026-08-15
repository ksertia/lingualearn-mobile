import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Sons UI générés en mémoire — aucun fichier asset requis.
class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _bgPlayer = AudioPlayer();

  static const int _sampleRate = 44100;

  /// Tick léger à la sélection d'une option
  static Future<void> playSelect() => _play(_buildTone(
        frequency: 800,
        durationMs: 55,
        volume: 0.35,
      ));

  /// Ding montant sur bonne réponse
  static Future<void> playCorrect() => _play(_buildChirp(
        freqStart: 880,
        freqEnd: 1320,
        durationMs: 180,
        volume: 0.5,
      ));

  /// Bwomp descendant sur mauvaise réponse
  static Future<void> playWrong() => _play(_buildChirp(
        freqStart: 380,
        freqEnd: 180,
        durationMs: 200,
        volume: 0.5,
      ));

  /// Son de célébration depuis le fichier asset
  static Future<void> playCelebration() async {
    await _player.stop();
    if (kIsWeb) {
      // Sur web Flutter, les assets sont servis à la racine sous /assets/
      await _player.play(UrlSource('assets/sound/succes.mp3'), volume: 0.8);
    } else {
      await _player.play(AssetSource('sound/succes.mp3'), volume: 0.8);
    }
  }

  /// Musique de fond, jouée une seule fois (lecteur dédié, indépendant des effets sonores)
  static Future<void> playBackgroundLoop() async {
    await _bgPlayer.setReleaseMode(ReleaseMode.release);
    if (kIsWeb) {
      await _bgPlayer.play(UrlSource('assets/sound/succes.mp3'), volume: 0.4);
    } else {
      await _bgPlayer.play(AssetSource('sound/succes.mp3'), volume: 0.4);
    }
  }

  static Future<void> stopBackgroundLoop() => _bgPlayer.stop();

  // ── Lecteur ──────────────────────────────────────────────────────────────

  static Future<void> _play(Uint8List wav) async {
    await _player.stop();
    if (kIsWeb) {
      // BytesSource non supporté sur web → data URL base64
      final dataUrl = 'data:audio/wav;base64,${base64Encode(wav)}';
      await _player.play(UrlSource(dataUrl));
    } else {
      await _player.play(BytesSource(wav));
    }
  }

  // ── Générateurs WAV ───────────────────────────────────────────────────────

  /// Tonalité simple à fréquence fixe
  static Uint8List _buildTone({
    required double frequency,
    required int durationMs,
    double volume = 0.5,
  }) {
    final samples = _samplesFor(durationMs);
    final pcm = Int16List(samples);

    for (int i = 0; i < samples; i++) {
      final t = i / _sampleRate;
      final env = _envelope(t, durationMs / 1000.0);
      pcm[i] = (volume * env * sin(2 * pi * frequency * t) * 32767).round().clamp(-32768, 32767);
    }

    return _wavHeader(samples)..buffer.asInt16List(44).setAll(0, pcm);
  }

  /// Tonalité glissante (chirp) de freqStart vers freqEnd
  static Uint8List _buildChirp({
    required double freqStart,
    required double freqEnd,
    required int durationMs,
    double volume = 0.5,
  }) {
    final samples = _samplesFor(durationMs);
    final pcm = Int16List(samples);
    final D = durationMs / 1000.0;

    for (int i = 0; i < samples; i++) {
      final t = i / _sampleRate;
      // Phase intégrée pour un glissement de fréquence propre
      final phase = 2 * pi * (freqStart * t + (freqEnd - freqStart) * t * t / (2 * D));
      final env = _envelope(t, D);
      pcm[i] = (volume * env * sin(phase) * 32767).round().clamp(-32768, 32767);
    }

    return _wavHeader(samples)..buffer.asInt16List(44).setAll(0, pcm);
  }

  // ── Helpers internes ──────────────────────────────────────────────────────

  static int _samplesFor(int durationMs) => (_sampleRate * durationMs / 1000).round();

  /// Enveloppe attack/decay pour éviter les clics
  static double _envelope(double t, double duration) {
    const attack = 0.008;
    const decay  = 0.03;
    if (t < attack) return t / attack;
    if (t > duration - decay) return ((duration - t) / decay).clamp(0.0, 1.0);
    return 1.0;
  }

  /// En-tête WAV 44 octets + espace PCM
  static Uint8List _wavHeader(int samples) {
    const int channels      = 1;
    const int bitsPerSample = 16;
    final int dataSize      = samples * channels * (bitsPerSample ~/ 8);
    final buf               = ByteData(44 + dataSize);

    void setStr(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        buf.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    setStr(0, 'RIFF');
    buf.setUint32(4,  36 + dataSize, Endian.little);
    setStr(8,  'WAVE');
    setStr(12, 'fmt ');
    buf.setUint32(16, 16, Endian.little);
    buf.setUint16(20, 1,  Endian.little); // PCM
    buf.setUint16(22, channels, Endian.little);
    buf.setUint32(24, _sampleRate, Endian.little);
    buf.setUint32(28, _sampleRate * channels * (bitsPerSample ~/ 8), Endian.little);
    buf.setUint16(32, channels * (bitsPerSample ~/ 8), Endian.little);
    buf.setUint16(34, bitsPerSample, Endian.little);
    setStr(36, 'data');
    buf.setUint32(40, dataSize, Endian.little);

    return buf.buffer.asUint8List();
  }
}
