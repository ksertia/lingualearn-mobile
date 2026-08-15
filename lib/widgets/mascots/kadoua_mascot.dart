import 'dart:math' as math;
import 'package:flutter/material.dart';

enum KadouaMood { speaking, correct, incorrect }

enum KadouaSize {
  sm(72.0),
  md(100.0),
  lg(130.0),
  xl(170.0);

  final double value;
  const KadouaSize(this.value);
}

// ─────────────────────────────────────────────────────────────────────────────
// KADOUA — petite fille africaine, chignon tressé, robe rose
// 3 humeurs : speaking (bouche mobile), correct (joie + bond), incorrect (triste + larme)
// ─────────────────────────────────────────────────────────────────────────────

class KadouaMascot extends StatefulWidget {
  final KadouaMood mood;
  final KadouaSize size;

  const KadouaMascot({
    super.key,
    this.mood = KadouaMood.speaking,
    this.size = KadouaSize.md,
  });

  @override
  State<KadouaMascot> createState() => _KadouaMascotState();
}

class _KadouaMascotState extends State<KadouaMascot>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _speakCtrl;
  late final AnimationController _blinkCtrl;
  late final AnimationController _happyCtrl;
  late final AnimationController _sadCtrl;
  late final Animation<double> _blinkAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _speakCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320))
      ..repeat(reverse: true);
    _blinkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3400))
      ..repeat();
    _blinkAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 2),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 96),
    ]).animate(_blinkCtrl);
    _happyCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
    _sadCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _speakCtrl.dispose();
    _blinkCtrl.dispose();
    _happyCtrl.dispose();
    _sadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_floatCtrl, _speakCtrl, _blinkCtrl, _happyCtrl, _sadCtrl]),
      builder: (_, __) {
        final baseY =
            -4.0 + Curves.easeInOut.transform(_floatCtrl.value) * 8.0;
        final happyBounce = widget.mood == KadouaMood.correct
            ? -math.sin(_happyCtrl.value * math.pi) * 10.0
            : 0.0;
        final sadSway = widget.mood == KadouaMood.incorrect
            ? math.sin(_sadCtrl.value * math.pi * 2) * 2.5
            : 0.0;

        return Transform.translate(
          offset: Offset(sadSway, baseY + happyBounce),
          child: SizedBox(
            width: widget.size.value,
            height: widget.size.value * 1.65,
            child: CustomPaint(
              painter: _KadouaPainter(
                mood: widget.mood,
                mouthOpen: widget.mood == KadouaMood.speaking
                    ? _speakCtrl.value
                    : 0.0,
                blink: _blinkAnim.value,
                happyAnim: widget.mood == KadouaMood.correct
                    ? _happyCtrl.value
                    : 0.0,
                sadAnim: widget.mood == KadouaMood.incorrect
                    ? _sadCtrl.value
                    : 0.0,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _KadouaPainter extends CustomPainter {
  final KadouaMood mood;
  final double mouthOpen;
  final double blink;
  final double happyAnim;
  final double sadAnim;

  static const _skin     = Color(0xFF6B3412);
  static const _skinDk   = Color(0xFF542808);
  static const _skinRosy = Color(0xFF8B4A20);
  static const _hair     = Color(0xFF160900);
  static const _beadPink = Color(0xFFFF5FAA);
  static const _dressP   = Color(0xFFE91C8B);
  static const _dressDk  = Color(0xFFD81880);
  static const _dressTrim= Color(0xFFFFB7D5);
  static const _eyeW     = Color(0xFFFFF8EE);
  static const _iris     = Color(0xFF8B5010);
  static const _pupil    = Color(0xFF1A0800);
  static const _gold     = Color(0xFFD4A017);
  static const _teeth    = Color(0xFFFFF8F0);
  static const _lips     = Color(0xFFBB6040);
  static const _tearClr  = Color(0xFF6BB8D8);

  const _KadouaPainter({
    required this.mood,
    required this.mouthOpen,
    required this.blink,
    required this.happyAnim,
    required this.sadAnim,
  });

  Paint _f(Color c, {double o = 1.0}) =>
      Paint()
        ..color = o < 1 ? c.withValues(alpha: o) : c
        ..style = PaintingStyle.fill;
  Paint _st(Color c, double w) =>
      Paint()
        ..color = c
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final sc = math.min(size.width / 120, size.height / 200);
    canvas.save();
    canvas.translate(
        (size.width - 120 * sc) / 2, (size.height - 200 * sc) / 2);
    canvas.scale(sc);

    _drawDress(canvas);
    _drawFeet(canvas);
    _drawNeck(canvas);
    _drawHead(canvas);
    _drawEars(canvas);
    _drawHair(canvas);
    _drawFace(canvas);

    canvas.restore();
  }

  // ── Robe ──────────────────────────────────────────────────────────────────
  void _drawDress(Canvas canvas) {
    // Manches bouffantes
    canvas.drawOval(Rect.fromLTWH(7, 96, 30, 28), _f(_dressP));
    canvas.drawOval(Rect.fromLTWH(83, 96, 30, 28), _f(_dressP));
    canvas.drawOval(Rect.fromLTWH(10, 98, 16, 14), _f(Colors.white, o: 0.14));
    canvas.drawOval(Rect.fromLTWH(94, 98, 16, 14), _f(Colors.white, o: 0.14));

    // Bras sous les manches
    canvas.drawPath(
      Path()
        ..moveTo(9, 116)
        ..cubicTo(3, 132, 5, 148, 9, 158)
        ..lineTo(15, 156)
        ..cubicTo(11, 144, 9, 130, 13, 118)
        ..close(),
      _f(_skin),
    );
    canvas.drawPath(
      Path()
        ..moveTo(111, 116)
        ..cubicTo(117, 132, 115, 148, 111, 158)
        ..lineTo(105, 156)
        ..cubicTo(111, 144, 111, 130, 107, 118)
        ..close(),
      _f(_skin),
    );

    // Corps de la robe (ligne A) — raccourcie pour laisser voir les pieds
    canvas.drawPath(
      Path()
        ..moveTo(32, 100)
        ..lineTo(88, 100)
        ..lineTo(110, 184)
        ..lineTo(10, 184)
        ..close(),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFD81880), Color(0xFFE91C8B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(8, 100, 104, 84)),
    );

    // Ceinture / bande décorative
    canvas.drawRect(Rect.fromLTWH(26, 125, 68, 9), _f(_dressTrim, o: 0.55));
    canvas.drawRect(Rect.fromLTWH(26, 131, 68, 2), _f(_dressDk, o: 0.35));

    // Encolure arrondie
    canvas.drawPath(
      Path()..moveTo(36, 101)..quadraticBezierTo(60, 93, 84, 101),
      _st(_dressTrim, 2.2),
    );
    canvas.drawCircle(const Offset(60, 106), 4, _f(_dressTrim, o: 0.8));
    canvas.drawCircle(const Offset(60, 106), 2, _f(_dressP));

    // Étoiles scintillantes (correct)
    if (happyAnim > 0.3) {
      _drawStar(canvas, const Offset(28, 152), happyAnim);
      _drawStar(canvas, const Offset(92, 152), happyAnim);
      _drawStar(canvas, const Offset(60, 170), happyAnim * 0.7);
    }
  }

  // ── Pieds ─────────────────────────────────────────────────────────────────
  void _drawFeet(Canvas canvas) {
    for (final cx in [42.0, 78.0]) {
      // Petite jambe qui dépasse de la robe
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 5, 180, 10, 8), const Radius.circular(4)),
        _f(_skin),
      );
      // Chaussure ronde
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 10, 186, 20, 12), const Radius.circular(7)),
        _f(_gold),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 10, 186, 20, 5), const Radius.circular(4)),
        _f(const Color(0xFFFFE066), o: 0.55),
      );
    }
  }

  void _drawStar(Canvas canvas, Offset c, double p) {
    final paint = Paint()
      ..color = const Color(0xFFFFE066).withValues(alpha: ((p - 0.3) * 1.4).clamp(0.0, 0.9))
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final r = 7.0 * p;
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2 - math.pi / 4;
      canvas.drawLine(
        Offset(c.dx + math.cos(a) * 2, c.dy + math.sin(a) * 2),
        Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r),
        paint,
      );
    }
  }

  // ── Cou ───────────────────────────────────────────────────────────────────
  void _drawNeck(Canvas canvas) {
    canvas.drawRRect(      RRect.fromRectAndRadius(
          Rect.fromLTWH(50, 90, 20, 14), const Radius.circular(5)),
      _f(_skin),
    );
  }

  // ── Tête ──────────────────────────────────────────────────────────────────
  void _drawHead(Canvas canvas) {
    canvas.drawOval(Rect.fromLTWH(22, 10, 76, 84), _f(_skin));
    // Joues rosées — plus basses et plus pleines pour un air enfantin
    canvas.drawCircle(const Offset(30, 70), 13, _f(_skinRosy, o: 0.25));
    canvas.drawCircle(const Offset(90, 70), 13, _f(_skinRosy, o: 0.25));
    // Joues rougeoyantes (correct)
    if (happyAnim > 0) {
      canvas.drawCircle(
          const Offset(30, 70), 13, _f(const Color(0xFFFF8888), o: happyAnim * 0.28));
      canvas.drawCircle(
          const Offset(90, 70), 13, _f(const Color(0xFFFF8888), o: happyAnim * 0.28));
    }
  }

  // ── Oreilles ──────────────────────────────────────────────────────────────
  void _drawEars(Canvas canvas) {
    canvas.drawOval(Rect.fromLTWH(15, 52, 12, 18), _f(_skin));
    canvas.drawCircle(const Offset(17, 65), 3.5, _f(_gold));
    canvas.drawCircle(const Offset(17, 65), 2.0, _f(const Color(0xFFFFE066)));
    canvas.drawOval(Rect.fromLTWH(93, 52, 12, 18), _f(_skin));
  }

  // ── Cheveux (cornrows + chignon + perles) ─────────────────────────────────
  void _drawHair(Canvas canvas) {
    // Calotte capillaire
    canvas.drawPath(
      Path()
        ..moveTo(22, 60)
        ..quadraticBezierTo(22, 8, 60, 6)
        ..quadraticBezierTo(94, 8, 98, 48)
        ..quadraticBezierTo(84, 20, 60, 18)
        ..quadraticBezierTo(36, 20, 22, 60)
        ..close(),
      _f(_hair),
    );

    // Lignes de tresses remontant vers le chignon
    final cp = _st(const Color(0xFF2A1200), 1.4);
    for (int i = 0; i < 6; i++) {
      final sx = 32.0 + i * 8;
      canvas.drawPath(
        Path()
          ..moveTo(sx, 22)
          ..quadraticBezierTo(sx + 18, 16, 78 + i * 2.0, 22),
        cp,
      );
    }

    // Chignon
    canvas.drawCircle(const Offset(76, 18), 19, _f(_hair));
    canvas.drawCircle(const Offset(76, 18), 14, _f(const Color(0xFF200E00)));
    final bp = _st(const Color(0xFF301800), 1.6);
    for (int i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5;
      canvas.drawArc(
        Rect.fromCenter(
            center: const Offset(76, 18), width: 22, height: 22),
        a, math.pi / 2.2,
        false, bp,
      );
    }

    // Couronne de perles roses autour du chignon
    for (int i = 0; i < 8; i++) {
      final a = -math.pi / 2 + i * (2 * math.pi / 8);
      final bx = 76 + math.cos(a) * 21.0;
      final by = 18 + math.sin(a) * 20.0;
      canvas.drawCircle(Offset(bx, by), 4, _f(_beadPink));
      canvas.drawCircle(
          Offset(bx - 1, by - 1), 1.5, _f(const Color(0xFFFFAACC)));
    }
  }

  // ── Visage ────────────────────────────────────────────────────────────────
  void _drawFace(Canvas canvas) {
    _drawEyebrows(canvas);
    _drawEyes(canvas);
    _drawNose(canvas);
    _drawMouth(canvas);
    if (mood == KadouaMood.incorrect && sadAnim > 0.1) {
      _drawTear(canvas);
    }
  }

  void _drawEyebrows(Canvas canvas) {
    final bp = _st(_hair, 3);
    switch (mood) {
      case KadouaMood.incorrect:
        // Inquiets : extrémités internes relevées
        canvas.drawPath(
            Path()..moveTo(34, 41)..quadraticBezierTo(44, 46, 54, 42), bp);
        canvas.drawPath(
            Path()..moveTo(66, 42)..quadraticBezierTo(76, 46, 86, 41), bp);
        break;
      case KadouaMood.correct:
        // Heureux : haut et arqués
        canvas.drawPath(
            Path()..moveTo(34, 34)..quadraticBezierTo(44, 29, 54, 34), bp);
        canvas.drawPath(
            Path()..moveTo(66, 34)..quadraticBezierTo(76, 29, 86, 34), bp);
        break;
      default:
        canvas.drawPath(
            Path()..moveTo(34, 39)..quadraticBezierTo(44, 34, 54, 38), bp);
        canvas.drawPath(
            Path()..moveTo(66, 38)..quadraticBezierTo(76, 34, 86, 39), bp);
    }
  }

  void _drawEyes(Canvas canvas) {
    if (blink > 0) { _drawBlinkEyes(canvas); return; }
    switch (mood) {
      case KadouaMood.correct:   _drawHappyEyes(canvas);  break;
      case KadouaMood.incorrect: _drawSadEyes(canvas);    break;
      default:                   _drawNormalEyes(canvas);
    }
  }

  void _drawNormalEyes(Canvas canvas) {
    for (final c in [const Offset(43, 58), const Offset(77, 58)]) {
      _drawOneEye(canvas, c, const Offset(0.5, -1.5)); // regard légèrement levé
    }
  }

  void _drawSadEyes(Canvas canvas) {
    for (final c in [const Offset(43, 60), const Offset(77, 60)]) {
      _drawOneEye(canvas, c, const Offset(-0.5, 1.5)); // regard baissé
      // Paupière tombante
      canvas.drawPath(
        Path()
          ..moveTo(c.dx - 11, c.dy - 9)
          ..quadraticBezierTo(c.dx, c.dy - 13, c.dx + 11, c.dy - 9),
        _st(_hair, 3.5),
      );
    }
  }

  void _drawHappyEyes(Canvas canvas) {
    // Yeux arc (^_^)
    final eyeP = _st(_iris, 5.5);
    final rimP = _st(_hair, 2);
    for (final cx in [43.0, 77.0]) {
      canvas.drawPath(
        Path()..moveTo(cx - 11, 58)..quadraticBezierTo(cx, 46, cx + 11, 58),
        eyeP,
      );
      canvas.drawPath(
        Path()..moveTo(cx - 11, 58)..quadraticBezierTo(cx, 46, cx + 11, 58),
        rimP,
      );
      final lp = _st(_hair, 1.5);
      for (int i = -2; i <= 2; i++) {
        canvas.drawLine(
            Offset(cx + i * 3.5, 48), Offset(cx + i * 4, 45), lp);
      }
    }
    // Paillettes dorées près des joues
    final sparkP = _f(const Color(0xFFFFCC00), o: happyAnim * 0.9);
    for (final cx in [30.0, 90.0]) {
      canvas.drawCircle(Offset(cx, 70), 2.5, sparkP);
      canvas.drawCircle(Offset(cx + (cx < 60 ? 6 : -6), 74), 1.8, sparkP);
      canvas.drawCircle(Offset(cx + (cx < 60 ? -3 : 3), 77), 1.5, sparkP);
    }
  }

  void _drawOneEye(Canvas canvas, Offset c, Offset irisOffset) {
    canvas.drawCircle(c, 11, _f(_eyeW));
    final ic = Offset(c.dx + irisOffset.dx, c.dy + irisOffset.dy);
    canvas.drawCircle(ic, 7.5, _f(_iris));
    canvas.drawCircle(ic, 4, _f(_pupil));
    canvas.drawCircle(Offset(ic.dx + 2.2, ic.dy - 2.2), 2, _f(Colors.white));
    canvas.drawCircle(c, 11, _st(_hair, 1.4));
    // Cils supérieurs
    final lp = _st(_hair, 1.5);
    for (int i = -2; i <= 2; i++) {
      canvas.drawLine(
        Offset(c.dx + i * 3.7, c.dy - 11),
        Offset(c.dx + i * 4, c.dy - 15),
        lp,
      );
    }
    // Ligne inférieure de la paupière
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - 10, c.dy + 6.5)
        ..quadraticBezierTo(c.dx, c.dy + 10, c.dx + 10, c.dy + 6.5),
      _st(_hair, 1),
    );
  }

  void _drawBlinkEyes(Canvas canvas) {
    for (final c in [const Offset(43, 58), const Offset(77, 58)]) {
      canvas.drawCircle(c, 11, _f(_eyeW));
      final lidH = 22.0 * blink;
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(c.dx - 11, c.dy - 11, 22, 22));
      canvas.drawRect(
          Rect.fromLTWH(c.dx - 11, c.dy - 11, 22, lidH), _f(_skin));
      canvas.restore();
      canvas.drawCircle(c, 11, _st(_hair, 1.4));
    }
  }

  void _drawNose(Canvas canvas) {
    // Nez discret, resserré — plus enfantin
    canvas.drawCircle(const Offset(57, 76), 2, _f(_skinDk, o: 0.38));
    canvas.drawCircle(const Offset(63, 76), 2, _f(_skinDk, o: 0.38));
  }

  void _drawMouth(Canvas canvas) {
    switch (mood) {
      case KadouaMood.correct:
        // Grand sourire avec dents
        canvas.drawPath(
          Path()..moveTo(46, 86)..quadraticBezierTo(60, 100, 74, 86),
          _st(_lips, 3),
        );
        canvas.drawPath(
          Path()
            ..moveTo(48, 87)
            ..quadraticBezierTo(60, 99, 72, 87)
            ..lineTo(72, 90)
            ..quadraticBezierTo(60, 98, 48, 90)
            ..close(),
          _f(_pupil),
        );
        // Petit sourire de dents, discret et doux (pas de gros bloc blanc)
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(51, 87.5, 18, 4), const Radius.circular(2.5)),
          _f(_teeth),
        );
        break;

      case KadouaMood.incorrect:
        // Moue triste
        canvas.drawPath(
          Path()..moveTo(50, 92)..quadraticBezierTo(60, 84, 70, 92),
          _st(_lips, 3),
        );
        canvas.drawPath(
          Path()
            ..moveTo(52, 92)
            ..quadraticBezierTo(56, 90, 60, 91)
            ..quadraticBezierTo(64, 90, 68, 92),
          _st(_lips.withValues(alpha: 0.4), 1.5),
        );
        break;

      default:
        // Parle : bouche qui s'ouvre/se ferme
        if (mouthOpen > 0.08) {
          final h = 9.0 * mouthOpen;
          canvas.drawPath(
            Path()
              ..moveTo(48, 86)
              ..quadraticBezierTo(60, 86 + h * 2, 72, 86),
            _f(_pupil),
          );
          if (mouthOpen > 0.3) {
            canvas.drawRect(
                Rect.fromLTWH(50, 86, 20, h * 1.3), _f(_teeth));
          }
          canvas.drawPath(
            Path()
              ..moveTo(48, 86)
              ..quadraticBezierTo(60, 86 + h * 2.2, 72, 86),
            _st(_lips, 2.5),
          );
          canvas.drawPath(
            Path()
              ..moveTo(48, 86)
              ..quadraticBezierTo(53, 83, 60, 84)
              ..quadraticBezierTo(67, 83, 72, 86),
            _st(_lips.withValues(alpha: 0.5), 1.5),
          );
        } else {
          // Sourire léger au repos
          canvas.drawPath(
            Path()..moveTo(50, 87)..quadraticBezierTo(60, 95, 70, 87),
            _st(_lips, 2.5),
          );
        }
    }
  }

  // ── Larme (incorrect seulement) ───────────────────────────────────────────
  void _drawTear(Canvas canvas) {
    final progress = ((sadAnim - 0.1) / 0.9).clamp(0.0, 1.0);
    final tearY = 68.0 + progress * 24;
    final opacity = (progress * 1.2).clamp(0.0, 0.85);
    final tearPath = Path()
      ..moveTo(37, tearY - 5)
      ..quadraticBezierTo(32, tearY + 2, 37, tearY + 8)
      ..quadraticBezierTo(42, tearY + 2, 37, tearY - 5);
    canvas.drawPath(tearPath, _f(_tearClr, o: opacity));
    // Reflet dans la larme
    canvas.drawCircle(Offset(35, tearY), 1.2, _f(Colors.white, o: opacity * 0.7));
  }

  @override
  bool shouldRepaint(_KadouaPainter o) =>
      o.mood != mood ||
      o.mouthOpen != mouthOpen ||
      o.blink != blink ||
      o.happyAnim != happyAnim ||
      o.sadAnim != sadAnim;
}
