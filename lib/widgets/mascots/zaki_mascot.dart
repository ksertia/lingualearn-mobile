import 'dart:math' as math;
import 'package:flutter/material.dart';

// ── Mood ──────────────────────────────────────────────────────────────────────
enum ZakiMood {
  happy,
  excited,
  celebrating,
  surprised,
  sad,
  thinking,
  proud,
  resting,
  victory,
  encouraging,
}

// ── Size ──────────────────────────────────────────────────────────────────────
enum ZakiSize { xs, sm, md, lg, xl }

const _sizeMap = {
  ZakiSize.xs: 48.0,
  ZakiSize.sm: 64.0,
  ZakiSize.md: 88.0,
  ZakiSize.lg: 120.0,
  ZakiSize.xl: 160.0,
};

// ── Widget ────────────────────────────────────────────────────────────────────
class ZakiMascot extends StatefulWidget {
  final ZakiMood mood;
  final ZakiSize size;
  final bool animated;

  const ZakiMascot({
    super.key,
    this.mood = ZakiMood.happy,
    this.size = ZakiSize.md,
    this.animated = true,
  });

  @override
  State<ZakiMascot> createState() => _ZakiMascotState();
}

class _ZakiMascotState extends State<ZakiMascot> with TickerProviderStateMixin {
  // SVG viewBox: 180 × 250
  static const double _vw = 180;
  static const double _vh = 250;

  late final AnimationController _floatCtrl;
  late final AnimationController _waveCtrl;
  late final AnimationController _antennaCtrl;
  late final AnimationController _thrusterCtrl;
  late final AnimationController _eyeCtrl;
  late AnimationController _moodCtrl;

  late Animation<double> _waveAnim;

