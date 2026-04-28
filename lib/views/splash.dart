import 'dart:async';

import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _orange = Color(0xFFFF6B35);
const Color _orangeLight = Color(0xFFFFB347);
const Color _bg = Color(0xFFFFF9F6);

class SplashCree extends StatefulWidget {
  const SplashCree({super.key});

  @override
  State<SplashCree> createState() => _SplashCreeState();
}

class _SplashCreeState extends State<SplashCree> with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _taglineCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _ringsCtrl;
  late final AnimationController _btnsCtrl;
  late final AnimationController _exitCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _pulse;
  late final Animation<double> _ringsAnim;
  late final Animation<double> _btnsOpacity;
  late final Animation<Offset> _btnsSlide;
  late final Animation<double> _exitOpacity;
  late final Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _logoCtrl.forward().then((_) {
      if (mounted) {
        _taglineCtrl.forward();
        _btnsCtrl.forward();
        _pulseCtrl.repeat(reverse: true);
        _ringsCtrl.repeat(reverse: true);
      }
    });
    _checkStatus();
  }

  void _setupAnimations() {
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _logoScale = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _taglineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeIn),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _ringsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _ringsAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringsCtrl, curve: Curves.easeInOut),
    );

    _btnsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _btnsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _btnsCtrl, curve: Curves.easeIn),
    );
    _btnsSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _btnsCtrl, curve: Curves.easeOut));

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );
    _exitScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _taglineCtrl.dispose();
    _pulseCtrl.dispose();
    _ringsCtrl.dispose();
    _btnsCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final String? storedToken = LocalStorage.getAuthToken();
    if (storedToken == null || storedToken.isEmpty || storedToken == 'null') return;

    try {
      final session = Get.find<SessionController>();
      session.token.value = storedToken;

      final response = await session.dio.get('/users/me');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final UserModel user = UserModel.fromJson(response.data['data']);
        session.updateUser(user, storedToken);

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
    } catch (e) {
      debugPrint('Erreur Splash : $e');
    }
  }

  Future<void> _goTo(String route) async {
    await _exitCtrl.forward();
    if (mounted) Get.offAllNamed(route);
  }

  Future<void> _open(String route) async {
    await _exitCtrl.forward();
    if (mounted) Get.toNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Blobs décoratifs de fond
          Positioned(
            top: -70,
            right: -70,
            child: _blob(220, _orange.withValues(alpha: 0.06)),
          ),
          Positioned(
            bottom: 80,
            left: -90,
            child: _blob(260, _orangeLight.withValues(alpha: 0.07)),
          ),
          Positioned(
            top: size.height * 0.42,
            right: -40,
            child: _blob(130, _orange.withValues(alpha: 0.04)),
          ),

          // ── Contenu
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Zone logo avec anneaux
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildPulsingRings(),
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, child) =>
                              Transform.scale(scale: _pulse.value, child: child),
                          child: Container(
                            width: 130,
                            height: 130,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _orange.withValues(alpha: 0.22),
                                  blurRadius: 45,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo/login.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Nom + tagline
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: SlideTransition(
                    position: _taglineSlide,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [_orange, _orangeLight],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds),
                          child: const Text(
                            'Maîtrisez nos langues locales',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Boutons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: FadeTransition(
                    opacity: _btnsOpacity,
                    child: SlideTransition(
                      position: _btnsSlide,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _primaryBtn("C'est parti !", () {
                            session.vientDeLaDecouverte = true;
                            Get.toNamed('/step');
                          }),
                          const SizedBox(height: 14),
                          _secondaryBtn("J'ai déjà un compte", () {
                            session.vientDeLaDecouverte = false;
                            Get.toNamed('/login');
                          }),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Mention légale
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      "En continuant, vous acceptez nos conditions d'utilisation",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _buildPulsingRings() {
    return AnimatedBuilder(
      animation: _ringsAnim,
      builder: (_, __) {
        final t = _ringsAnim.value;
        return SizedBox(
          width: 230,
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Anneau externe
              Opacity(
                opacity: (0.07 + t * 0.05).clamp(0.0, 1.0),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _orange.withValues(alpha: 0.25), width: 1),
                  ),
                ),
              ),
              // Anneau intermédiaire
              Opacity(
                opacity: (0.10 + t * 0.07).clamp(0.0, 1.0),
                child: Container(
                  width: 178,
                  height: 178,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _orange.withValues(alpha: 0.35), width: 1.5),
                  ),
                ),
              ),
              // Halo radial derrière le logo
              Container(
                width: 158,
                height: 158,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _orange.withValues(alpha: 0.10 + t * 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _primaryBtn(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_orange, _orangeLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _orange.withValues(alpha: 0.38),
              blurRadius: 22,
              spreadRadius: -3,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryBtn(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: _orange,
          side: BorderSide(color: _orange.withValues(alpha: 0.45), width: 1.5),
          backgroundColor: _orange.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: _orange,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
