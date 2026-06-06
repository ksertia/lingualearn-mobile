import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const Color _kGreen  = Color(0xFF188329);
const Color _kOrange = Color(0xFFF27F22);
const Color _kYellow = Color(0xFFFFC107);

// ── Texte ─────────────────────────────────────────────────────────────────────
const String _bubbleText =
    "Salut 👋 moi c'est TiBi !\nPrêt à découvrir les langues du Faso ?";

const String _ttsText =
    "Salut ! Moi c'est TiBi, "
    "ta mascotte. Prêt à découvrir les langues du Faso ?";

// ─────────────────────────────────────────────────────────────────────────────

class StepMascotte extends StatefulWidget {
  const StepMascotte({super.key});

  @override
  State<StepMascotte> createState() => _StepMascotteState();
}

class _StepMascotteState extends State<StepMascotte>
    with TickerProviderStateMixin {

  // ── TTS ────────────────────────────────────────────────────────────────────
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _textDone   = false;

  // ── Animations d'entrée ────────────────────────────────────────────────────
  late final AnimationController _logoCtrl;
  late final Animation<double>   _logoScale;
  late final Animation<double>   _logoFade;

  late final AnimationController _bubbleCtrl;
  late final Animation<double>   _bubbleFade;
  late final Animation<Offset>   _bubbleSlide;

  late final AnimationController _mascotCtrl;
  late final Animation<double>   _mascotScale;
  late final Animation<double>   _mascotFade;

  // ── Animations en boucle ───────────────────────────────────────────────────
  late final AnimationController _floatCtrl;   // mascotte flotte
  late final Animation<double>   _float;

  late final AnimationController _glowCtrl;    // halo mascotte
  late final Animation<double>   _glow;

  late final AnimationController _pulseCtrl;   // bouton pulse
  late final Animation<double>   _pulse;

  // ── Bouton ─────────────────────────────────────────────────────────────────
  late final AnimationController _btnCtrl;
  late final Animation<double>   _btnScale;
  late final Animation<double>   _btnFade;

  @override
  void initState() {
    super.initState();

    // ── Logo : scale élastique ──────────────────────────────────────────────
    _logoCtrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 700));
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl,
            curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));

    // ── Bulle : slide depuis le haut ────────────────────────────────────────
    _bubbleCtrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 520));
    _bubbleFade  = CurvedAnimation(parent: _bubbleCtrl, curve: Curves.easeIn);
    _bubbleSlide = Tween<Offset>(
            begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bubbleCtrl,
            curve: Curves.easeOutCubic));

    // ── Mascotte : pop depuis le bas ────────────────────────────────────────
    _mascotCtrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 650));
    _mascotScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _mascotCtrl, curve: Curves.elasticOut));
    _mascotFade  = CurvedAnimation(parent: _mascotCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn));

    // ── Float mascotte (monte/descend) ──────────────────────────────────────
    _floatCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _float     = Tween<double>(begin: 0.0, end: 8.0).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // ── Halo/glow (respire) ─────────────────────────────────────────────────
    _glowCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    _glow     = Tween<double>(begin: 0.12, end: 0.28).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    // ── Pulse bouton ────────────────────────────────────────────────────────
    _pulseCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _pulse     = Tween<double>(begin: 1.0, end: 1.04).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // ── Bouton apparaît après typewriter ────────────────────────────────────
    _btnCtrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 500));
    _btnScale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _btnCtrl, curve: Curves.elasticOut));
    _btnFade  = CurvedAnimation(parent: _btnCtrl, curve: Curves.easeIn);

    // ── Init TTS en avance (pendant les animations d'entrée) ─────────────────
    _initTts();

    // ── Séquence d'entrée ────────────────────────────────────────────────────
    _logoCtrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) {
          _bubbleCtrl.forward();
          _speak(); // audio démarre exactement avec le typewriter
        }
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _mascotCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _tts.stop();
    for (final c in [_logoCtrl, _bubbleCtrl, _mascotCtrl,
        _floatCtrl, _glowCtrl, _pulseCtrl, _btnCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── TTS ────────────────────────────────────────────────────────────────────

  Future<void> _initTts() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.08);
    _tts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _tts.setCancelHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speak() async {
    await _tts.stop();
    await _tts.speak(_ttsText);
  }

  Future<void> _toggleAudio() async {
    _isSpeaking ? await _tts.stop() : await _speak();
  }

  void _onTypewriterDone() {
    if (!_textDone) {
      setState(() => _textDone = true);
      _btnCtrl.forward();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Fond image ────────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/app/plan4.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // ── Dégradé bas pour lisibilité bouton ────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: size.height * 0.28,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x88FFFFFF)],
                ),
              ),
            ),
          ),

          // ── Contenu ───────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildBackBtn(),
                      const Spacer(),
                      _buildAudioBtn(),
                    ],
                  ),
                ),

                // ── Logo animé ────────────────────────────────────────
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Image.asset(
                      'assets/images/app/logo.png',
                      height: 100,
                      errorBuilder: (_, __, ___) =>
                          const SizedBox(height: 100),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Bulle + Mascotte groupées (impression de parole) ──
                FadeTransition(
                  opacity: _bubbleFade,
                  child: SlideTransition(
                    position: _bubbleSlide,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSpeechBubble(),
                    ),
                  ),
                ),

                // Espace minimal entre bulle et mascotte (le triangle fait le lien)
                const SizedBox(height: 2),

                // ── Mascotte flottante ────────────────────────────────
                ScaleTransition(
                  scale: _mascotScale,
                  child: FadeTransition(
                    opacity: _mascotFade,
                    child: _buildMascot(size),
                  ),
                ),

                const Spacer(),

                // ── Bouton ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: _buildActionButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Back button ────────────────────────────────────────────────────────────

  Widget _buildBackBtn() {
    return Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.black87, size: 18),
        onPressed: () { _tts.stop(); Get.offAllNamed('/splash'); },
        padding: EdgeInsets.zero,
      ),
    );
  }

  // ── Audio button ───────────────────────────────────────────────────────────

  Widget _buildAudioBtn() {
    return GestureDetector(
      onTap: _toggleAudio,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: _isSpeaking
              ? _kGreen.withValues(alpha: 0.90)
              : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _isSpeaking
                  ? _kGreen.withValues(alpha: 0.40)
                  : Colors.black.withValues(alpha: 0.12),
              blurRadius: _isSpeaking ? 14 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _isSpeaking ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          color: _isSpeaking ? Colors.white : Colors.black54,
          size: 20,
        ),
      ),
    );
  }

  // ── Speech bubble ──────────────────────────────────────────────────────────

  Widget _buildSpeechBubble() {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // Ombre colorée derrière la bulle
        Positioned(
          left: 6, right: -6, top: 6, bottom: -6,
          child: Container(
            decoration: BoxDecoration(
              color: _kYellow.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),

        // Container principal
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _kYellow, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: _kYellow.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicateur audio en cours
              if (_isSpeaking)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      _AudioDots(color: _kGreen),
                      const SizedBox(width: 6),
                      Text('TiBi parle…',
                          style: TextStyle(
                              fontSize: 10,
                              color: _kGreen,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),

              // Texte typewriter
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    _bubbleText,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2D2D),
                      height: 1.55,
                    ),
                    speed: const Duration(milliseconds: 42),
                    cursor: '▌',
                  ),
                ],
                totalRepeatCount: 1,
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
                onFinished: _onTypewriterDone,
              ),
            ],
          ),
        ),

        // Triangle pointeur
        Positioned(
          bottom: -13,
          child: Transform.rotate(
            angle: 45 * 3.14159 / 180,
            child: Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  right: BorderSide(color: _kYellow, width: 2.5),
                  bottom: BorderSide(color: _kYellow, width: 2.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Mascotte avec halo et float ────────────────────────────────────────────

  Widget _buildMascot(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_float, _glow]),
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, -_float.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Halo lumineux respirant
              Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _kOrange.withValues(alpha: _glow.value),
                    Colors.transparent,
                  ]),
                ),
              ),
              // Ombre au sol (ellipse)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 110, height: 14,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                        alpha: 0.06 + (_float.value / 8) * 0.04),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              // Lottie
              Lottie.asset(
                'assets/lottie/Happy mascot.json',
                width: size.height * 0.26,
                height: size.height * 0.26,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                    Icons.emoji_emotions_rounded,
                    size: 110, color: _kOrange),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Bouton action ──────────────────────────────────────────────────────────

  Widget _buildActionButton() {
    return ScaleTransition(
      scale: _btnScale,
      child: FadeTransition(
        opacity: _btnFade,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) => Transform.scale(
            scale: _textDone ? _pulse.value : 1.0,
            child: child,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 58,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8F00), Color(0xFFFF6B00)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _kOrange.withValues(alpha: 0.42),
                    blurRadius: 22,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  _tts.stop();
                  Get.toNamed('/laguedecouvert');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "C'EST PARTI !",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.rocket_launch_rounded,
                        color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Points audio animés ────────────────────────────────────────────────────────

class _AudioDots extends StatefulWidget {
  final Color color;
  const _AudioDots({required this.color});

  @override
  State<_AudioDots> createState() => _AudioDotsState();
}

class _AudioDotsState extends State<_AudioDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final phase = (_ctrl.value + i * 0.33) % 1.0;
          final h = 3.0 +
              8.0 * (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: Container(
              width: 3, height: h,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