  double get _pixelW => _sizeMap[widget.size] ?? 88;
  double get _pixelH => _pixelW * _vh / _vw;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _waveAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -20.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -20.0, end: 15.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 15.0, end: 0.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _waveCtrl, curve: Curves.easeInOut));

    _antennaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _thrusterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _eyeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _initMoodCtrl();
  }

  void _initMoodCtrl() {
    final durations = {
      ZakiMood.celebrating: 800,
      ZakiMood.excited: 600,
      ZakiMood.sad: 2000,
    };
    _moodCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durations[widget.mood] ?? 3000),
    )..repeat();
  }

  @override
  void didUpdateWidget(ZakiMascot old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) {
      _moodCtrl.dispose();
      _initMoodCtrl();
    }
    if (widget.animated && !old.animated) {
      _floatCtrl.repeat(reverse: true);
      _waveCtrl.repeat();
      _antennaCtrl.repeat(reverse: true);
      _thrusterCtrl.repeat(reverse: true);
      _eyeCtrl.repeat(reverse: true);
    } else if (!widget.animated && old.animated) {
      _floatCtrl.stop();
      _waveCtrl.stop();
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _waveCtrl.dispose();
    _antennaCtrl.dispose();
    _thrusterCtrl.dispose();
    _eyeCtrl.dispose();
    _moodCtrl.dispose();
    super.dispose();
  }

  // ── Derived animation values ───────────────────────────────────────────────

  double get _floatY {
    if (!widget.animated) return 0;
    return -5 * Curves.easeInOut.transform(_floatCtrl.value);
  }

  double get _antennaOpacity {
    if (!widget.animated) return 1.0;
    return 1.0 - 0.4 * Curves.easeInOut.transform(_antennaCtrl.value);
  }

  double get _thrusterScale {
    if (!widget.animated) return 1.0;
    return 1.0 + 0.2 * Curves.easeInOut.transform(_thrusterCtrl.value);
  }

  double get _eyeGlowOpacity {
    if (!widget.animated) return 0.4;
    return 0.4 + 0.25 * Curves.easeInOut.transform(_eyeCtrl.value);
  }

  // Mood-specific transform values
  double get _moodTranslateX {
    if (!widget.animated) return 0;
    if (widget.mood == ZakiMood.sad) {
      return math.sin(_moodCtrl.value * math.pi * 4) * 3;
    }
    return 0;
  }

  double get _moodTranslateY {
    if (!widget.animated) return 0;
    switch (widget.mood) {
      case ZakiMood.excited:
        return -math.sin(_moodCtrl.value * math.pi * 2).abs() * 12;
      case ZakiMood.celebrating:
        return -math.sin(_moodCtrl.value * math.pi * 2).abs() * 6;
      default:
        return 0;
    }
  }

  double get _moodRotate {
    if (!widget.animated) return 0;
    if (widget.mood == ZakiMood.celebrating) {
      return math.sin(_moodCtrl.value * math.pi * 2) * 6 * math.pi / 180;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatCtrl, _waveCtrl, _antennaCtrl, _thrusterCtrl, _eyeCtrl, _moodCtrl,
      ]),
      builder: (_, __) {
        final totalY = _floatY + _moodTranslateY;
        return Transform.translate(
          offset: Offset(_moodTranslateX, totalY),
          child: Transform.rotate(
            angle: _moodRotate,
            child: SizedBox(
              width: _pixelW,
              height: _pixelH,
              child: CustomPaint(
                painter: _ZakiPainter(
                  mood: widget.mood,
                  waveAngle: widget.animated ? _waveAnim.value : 0,
                  antennaOpacity: _antennaOpacity,
                  thrusterScale: _thrusterScale,
                  eyeGlowOpacity: _eyeGlowOpacity,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────
class _ZakiPainter extends CustomPainter {
  final ZakiMood mood;
  final double waveAngle;
  final double antennaOpacity;
  final double thrusterScale;
  final double eyeGlowOpacity;

  const _ZakiPainter({
    required this.mood,
    required this.waveAngle,
    required this.antennaOpacity,
    required this.thrusterScale,
    required this.eyeGlowOpacity,
  });

  static const double _vw = 180;
  static const double _vh = 250;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / _vw, size.height / _vh);
    canvas.save();
    canvas.scale(s, s);

    _drawThruster(canvas);
    if (mood == ZakiMood.celebrating) {
      _drawHangingArmUp(canvas);
    } else {
      _drawHangingArm(canvas);
    }
    _drawBody(canvas);
    if (mood == ZakiMood.celebrating) {
      _drawWaveArmUp(canvas);
    } else {
      _drawWaveArm(canvas);
    }
    _drawHead(canvas);
    _drawEarRings(canvas);
    _drawFace(canvas);
    _drawAntenna(canvas);

    canvas.restore();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Paint _fill(Color color, {double opacity = 1.0}) => Paint()
    ..color = color.withValues(alpha: opacity)
    ..style = PaintingStyle.fill;

  Paint _stroke(Color color, double width, {double opacity = 1.0}) => Paint()
    ..color = color.withValues(alpha: opacity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  // ── Thruster ──────────────────────────────────────────────────────────────
  void _drawThruster(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(68, 208, 44, 13), const Radius.circular(6.5)),
      _fill(const Color(0xFF1C2731)),
    );

    // Glow layers (scaled vertically by thrusterScale)
    canvas.save();
    canvas.translate(90, 228);
    canvas.scale(1.0, thrusterScale);
    canvas.translate(-90, -228);
    canvas.drawOval(Rect.fromCenter(center: const Offset(90, 228), width: 44, height: 28),
        _fill(const Color(0xFF0099DD), opacity: 0.35));
    canvas.drawOval(Rect.fromCenter(center: const Offset(90, 225), width: 26, height: 18),
        _fill(const Color(0xFF00C4FF), opacity: 0.85));
    canvas.restore();

    canvas.drawOval(Rect.fromCenter(center: const Offset(90, 222), width: 14, height: 10),
        _fill(const Color(0xFF80DFFF)));
    canvas.drawOval(Rect.fromCenter(center: const Offset(90, 220), width: 7, height: 6),
        _fill(Colors.white, opacity: 0.95));
  }

  // ── Hanging arm (robot's left = screen right) ─────────────────────────────
  void _drawHangingArm(Canvas canvas) {
    canvas.drawCircle(const Offset(134, 158), 9, _fill(const Color(0xFF37474F)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(127, 158, 15, 30), const Radius.circular(7)),
      _fill(const Color(0xFF455A64)),
    );
    canvas.drawCircle(const Offset(132, 188), 7, _fill(const Color(0xFF37474F)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(126, 188, 13, 25), const Radius.circular(6)),
      _fill(const Color(0xFF546E7A)),
    );
    canvas.drawCircle(const Offset(131, 214), 10, _fill(const Color(0xFF37474F)));
    final fp = _stroke(const Color(0xFF263238), 3);
    canvas.drawLine(const Offset(125, 208), const Offset(121, 202), fp);
    canvas.drawLine(const Offset(131, 206), const Offset(129, 200), fp);
    canvas.drawLine(const Offset(137, 208), const Offset(139, 203), fp);
  }

  // ── Hanging arm raised (celebrating) ──────────────────────────────────────
  void _drawHangingArmUp(Canvas canvas) {
    canvas.drawCircle(const Offset(134, 158), 9, _fill(const Color(0xFF37474F)));
    canvas.save();
    canvas.translate(134, 158);
    canvas.rotate(45 * math.pi / 180);
    canvas.translate(-134, -158);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(127, 128, 15, 30), const Radius.circular(7)),
      _fill(const Color(0xFF455A64)),
    );
    canvas.restore();
    canvas.drawCircle(const Offset(148, 128), 7, _fill(const Color(0xFF37474F)));
    canvas.save();
    canvas.translate(148, 128);
    canvas.rotate(30 * math.pi / 180);
    canvas.translate(-148, -128);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(144, 106, 13, 24), const Radius.circular(6)),
      _fill(const Color(0xFF546E7A)),
    );
    canvas.restore();
    canvas.drawCircle(const Offset(158, 106), 10, _fill(const Color(0xFF37474F)));
  }

  // ── Body ──────────────────────────────────────────────────────────────────
  void _drawBody(Canvas canvas) {
    const bodyRect = Rect.fromLTWH(46, 144, 88, 66);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, const Radius.circular(28));

    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.30, -0.50),
        radius: 1.0,
        colors: [Colors.white, Color(0xFFE8EDF2)],
      ).createShader(bodyRect);
    canvas.drawRRect(bodyRRect, bodyPaint);
    canvas.drawRRect(bodyRRect, _stroke(const Color(0xFFD4DBE3), 1.5));

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(46, 144, 88, 10), const Radius.circular(5)),
      _fill(const Color(0xFF1565C0)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(46, 200, 88, 10), const Radius.circular(5)),
      _fill(const Color(0xFF0D47A1)),
    );

    // Chest badge
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(58, 160, 64, 34), const Radius.circular(10)),
      _fill(const Color(0xFFF0B429)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(60, 162, 60, 30), const Radius.circular(8)),
      _fill(const Color(0xFFF5BE3A), opacity: 0.45),
    );

    // "Zaki" text
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Zaki',
        style: TextStyle(
          color: Color(0xFF0D47A1),
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          fontFamily: 'sans-serif',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(90 - tp.width / 2, 182 - tp.height / 2));

    canvas.drawCircle(const Offset(55, 180), 4, _fill(const Color(0xFF1565C0), opacity: 0.5));
    canvas.drawCircle(const Offset(125, 180), 4, _fill(const Color(0xFF1565C0), opacity: 0.5));
  }

  // ── Wave arm (robot's right = screen left, animated) ──────────────────────
  void _drawWaveArm(Canvas canvas) {
    canvas.save();
    canvas.translate(46, 158);
    canvas.rotate(waveAngle * math.pi / 180);
    canvas.translate(-46, -158);

    canvas.drawCircle(const Offset(46, 158), 9, _fill(const Color(0xFF37474F)));

    canvas.save();
    canvas.translate(46, 158);
    canvas.rotate(-35 * math.pi / 180);
    canvas.translate(-46, -158);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(30, 130, 15, 30), const Radius.circular(7)),
      _fill(const Color(0xFF455A64)),
    );
    canvas.restore();

    canvas.drawCircle(const Offset(26, 136), 7, _fill(const Color(0xFF37474F)));

    canvas.save();
    canvas.translate(26, 136);
    canvas.rotate(-20 * math.pi / 180);
    canvas.translate(-26, -136);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(14, 110, 13, 26), const Radius.circular(6)),
      _fill(const Color(0xFF546E7A)),
    );
    canvas.restore();

    canvas.drawCircle(const Offset(14, 110), 10, _fill(const Color(0xFF37474F)));
    final fp = _stroke(const Color(0xFF263238), 3);
    canvas.drawLine(const Offset(8, 103), const Offset(4, 96), fp);
    canvas.drawLine(const Offset(13, 101), const Offset(11, 94), fp);
    canvas.drawLine(const Offset(18, 101), const Offset(19, 94), fp);
    canvas.drawLine(const Offset(22, 104), const Offset(26, 99), fp);

    canvas.restore();
  }

  // ── Wave arm raised (celebrating) ─────────────────────────────────────────
  void _drawWaveArmUp(Canvas canvas) {
    canvas.drawCircle(const Offset(46, 158), 9, _fill(const Color(0xFF37474F)));
    canvas.save();
    canvas.translate(46, 158);
    canvas.rotate(-55 * math.pi / 180);
    canvas.translate(-46, -158);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(30, 122, 15, 30), const Radius.circular(7)),
      _fill(const Color(0xFF455A64)),
    );
    canvas.restore();
    canvas.drawCircle(const Offset(22, 124), 7, _fill(const Color(0xFF37474F)));
    canvas.save();
    canvas.translate(22, 124);
    canvas.rotate(-40 * math.pi / 180);
    canvas.translate(-22, -124);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(12, 104, 13, 24), const Radius.circular(6)),
      _fill(const Color(0xFF546E7A)),
    );
    canvas.restore();
    canvas.drawCircle(const Offset(10, 100), 10, _fill(const Color(0xFF37474F)));
  }

  // ── Head ──────────────────────────────────────────────────────────────────
  void _drawHead(Canvas canvas) {
    final headRect = Rect.fromCenter(center: const Offset(90, 84), width: 128, height: 136);

    final headPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.36, -0.56),
        radius: 1.0,
        colors: [Colors.white, Color(0xFFEEF2F6)],
      ).createShader(headRect);
    canvas.drawOval(headRect, headPaint);
    canvas.drawOval(headRect, _stroke(const Color(0xFFD4DBE3), 1.5));

    // Yellow cap
    final cap = Path()
      ..moveTo(38, 66)
      ..cubicTo(42, 24, 138, 24, 142, 66)
      ..cubicTo(124, 52, 56, 52, 38, 66)
      ..close();
    canvas.drawPath(cap, _fill(const Color(0xFFF0B429)));
    final capHi = Path()
      ..moveTo(52, 58)
      ..cubicTo(58, 32, 122, 32, 128, 58)
      ..cubicTo(116, 44, 64, 44, 52, 58)
      ..close();
    canvas.drawPath(capHi, _fill(const Color(0xFFF5BE3A), opacity: 0.55));

    // Screen chrome
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(30, 46, 120, 82), const Radius.circular(22)),
      _fill(const Color(0xFFB0BEC5)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(32, 48, 116, 78), const Radius.circular(20)),
      _fill(const Color(0xFFCFD8DC)),
    );
    // Black screen
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(36, 52, 108, 70), const Radius.circular(17)),
      _fill(const Color(0xFF070918)),
    );
    // Glass reflection
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(36, 52, 56, 16), const Radius.circular(8)),
      _fill(Colors.white, opacity: 0.035),
    );
  }

  // ── Ear rings ─────────────────────────────────────────────────────────────
  void _drawEarRings(Canvas canvas) {
    _drawOneEar(canvas, const Offset(22, 83), isLeft: true);
    _drawOneEar(canvas, const Offset(158, 83), isLeft: false);
  }

  void _drawOneEar(Canvas canvas, Offset c, {required bool isLeft}) {
    canvas.drawCircle(c, 18, _fill(const Color(0xFF1155AA)));
    canvas.drawCircle(c, 13, _fill(const Color(0xFF1976D2)));
    canvas.drawCircle(c, 8, _fill(const Color(0xFF0D47A1)));
    canvas.drawCircle(c, 4, _fill(const Color(0xFF1565C0), opacity: 0.6));
    final arc = Path();
    if (isLeft) {
      arc.moveTo(11, 77);
      arc.quadraticBezierTo(10, 83, 11, 89);
    } else {
      arc.moveTo(169, 77);
      arc.quadraticBezierTo(170, 83, 169, 89);
    }
    canvas.drawPath(arc, _stroke(Colors.white, 1.5, opacity: 0.25));
  }

  // ── Face: eyes + mouth ────────────────────────────────────────────────────
  void _drawFace(Canvas canvas) {
    _drawEyes(canvas);
    _drawMouth(canvas);
  }

  void _drawEyes(Canvas canvas) {
    switch (mood) {
      case ZakiMood.excited:
      case ZakiMood.surprised:
        _drawWideEyes(canvas);
      case ZakiMood.celebrating:
        _drawArcEyes(canvas);
      case ZakiMood.sad:
        _drawWorriedEyes(canvas);
      case ZakiMood.thinking:
      case ZakiMood.resting:
        _drawSquintEyes(canvas);
      case ZakiMood.victory:
        _drawWinkEyes(canvas);
      default:
        _drawNormalEyes(canvas);
    }
  }

  void _drawNormalEyes(Canvas canvas) {
    _oneNormalEye(canvas, const Offset(68, 83));
    _oneNormalEye(canvas, const Offset(112, 83));
  }

  void _oneNormalEye(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 14, _fill(const Color(0xFF0090D0), opacity: eyeGlowOpacity));
    canvas.drawCircle(c, 12, _fill(const Color(0xFF00AAEE)));
    canvas.drawCircle(c, 8, _fill(const Color(0xFF006EA8)));
    canvas.drawCircle(Offset(c.dx + 2, c.dy + 2), 5.5, _fill(const Color(0xFF03101E)));
    canvas.drawCircle(Offset(c.dx - 3, c.dy - 4), 3, _fill(Colors.white, opacity: 0.9));
  }

  void _drawWideEyes(Canvas canvas) {
    _oneWideEye(canvas, const Offset(68, 83));
    _oneWideEye(canvas, const Offset(112, 83));
  }

  void _oneWideEye(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 17, _fill(const Color(0xFF0099E8), opacity: eyeGlowOpacity));
    canvas.drawCircle(c, 15, _fill(const Color(0xFF00BBFF)));
    canvas.drawCircle(c, 10, _fill(const Color(0xFF007ACC)));
    canvas.drawCircle(Offset(c.dx + 3, c.dy + 3), 7, _fill(const Color(0xFF02101E)));
    canvas.drawCircle(Offset(c.dx - 5, c.dy - 5), 4, _fill(Colors.white, opacity: 0.9));
    canvas.drawCircle(Offset(c.dx + 8, c.dy - 7), 2, _fill(Colors.white, opacity: 0.6));
  }

  void _drawArcEyes(Canvas canvas) {
    final p1 = _stroke(const Color(0xFF00DDFF), 5);
    final p2 = _stroke(const Color(0xFF88EEFF), 3, opacity: 0.6);
    void arc(double x1, double cx, double x2, double yc, Paint p) {
      canvas.drawPath(Path()..moveTo(x1, 88)..quadraticBezierTo(cx, yc, x2, 88), p);
    }
    arc(55, 68, 81, 70, p1);
    arc(57, 68, 79, 72, p2);
    arc(99, 112, 125, 70, p1);
    arc(101, 112, 123, 72, p2);
  }

  void _drawWorriedEyes(Canvas canvas) {
    _oneWorriedEye(canvas, const Offset(68, 85), isLeft: true);
    _oneWorriedEye(canvas, const Offset(112, 85), isLeft: false);
  }

  void _oneWorriedEye(Canvas canvas, Offset c, {required bool isLeft}) {
    canvas.drawCircle(c, 11, _fill(const Color(0xFF0077BB), opacity: 0.35));
    canvas.drawCircle(c, 9, _fill(const Color(0xFF0088CC), opacity: 0.75));
    canvas.drawCircle(c, 6, _fill(const Color(0xFF004E77)));
    canvas.drawCircle(Offset(c.dx + 1, c.dy + 2), 4.5, _fill(const Color(0xFF02101E)));
    canvas.drawCircle(Offset(c.dx - 3, c.dy - 3), 2.5, _fill(Colors.white, opacity: 0.7));
    final brow = Path();
    if (isLeft) { brow.moveTo(59, 76); brow.lineTo(72, 80); }
    else        { brow.moveTo(108, 80); brow.lineTo(121, 76); }
    canvas.drawPath(brow, _stroke(const Color(0xFF0088CC), 2.5, opacity: 0.75));
  }

  void _drawSquintEyes(Canvas canvas) {
    _oneSquintEye(canvas, const Offset(68, 84));
    _oneSquintEye(canvas, const Offset(112, 84));
  }

  void _oneSquintEye(Canvas canvas, Offset c) {
    canvas.drawOval(Rect.fromCenter(center: c, width: 24, height: 14),
        _fill(const Color(0xFF0090D0), opacity: eyeGlowOpacity));
    canvas.drawOval(Rect.fromCenter(center: c, width: 20, height: 12),
        _fill(const Color(0xFF00AAEE)));
    canvas.drawOval(Rect.fromCenter(center: c, width: 14, height: 8),
        _fill(const Color(0xFF006EA8)));
    canvas.drawOval(Rect.fromCenter(center: Offset(c.dx + 1, c.dy + 1), width: 9, height: 7),
        _fill(const Color(0xFF02101E)));
    canvas.drawCircle(Offset(c.dx - 3, c.dy - 2), 2, _fill(Colors.white, opacity: 0.85));
    canvas.drawLine(Offset(c.dx - 11, c.dy - 6), Offset(c.dx + 11, c.dy - 6),
        _stroke(const Color(0xFF00AAEE), 2, opacity: 0.5));
  }

  void _drawWinkEyes(Canvas canvas) {
    _oneNormalEye(canvas, const Offset(68, 83));
    final p1 = _stroke(const Color(0xFF00DDFF), 5);
    final p2 = _stroke(const Color(0xFF80EEFF), 3, opacity: 0.6);
    canvas.drawPath(Path()..moveTo(100, 83)..quadraticBezierTo(112, 73, 124, 83), p1);
    canvas.drawPath(Path()..moveTo(102, 83)..quadraticBezierTo(112, 75, 122, 83), p2);
  }

  void _drawMouth(Canvas canvas) {
    switch (mood) {
      case ZakiMood.celebrating:
      case ZakiMood.victory:
        _bigSmile(canvas);
      case ZakiMood.excited:
      case ZakiMood.surprised:
        _openMouth(canvas);
      case ZakiMood.sad:
        _frown(canvas);
      case ZakiMood.thinking:
        _straight(canvas);
      case ZakiMood.proud:
        _smirk(canvas);
      default:
        _gentleSmile(canvas);
    }
  }

  void _gentleSmile(Canvas canvas) => canvas.drawPath(
    Path()..moveTo(78, 106)..quadraticBezierTo(90, 117, 102, 106),
    _stroke(const Color(0xFF00CCFF), 4),
  );

  void _bigSmile(Canvas canvas) => canvas.drawPath(
    Path()..moveTo(73, 104)..quadraticBezierTo(90, 120, 107, 104),
    _stroke(const Color(0xFF00CCFF), 4.5),
  );

  void _openMouth(Canvas canvas) {
    canvas.drawPath(
      Path()..moveTo(76, 104)..quadraticBezierTo(90, 118, 104, 104),
      _stroke(const Color(0xFF00CCFF), 4),
    );
    canvas.drawOval(Rect.fromCenter(center: const Offset(90, 108), width: 26, height: 14),
        _fill(const Color(0xFF01091A)));
    canvas.drawOval(Rect.fromCenter(center: const Offset(90, 107), width: 18, height: 8),
        _fill(const Color(0xFF002233), opacity: 0.8));
  }

  void _frown(Canvas canvas) => canvas.drawPath(
    Path()..moveTo(78, 111)..quadraticBezierTo(90, 102, 102, 111),
    _stroke(const Color(0xFF0077BB), 3.5, opacity: 0.8),
  );

  void _straight(Canvas canvas) => canvas.drawLine(
    const Offset(81, 108), const Offset(99, 108),
    _stroke(const Color(0xFF0088AA), 3, opacity: 0.7),
  );

  void _smirk(Canvas canvas) => canvas.drawPath(
    Path()..moveTo(82, 108)..quadraticBezierTo(95, 114, 104, 107),
    _stroke(const Color(0xFF00CCFF), 3.5),
  );

  // ── Antenna ───────────────────────────────────────────────────────────────
  void _drawAntenna(Canvas canvas) {
    canvas.drawLine(const Offset(90, 18), const Offset(90, 34),
        _stroke(const Color(0xFF90A4AE), 3.5));
    canvas.drawCircle(const Offset(90, 34), 5.5, _fill(const Color(0xFF78909C)));
    canvas.drawCircle(const Offset(90, 34), 3.5, _fill(const Color(0xFF90A4AE)));
    canvas.drawCircle(const Offset(90, 12), 10,
        _fill(const Color(0xFF26C6DA), opacity: antennaOpacity));
    canvas.drawCircle(const Offset(90, 12), 7, _fill(const Color(0xFF4DD0E1)));
    canvas.drawCircle(const Offset(86, 8), 3.5, _fill(Colors.white, opacity: 0.5));
  }

  @override
  bool shouldRepaint(_ZakiPainter old) =>
      old.mood != mood ||
      old.waveAngle != waveAngle ||
      old.antennaOpacity != antennaOpacity ||
      old.thrusterScale != thrusterScale ||
      old.eyeGlowOpacity != eyeGlowOpacity;
}
