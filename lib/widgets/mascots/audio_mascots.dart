import 'dart:math' as math;
import 'package:flutter/material.dart';

enum AudioMascotMood { idle, speaking, listening, happy, thinking, sad }

enum AudioMascotSize {
  sm(72.0),
  md(100.0),
  lg(130.0),
  xl(170.0);

  final double value;
  const AudioMascotSize(this.value);
}

// ─────────────────────────────────────────────────────────────────────────────
// AWA  — tresses, robe verte, cahier bleu
// ─────────────────────────────────────────────────────────────────────────────

class AwaMascot extends StatefulWidget {
  final AudioMascotMood mood;
  final AudioMascotSize size;
  const AwaMascot({super.key, this.mood = AudioMascotMood.idle, this.size = AudioMascotSize.md});
  @override
  State<AwaMascot> createState() => _AwaMascotState();
}

class _AwaMascotState extends State<AwaMascot> with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _speakCtrl;
  late final AnimationController _blinkCtrl;
  late final AnimationController _sadCtrl;
  late final Animation<double> _blinkAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _speakCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280))
      ..repeat(reverse: true);
    _blinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))
      ..repeat();
    _blinkAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 2),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 96),
    ]).animate(_blinkCtrl);
    _sadCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _speakCtrl.dispose();
    _blinkCtrl.dispose();
    _sadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatCtrl, _speakCtrl, _blinkCtrl, _sadCtrl]),
      builder: (_, __) {
        final floatY = -5.0 + Curves.easeInOut.transform(_floatCtrl.value) * 10.0;
        final mouthOpen = widget.mood == AudioMascotMood.speaking
            ? _speakCtrl.value
            : (widget.mood == AudioMascotMood.happy ? 0.45 : 0.0);
        final sadSway = widget.mood == AudioMascotMood.sad
            ? math.sin(_sadCtrl.value * math.pi * 2) * 2.5
            : 0.0;
        return Transform.translate(
          offset: Offset(sadSway, floatY),
          child: SizedBox(
            width: widget.size.value,
            height: widget.size.value * 1.65,
            child: CustomPaint(
              painter: _AwaPainter(mouthOpen: mouthOpen, blink: _blinkAnim.value, mood: widget.mood),
            ),
          ),
        );
      },
    );
  }
}

class _AwaPainter extends CustomPainter {
  final double mouthOpen;
  final double blink;
  final AudioMascotMood mood;

  static const _skin     = Color(0xFF8B5430);
  static const _skinDk   = Color(0xFF7A4020);
  static const _skinRosy = Color(0xFFB06840);
  static const _hair     = Color(0xFF150800);
  static const _dresG    = Color(0xFF1A8A3C);
  static const _trimOr   = Color(0xFFF5A20A);
  static const _trimG    = Color(0xFF0A6620);
  static const _eyeW     = Color(0xFFFFF8EE);
  static const _iris     = Color(0xFF3A1800);
  static const _pupil    = Color(0xFF0A0400);
  static const _nb       = Color(0xFF1A3BAA);
  static const _nbDk     = Color(0xFF112888);
  static const _gold     = Color(0xFFD4A017);
  static const _teeth    = Color(0xFFFFF8F0);
  static const _lips     = Color(0xFFC0704A);

  const _AwaPainter({required this.mouthOpen, required this.blink, required this.mood});

