import 'package:tibi/controller/apps/session_controller.dart';
import 'package:tibi/helpers/storage/local_storage.dart';
import 'package:tibi/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Palette ────────────────────────────────────────────────────────────────────
const Color _bg      = Color(0xFFFFF6F1); 
const Color _orange  = Color(0xFFF27F22);
const Color _orange2 = Color(0xFFFFB347);
const Color _green   = Color(0xFF188329);
const Color _dark    = Color(0xFF1A1A2E);


class SplashCree extends StatefulWidget {
  const SplashCree({super.key});
  @override
  State<SplashCree> createState() => _SplashCreeState();
}

class _SplashCreeState extends State<SplashCree>
    with TickerProviderStateMixin {

  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _btnsCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _exitCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset>  _textSlide;
  late final Animation<double> _btnsFade;
  late final Animation<Offset>  _btnsSlide;
  late final Animation<double> _pulse;
  late final Animation<double> _exitOpacity;
  late final Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();
    _build();
    _start();
    _checkStatus();
  }

  void _build() {
    _logoCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900));
    _logoScale = Tween<double>(begin: 0.15, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl,
            curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));

    _textCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 540));
    _textFade  = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textSlide = Tween<Offset>(
            begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _textCtrl, curve: Curves.easeOutCubic));

    _btnsCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 460));
    _btnsFade  = CurvedAnimation(parent: _btnsCtrl, curve: Curves.easeIn);
    _btnsSlide = Tween<Offset>(
            begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _btnsCtrl, curve: Curves.easeOutCubic));

    _pulseCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2400));
    _pulse = Tween<double>(begin: 1.0, end: 1.055).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _exitCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 340));
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
    _exitScale   = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
  }

  void _start() {
    _logoCtrl.forward().then((_) {
      if (!mounted) return;
      _pulseCtrl.repeat(reverse: true);
      _textCtrl.forward();
      Future.delayed(const Duration(milliseconds: 220),
          () { if (mounted) _btnsCtrl.forward(); });
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose(); _textCtrl.dispose(); _btnsCtrl.dispose();
    _pulseCtrl.dispose(); _exitCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  Future<void> _checkStatus() async {
    final token = LocalStorage.getAuthToken();
    if (token == null || token.isEmpty || token == 'null') return;
    try {
      final session = Get.find<SessionController>();
      session.token.value = token;
      final resp = await session.dio.get('/users/me');
      if (resp.statusCode == 200 && resp.data['success'] == true) {
        final user = UserModel.fromJson(resp.data['data']);
        session.updateUser(user, token);
        if (user.selectedLanguageId != null &&
            user.selectedLanguageId!.isNotEmpty &&
            user.selectedLevelId != null &&
            user.selectedLevelId!.isNotEmpty) {
          _goTo('/HomeScreen');
        } else if (user.selectedLanguageId != null &&
            user.selectedLanguageId!.isNotEmpty) {
          _goTo('/selection');
        } else {
          _goTo('/bienvenue');
        }
      }
    } catch (e) { debugPrint('Splash: $e'); }
  }

  Future<void> _goTo(String r) async {
    await _exitCtrl.forward();
    if (mounted) Get.offAllNamed(r);
  }

  Future<void> _open(String r) async {
    await _exitCtrl.forward();
    if (mounted) Get.offAllNamed(r);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionController>();
    final size    = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _exitCtrl,
      builder: (_, child) => Opacity(
        opacity: _exitOpacity.value,
        child: Transform.scale(scale: _exitScale.value, child: child),
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            _Blobs(size: size),

            // ── Contenu ──────────────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo
                    _buildLogo(),

                    const SizedBox(height: 40),

                    // Texte
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                          position: _textSlide,
                          child: _buildText()),
                    ),

                    const Spacer(flex: 3),

                    // Boutons
                    FadeTransition(
                      opacity: _btnsFade,
                      child: SlideTransition(
                        position: _btnsSlide,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Primaire
                            _PrimaryBtn(
                              label: "C'EST PARTI !",
                              onTap: () {
                                session.vientDeLaDecouverte = true;
                                _open('/step');
                              },
                            ),
                            const SizedBox(height: 14),
                            // Secondaire
                            _SecondaryBtn(
                              label: "J'AI DÉJÀ UN COMPTE",
                              onTap: () {
                                session.vientDeLaDecouverte = false;
                                _open('/login');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Mention légale
                    FadeTransition(
                      opacity: _btnsFade,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "En continuant, vous acceptez nos conditions d'utilisation",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Logo ───────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return FadeTransition(
      opacity: _logoFade,
      child: ScaleTransition(
        scale: _logoScale,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) =>
              Transform.scale(scale: _pulse.value, child: child),
          child: Container(
            width: 168, height: 168,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _orange.withValues(alpha: 0.18),
                  blurRadius: 50,
                  spreadRadius: 4,
                  offset: const Offset(0, 12),
                ),
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/logo/login.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.school_rounded,
                  color: _orange, size: 52),
            ),
          ),
        ),
      ),
    );
  }

  // ── Texte ──────────────────────────────────────────────────────────────────

  Widget _buildText() {
    return Column(
      children: [
        // Tagline
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [_orange, _orange],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(b),
          child: const Text(
            'Maîtrisez nos langues locales',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Sous-tagline
        Text(
          'Apprenez à votre rythme, où que vous soyez',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        // Badge Burkina Faso
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 32, height: 1,
                color: _orange.withValues(alpha: 0.18)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _orange.withValues(alpha: 0.25), width: 1),
              ),
              child: const Text(
                'Burkina Faso',
                style: TextStyle(
                  color: _orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 32, height: 1,
                color: _orange.withValues(alpha: 0.18)),
          ],
        ),
      ],
    );
  }
}

// ── Bouton primaire ───────────────────────────────────────────────────────────

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_orange, _orange],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _orange.withValues(alpha: 0.45),
              blurRadius: 24,
              spreadRadius: -2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text(
            "C'EST PARTI !",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bouton secondaire ─────────────────────────────────────────────────────────

class _SecondaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SecondaryBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: _dark,
          side: const BorderSide(color: _orange, width: 1.8),
          backgroundColor: Colors.white.withValues(alpha: 0.60),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

// ── Blobs de fond ─────────────────────────────────────────────────────────────

class _Blobs extends StatelessWidget {
  final Size size;
  const _Blobs({required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grand blob haut-droite (orange)
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _orange2.withValues(alpha: 0.10),
            ),
          ),
        ),
        // Blob vert haut-gauche (accent vert harmonieux)
        Positioned(
          top: -40,
          left: -60,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _green.withValues(alpha: 0.07),
            ),
          ),
        ),
        // Blob milieu-droite petit (orange)
        Positioned(
          top: size.height * 0.40,
          right: -50,
          child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _orange2.withValues(alpha: 0.05),
            ),
          ),
        ),
        // Blob vert bas-droite (contrebalance)
        Positioned(
          bottom: size.height * 0.12,
          right: -30,
          child: Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _green.withValues(alpha: 0.06),
            ),
          ),
        ),
        // Petit blob vert milieu-gauche (nouveau)
        Positioned(
          top: size.height * 0.55,
          left: 20,
          child: Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _green.withValues(alpha: 0.09),
            ),
          ),
        ),
        // Grand blob bas-gauche (orange)
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 320, height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _orange2.withValues(alpha: 0.08),
            ),
          ),
        ),
      ],
    );
  }
}