  Paint _f(Color c, {double o = 1.0}) =>
      Paint()..color = o < 1 ? c.withValues(alpha: o) : c..style = PaintingStyle.fill;
  Paint _st(Color c, double w) =>
      Paint()..color = c..strokeWidth = w..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final sc = math.min(size.width / 120, size.height / 200);
    canvas.save();
    canvas.translate((size.width - 120 * sc) / 2, (size.height - 200 * sc) / 2);
    canvas.scale(sc);
    _drawBraidsBack(canvas);
    _drawDress(canvas);
    _drawNotebook(canvas);
    _drawLeftArm(canvas);
    _drawNeck(canvas);
    _drawHead(canvas);
    _drawEars(canvas);
    _drawHairCap(canvas);
    _drawFace(canvas);
    canvas.restore();
  }

  void _drawBraidsBack(Canvas canvas) {
    final p = _st(_hair, 8);
    for (int i = 0; i < 3; i++) {
      final sx = 26.0 + i * 9;
      canvas.drawPath(
        Path()..moveTo(sx, 22)..cubicTo(sx - 18, 75, sx - 24, 135, sx - 22 + i * 4.0, 190), p);
    }
    for (int i = 0; i < 3; i++) {
      final sx = 94.0 - i * 9;
      canvas.drawPath(
        Path()..moveTo(sx, 22)..cubicTo(sx + 18, 75, sx + 24, 135, sx + 22 - i * 4.0, 190), p);
    }
  }

  void _drawDress(Canvas canvas) {
    canvas.drawPath(
      Path()..moveTo(33, 105)..lineTo(15, 198)..lineTo(105, 198)..lineTo(87, 105)..close(),
      _f(_dresG),
    );
    canvas.drawOval(Rect.fromLTWH(10, 106, 28, 22), _f(_dresG));
    canvas.drawOval(Rect.fromLTWH(82, 106, 28, 22), _f(_dresG));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(30, 99, 60, 12), const Radius.circular(4)), _f(_trimOr));
    for (int i = 0; i < 6; i++) {
      final tx = 33.0 + i * 9.5;
      canvas.drawPath(
        Path()..moveTo(tx, 100)..lineTo(tx + 4, 110)..lineTo(tx + 8, 100)..close(),
        _f(_trimG),
      );
    }
    canvas.drawRect(Rect.fromLTWH(10, 124, 28, 5), _f(_trimOr));
    canvas.drawRect(Rect.fromLTWH(82, 124, 28, 5), _f(_trimOr));
  }

  void _drawNotebook(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(65, 127, 44, 58), const Radius.circular(4)), _f(_nb));
    canvas.drawRect(Rect.fromLTWH(65, 127, 6, 58), _f(_nbDk));
    for (int i = 0; i < 9; i++) {
      canvas.drawCircle(Offset(74 + (i % 3) * 12.0, 135 + (i ~/ 3) * 14.0), 1.8, _f(Colors.white, o: 0.28));
    }
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(69, 149, 33, 21), const Radius.circular(3)), _f(Colors.white));
    final tp = TextPainter(
      text: const TextSpan(text: 'Awa', style: TextStyle(color: Color(0xFF111111), fontSize: 10, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(69 + (33 - tp.width) / 2, 149 + (21 - tp.height) / 2));
  }

  void _drawLeftArm(Canvas canvas) {
    canvas.drawPath(
      Path()..moveTo(26, 128)..cubicTo(14, 148, 12, 165, 14, 178)..lineTo(20, 178)..cubicTo(18, 164, 20, 148, 28, 130)..close(),
      _f(_skin),
    );
  }

  void _drawNeck(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(51, 88, 18, 20), const Radius.circular(5)), _f(_skin));
  }

  void _drawHead(Canvas canvas) {
    canvas.drawOval(Rect.fromLTWH(24, 10, 72, 84), _f(_skin));
    canvas.drawCircle(const Offset(36, 63), 8, _f(_skinRosy, o: 0.32));
    canvas.drawCircle(const Offset(84, 63), 8, _f(_skinRosy, o: 0.32));
  }

  void _drawEars(Canvas canvas) {
    canvas.drawOval(Rect.fromLTWH(17, 48, 12, 18), _f(_skin));
    canvas.drawCircle(const Offset(19, 62), 3.5, _st(_gold, 2.5));
    canvas.drawOval(Rect.fromLTWH(91, 48, 12, 18), _f(_skin));
    canvas.drawCircle(const Offset(101, 62), 3.5, _st(_gold, 2.5));
  }

  void _drawHairCap(Canvas canvas) {
    canvas.drawPath(
      Path()
        ..moveTo(24, 52)
        ..quadraticBezierTo(25, 6, 60, 4)
        ..quadraticBezierTo(95, 6, 96, 52)
        ..quadraticBezierTo(82, 26, 60, 25)
        ..quadraticBezierTo(38, 26, 24, 52)
        ..close(),
      _f(_hair),
    );
  }

  void _drawFace(Canvas canvas) {
    // Sourcils
    final bp = _st(_hair, 2.5);
    if (mood == AudioMascotMood.sad) {
      // Inquiètes : extrémités internes relevées
      canvas.drawPath(Path()..moveTo(36, 40)..quadraticBezierTo(44, 36, 54, 38), bp);
      canvas.drawPath(Path()..moveTo(66, 38)..quadraticBezierTo(76, 36, 84, 40), bp);
    } else {
      canvas.drawPath(Path()..moveTo(36, 37)..quadraticBezierTo(44, 33, 54, 36), bp);
      canvas.drawPath(Path()..moveTo(66, 36)..quadraticBezierTo(76, 33, 84, 37), bp);
    }

    // Yeux
    const r = 9.0;
    for (final c in [const Offset(45, 48), const Offset(75, 48)]) {
      canvas.drawCircle(c, r, _f(_eyeW));
      if (blink > 0) {
        final lidH = r * 2 * blink;
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(c.dx - r, c.dy - r, r * 2, r * 2));
        canvas.drawRect(Rect.fromLTWH(c.dx - r, c.dy - r, r * 2, lidH), _f(_skin));
        canvas.restore();
      } else if (mood == AudioMascotMood.sad) {
        final ic = Offset(c.dx - 0.5, c.dy + 2.0); // regard baissé
        canvas.drawCircle(ic, 6, _f(_iris));
        canvas.drawCircle(ic, 3, _f(_pupil));
        canvas.drawCircle(Offset(ic.dx + 2, ic.dy - 2), 1.5, _f(Colors.white));
        // Paupière tombante
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - r, c.dy - r + 4)
            ..quadraticBezierTo(c.dx, c.dy - r, c.dx + r, c.dy - r + 4),
          _st(_hair, 3.5),
        );
      } else {
        canvas.drawCircle(c, 6, _f(_iris));
        canvas.drawCircle(c, 3, _f(_pupil));
        canvas.drawCircle(Offset(c.dx + 2, c.dy - 2), 1.5, _f(Colors.white));
      }
      canvas.drawCircle(c, r, _st(_hair, 1.4));
      final lp = _st(_hair, 1.5);
      for (int i = -2; i <= 2; i++) {
        canvas.drawLine(Offset(c.dx + i * 3.5, c.dy - r), Offset(c.dx + i * 3.8, c.dy - r - 4), lp);
      }
    }

    // Nez
    canvas.drawCircle(const Offset(56, 65), 2.2, _f(_skinDk, o: 0.45));
    canvas.drawCircle(const Offset(64, 65), 2.2, _f(_skinDk, o: 0.45));

    // Bouche
    if (mood == AudioMascotMood.sad) {
      canvas.drawPath(Path()..moveTo(50, 80)..quadraticBezierTo(60, 73, 70, 80), _st(_lips, 2.5));
      canvas.drawPath(
        Path()..moveTo(50, 80)..quadraticBezierTo(55, 78, 60, 79)..quadraticBezierTo(65, 78, 70, 80),
        _st(_lips.withValues(alpha: 0.4), 1.5),
      );
    } else if (mouthOpen > 0.1) {
      final h = 7.0 * mouthOpen;
      canvas.drawPath(
        Path()..moveTo(50, 76)..quadraticBezierTo(60, 76 + h * 2, 70, 76),
        _f(_iris),
      );
      if (mouthOpen > 0.3) canvas.drawRect(Rect.fromLTWH(52, 76, 16, h * 1.4), _f(_teeth));
      canvas.drawPath(Path()..moveTo(50, 76)..quadraticBezierTo(55, 73, 60, 74)..quadraticBezierTo(65, 73, 70, 76), _st(_lips, 2));
      canvas.drawPath(Path()..moveTo(50, 76)..quadraticBezierTo(60, 76 + h * 2.2, 70, 76), _st(_lips, 1.5));
    } else {
      canvas.drawPath(Path()..moveTo(50, 76)..quadraticBezierTo(60, 84, 70, 76), _st(_lips, 2.5));
      canvas.drawPath(
        Path()..moveTo(50, 76)..quadraticBezierTo(55, 74, 60, 75)..quadraticBezierTo(65, 74, 70, 76),
        _st(_lips.withValues(alpha: 0.55), 1.5),
      );
    }
  }

  @override
  bool shouldRepaint(_AwaPainter o) => o.mouthOpen != mouthOpen || o.blink != blink || o.mood != mood;
}

// ─────────────────────────────────────────────────────────────────────────────
// TIGA  — afro, t-shirt jaune, short bleu, pose penseur
// ─────────────────────────────────────────────────────────────────────────────

class TigaMascot extends StatefulWidget {
  final AudioMascotMood mood;
  final AudioMascotSize size;
  const TigaMascot({super.key, this.mood = AudioMascotMood.idle, this.size = AudioMascotSize.md});
  @override
  State<TigaMascot> createState() => _TigaMascotState();
}

class _TigaMascotState extends State<TigaMascot> with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _speakCtrl;
  late final AnimationController _blinkCtrl;
  late final AnimationController _thinkCtrl;
  late final Animation<double> _blinkAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
    _speakCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280))
      ..repeat(reverse: true);
    _blinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3800))
      ..repeat();
    _blinkAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 2),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 96),
    ]).animate(_blinkCtrl);
    _thinkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _speakCtrl.dispose();
    _blinkCtrl.dispose();
    _thinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatCtrl, _speakCtrl, _blinkCtrl, _thinkCtrl]),
      builder: (_, __) {
        final floatY = -5.0 + Curves.easeInOut.transform(_floatCtrl.value) * 10.0;
        final mouthOpen = widget.mood == AudioMascotMood.speaking ? _speakCtrl.value : 0.0;
        final tilt = widget.mood == AudioMascotMood.thinking ? _thinkCtrl.value * 0.05 : 0.0;
        final sadSway = widget.mood == AudioMascotMood.sad
            ? math.sin(_thinkCtrl.value * math.pi * 2) * 2.5
            : 0.0;
        return Transform.translate(
          offset: Offset(sadSway, floatY),
          child: Transform.rotate(
            angle: tilt,
            child: SizedBox(
              width: widget.size.value,
              height: widget.size.value * 1.65,
              child: CustomPaint(
                painter: _TigaPainter(
                  mouthOpen: mouthOpen,
                  blink: _blinkAnim.value,
                  mood: widget.mood,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TigaPainter extends CustomPainter {
  final double mouthOpen;
  final double blink;
  final AudioMascotMood mood;

  static const _skin    = Color(0xFF7B3F10);
  static const _skinDk  = Color(0xFF6A3208);
  static const _skinRos = Color(0xFF9E5828);
  static const _hair    = Color(0xFF1A0800);
  static const _shirtY  = Color(0xFFFFC107);
  static const _shirtD  = Color(0xFFE5A800);
  static const _shortsB = Color(0xFF1565C0);
  static const _shortsD = Color(0xFF0D47A1);
  static const _eyeW    = Color(0xFFFFF8EE);
  static const _iris    = Color(0xFF3A1800);
  static const _pupil   = Color(0xFF0A0400);
  static const _teeth   = Color(0xFFFFF8F0);
  static const _lips    = Color(0xFFB06040);

  const _TigaPainter({required this.mouthOpen, required this.blink, required this.mood});

  Paint _f(Color c, {double o = 1.0}) =>
      Paint()..color = o < 1 ? c.withValues(alpha: o) : c..style = PaintingStyle.fill;
  Paint _st(Color c, double w) =>
      Paint()..color = c..strokeWidth = w..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final sc = math.min(size.width / 120, size.height / 200);
    canvas.save();
    canvas.translate((size.width - 120 * sc) / 2, (size.height - 200 * sc) / 2);
    canvas.scale(sc);
    _drawShirt(canvas);
    _drawShorts(canvas);
    _drawLeftArm(canvas);
    _drawRightArm(canvas);
    _drawNeck(canvas);
    _drawHead(canvas);
    _drawAfro(canvas);
    _drawFace(canvas);
    canvas.restore();
  }

  void _drawShirt(Canvas canvas) {
    canvas.drawPath(
      Path()..moveTo(28, 103)..lineTo(92, 103)..lineTo(95, 150)..lineTo(25, 150)..close(),
      _f(_shirtY),
    );
    canvas.drawPath(Path()..moveTo(55, 103)..lineTo(52, 150), _st(_shirtD, 1));
    final tp = TextPainter(
      text: const TextSpan(text: 'Tiga', style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 13, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(60 - tp.width / 2, 122));
  }

  void _drawShorts(Canvas canvas) {
    canvas.drawPath(
      Path()..moveTo(25, 148)..lineTo(57, 148)..lineTo(54, 198)..lineTo(18, 198)..close(),
      _f(_shortsB),
    );
    canvas.drawPath(
      Path()..moveTo(63, 148)..lineTo(95, 148)..lineTo(102, 198)..lineTo(66, 198)..close(),
      _f(_shortsB),
    );
    canvas.drawRect(Rect.fromLTWH(25, 148, 70, 8), _f(_shortsD));
    canvas.drawLine(const Offset(60, 156), const Offset(60, 198), _st(_shortsD, 1.5));
  }

  void _drawLeftArm(Canvas canvas) {
    canvas.drawPath(
      Path()..moveTo(28, 113)..cubicTo(16, 138, 14, 158, 16, 172)..lineTo(22, 172)..cubicTo(20, 156, 22, 136, 28, 115)..close(),
      _f(_skin),
    );
    canvas.drawCircle(const Offset(18, 174), 6, _f(_skin));
  }

  void _drawRightArm(Canvas canvas) {
    // Upper arm (out and slightly down)
    canvas.drawPath(
      Path()
        ..moveTo(88, 108)
        ..cubicTo(102, 112, 108, 126, 104, 136)
        ..lineTo(98, 132)
        ..cubicTo(102, 122, 96, 110, 86, 108)
        ..close(),
      _f(_skin),
    );
    // Forearm (bending up to chin)
    canvas.drawPath(
      Path()
        ..moveTo(104, 136)
        ..cubicTo(110, 128, 96, 92, 72, 82)
        ..lineTo(70, 88)
        ..cubicTo(90, 98, 104, 130, 98, 134)
        ..close(),
      _f(_skin),
    );
    // Hand near chin
    canvas.drawCircle(const Offset(68, 82), 7, _f(_skin));
    // Index finger pointing up
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(65, 67, 6, 18), const Radius.circular(3)),
      _f(_skin),
    );
    canvas.drawLine(const Offset(65, 74), const Offset(71, 74), _st(_skinDk, 0.8));
    canvas.drawLine(const Offset(65, 79), const Offset(71, 79), _st(_skinDk, 0.8));
  }

  void _drawNeck(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(52, 88, 16, 18), const Radius.circular(5)), _f(_skin));
  }

  void _drawHead(Canvas canvas) {
    canvas.drawOval(Rect.fromLTWH(29, 16, 62, 72), _f(_skin));
    canvas.drawCircle(const Offset(40, 62), 7, _f(_skinRos, o: 0.30));
    canvas.drawCircle(const Offset(80, 62), 7, _f(_skinRos, o: 0.30));
    canvas.drawOval(Rect.fromLTWH(22, 46, 10, 16), _f(_skin));
    canvas.drawOval(Rect.fromLTWH(88, 46, 10, 16), _f(_skin));
  }

  void _drawAfro(Canvas canvas) {
    final p = _f(_hair);
    for (final b in [
      [60.0, 12.0, 28.0], [38.0, 22.0, 20.0], [82.0, 22.0, 20.0],
      [48.0, 8.0, 18.0],  [72.0, 8.0, 18.0],  [60.0, 2.0, 16.0],
      [34.0, 32.0, 15.0], [86.0, 32.0, 15.0],
    ]) {
      canvas.drawCircle(Offset(b[0], b[1]), b[2], p);
    }
    // Subtle curl highlights
    final cp = _st(_hair.withValues(alpha: 0.45), 1.5);
    for (final h in [
      [50.0, 6.0, 56.0, 11.0], [65.0, 4.0, 71.0, 10.0],
      [42.0, 18.0, 48.0, 14.0], [76.0, 18.0, 81.0, 13.0],
    ]) {
      canvas.drawPath(Path()..moveTo(h[0], h[1])..quadraticBezierTo(h[0] + 3, h[1] - 4, h[2], h[3]), cp);
    }
  }

  void _drawFace(Canvas canvas) {
    final bp = _st(_hair, 2.5);
    if (mood == AudioMascotMood.sad) {
      // Sourcils inquiets : extrémités internes relevées
      canvas.drawPath(Path()..moveTo(38, 39)..quadraticBezierTo(47, 35, 57, 37), bp);
      canvas.drawPath(Path()..moveTo(63, 37)..quadraticBezierTo(73, 35, 82, 39), bp);
    } else {
      // Sourcils normaux (curieux, légèrement relevés)
      canvas.drawPath(Path()..moveTo(38, 36)..quadraticBezierTo(47, 31, 57, 34), bp);
      canvas.drawPath(Path()..moveTo(63, 34)..quadraticBezierTo(73, 31, 82, 36), bp);
    }

    // Yeux
    const r = 8.0;
    for (final c in [const Offset(48, 50), const Offset(72, 50)]) {
      canvas.drawCircle(c, r, _f(_eyeW));
      if (blink > 0) {
        final lidH = r * 2 * blink;
        canvas.save();
        canvas.clipRect(Rect.fromLTWH(c.dx - r, c.dy - r, r * 2, r * 2));
        canvas.drawRect(Rect.fromLTWH(c.dx - r, c.dy - r, r * 2, lidH), _f(_skin));
        canvas.restore();
      } else if (mood == AudioMascotMood.sad) {
        final ic = Offset(c.dx - 0.5, c.dy + 2.0); // regard baissé
        canvas.drawCircle(ic, 5.5, _f(_iris));
        canvas.drawCircle(ic, 2.5, _f(_pupil));
        canvas.drawCircle(Offset(ic.dx + 1.5, ic.dy - 1.5), 1.2, _f(Colors.white));
        // Paupière tombante
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - r, c.dy - r + 4)
            ..quadraticBezierTo(c.dx, c.dy - r, c.dx + r, c.dy - r + 4),
          _st(_hair, 3.5),
        );
      } else {
        final ic = Offset(c.dx + 0.5, c.dy - 1.5);
        canvas.drawCircle(ic, 5.5, _f(_iris));
        canvas.drawCircle(ic, 2.5, _f(_pupil));
        canvas.drawCircle(Offset(ic.dx + 1.5, ic.dy - 1.5), 1.2, _f(Colors.white));
      }
      canvas.drawCircle(c, r, _st(_hair, 1.4));
      final lp = _st(_hair, 1.4);
      for (int i = -2; i <= 2; i++) {
        canvas.drawLine(Offset(c.dx + i * 3.2, c.dy - r), Offset(c.dx + i * 3.4, c.dy - r - 3), lp);
      }
    }

    // Nez
    canvas.drawCircle(const Offset(56, 65), 2.2, _f(_skinDk, o: 0.4));
    canvas.drawCircle(const Offset(64, 65), 2.2, _f(_skinDk, o: 0.4));

    // Bouche
    if (mood == AudioMascotMood.sad) {
      canvas.drawPath(Path()..moveTo(50, 80)..quadraticBezierTo(60, 73, 70, 80), _st(_lips, 2.5));
      canvas.drawPath(
        Path()..moveTo(50, 80)..quadraticBezierTo(55, 78, 60, 79)..quadraticBezierTo(65, 78, 70, 80),
        _st(_lips.withValues(alpha: 0.4), 1.5),
      );
    } else if (mouthOpen > 0.1) {
      final h = 8.0 * mouthOpen;
      canvas.drawPath(Path()..moveTo(50, 76)..quadraticBezierTo(60, 76 + h * 2, 70, 76), _f(_iris));
      if (mouthOpen > 0.3) canvas.drawRect(Rect.fromLTWH(52, 76, 16, h * 1.5), _f(_teeth));
      canvas.drawPath(Path()..moveTo(50, 76)..quadraticBezierTo(60, 76 + h * 2.2, 70, 76), _st(_lips, 2));
    } else {
      canvas.drawPath(Path()..moveTo(50, 76)..quadraticBezierTo(60, 82, 70, 76), _st(_lips, 2.5));
      canvas.drawOval(Rect.fromLTWH(54, 76, 12, 5), _f(_iris, o: 0.35));
      canvas.drawOval(Rect.fromLTWH(55, 76, 10, 3), _f(_teeth, o: 0.9));
    }
  }

  @override
  bool shouldRepaint(_TigaPainter o) =>
      o.mouthOpen != mouthOpen || o.blink != blink || o.mood != mood;
}

// ─────────────────────────────────────────────────────────────────────────────
// AUDIO MASCOT PAIR  — alterne Awa (pair) / Tiga (impair) par index d'étape
// ─────────────────────────────────────────────────────────────────────────────

class AudioMascotPair extends StatelessWidget {
  final int stepIndex;
  final AudioMascotMood mood;
  final AudioMascotSize size;

  const AudioMascotPair({
    super.key,
    required this.stepIndex,
    this.mood = AudioMascotMood.idle,
    this.size = AudioMascotSize.md,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: anim, child: child),
      ),
      child: stepIndex % 2 == 0
          ? AwaMascot(key: const ValueKey('awa'), mood: mood, size: size)
          : TigaMascot(key: const ValueKey('tiga'), mood: mood, size: size),
    );
  }
}
