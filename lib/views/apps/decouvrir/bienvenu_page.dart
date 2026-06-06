import 'package:fasolingo/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const Color _kGreen     = Color(0xFF188329);
const Color _kGreenDark = Color(0xFF0F5C1C);
const Color _kYellow    = Color(0xFFF5BF1E);
const Color _kOrange    = Color(0xFFF27F22);

// ─────────────────────────────────────────────────────────────────────────────

class BienvenuPage extends StatefulWidget {
  const BienvenuPage({super.key});

  @override
  State<BienvenuPage> createState() => _BienvenuPageState();
}

class _BienvenuPageState extends State<BienvenuPage>
    with TickerProviderStateMixin {

  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _enterCtrl;
  late final AnimationController _mascotCtrl;
  late final AnimationController _staggerCtrl;

  late final Animation<double> _headerFade;
  late final Animation<Offset>  _headerSlide;
  late final Animation<double> _mascotFade;
  late final Animation<double> _mascotBounce;
  late final Animation<double> _cardFade;
  late final Animation<Offset>  _cardSlide;
  late final Animation<double> _btnFade;
  late final Animation<Offset>  _btnSlide;

  @override
  void initState() {
    super.initState();

    // Entrée principale (header + card + btn en séquence)
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));

    _headerFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)));

    _mascotFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.2, 0.6, curve: Curves.easeIn)));

    _cardFade    = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.4, 0.8, curve: Curves.easeIn)));
    _cardSlide   = Tween<Offset>(
            begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.4, 0.85, curve: Curves.easeOutCubic)));

    _btnFade     = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.6, 1.0, curve: Curves.easeIn)));
    _btnSlide    = Tween<Offset>(
            begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic)));

    // Bounce mascotte (lent, doux)
    _mascotCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _mascotBounce = Tween<double>(begin: 0.0, end: 10.0).animate(
        CurvedAnimation(parent: _mascotCtrl, curve: Curves.easeInOut));

    // Lancement
    _staggerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _mascotCtrl.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7), // très léger vert-blanc
      body: Stack(
        children: [
          // ── Fond décoratif ──────────────────────────────────────────────
          _Background(size: size),

          // ── Contenu ─────────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                24, 16, 24,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                children: [
                  // ── Badge + titre haut ────────────────────────────────
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                        position: _headerSlide,
                        child: _buildTopSection(context)),
                  ),

                  const SizedBox(height: 8),

                  // ── Mascotte ──────────────────────────────────────────
                  FadeTransition(
                    opacity: _mascotFade,
                    child: AnimatedBuilder(
                      animation: _mascotBounce,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, -_mascotBounce.value),
                        child: child,
                      ),
                      child: _buildMascot(),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ── Card bienvenue ────────────────────────────────────
                  FadeTransition(
                    opacity: _cardFade,
                    child: SlideTransition(
                        position: _cardSlide,
                        child: _buildWelcomeCard(context)),
                  ),

                  const SizedBox(height: 28),

                  // ── Boutons ───────────────────────────────────────────
                  FadeTransition(
                    opacity: _btnFade,
                    child: SlideTransition(
                        position: _btnSlide,
                        child: _buildButtons(context)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top section ────────────────────────────────────────────────────────────

  Widget _buildTopSection(BuildContext context) {
    return Column(
      children: [
        // Badge vert
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _kGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: _kGreen.withValues(alpha: 0.25), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                    color: _kGreen, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              const Text(
                'Bienvenue sur TiBi !',
                style: TextStyle(
                  color: _kGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Titre principal
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
              letterSpacing: -0.8,
              height: 1.2,
            ),
            children: const [
              TextSpan(text: 'Découvrez les langues\n'),
              TextSpan(
                text: 'de vos racines',
                style: TextStyle(color: _kGreen),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Apprenez à votre rythme, où que vous soyez.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Mascotte ───────────────────────────────────────────────────────────────

  Widget _buildMascot() {
    return Container(
      width: 200, height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          _kGreen.withValues(alpha: 0.10),
          Colors.transparent,
        ]),
      ),
      child: Lottie.asset(
        'assets/lottie/Happy mascot.json',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          width: 160, height: 160,
          decoration: BoxDecoration(
            color: _kGreen.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.emoji_emotions_rounded,
              size: 80, color: _kGreen),
        ),
      ),
    );
  }

  // ── Welcome card ───────────────────────────────────────────────────────────

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section titre card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kGreen, _kGreenDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.language_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apprends en t\'amusant',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Choisis tes langues préférées',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Séparateur
          Container(height: 1, color: AppColors.divider(context)),
          const SizedBox(height: 18),

          // 3 features
          Row(
            children: [
              _feature(context, icon: Icons.speed_rounded,
                  label: 'À ton rythme', color: _kGreen),
              _feature(context, icon: Icons.headphones_rounded,
                  label: 'Audio inclus', color: _kOrange),
              _feature(context, icon: Icons.emoji_events_rounded,
                  label: 'Progressif', color: _kYellow,
                  textColor: const Color(0xFF8B6B00)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feature(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    Color? textColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  // ── Buttons ────────────────────────────────────────────────────────────────

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // Bouton principal vert
        SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kGreen, _kGreenDark],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _kGreen.withValues(alpha: 0.32),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Get.toNamed('/selection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Commencer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Fond décoratif ────────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  final Size size;
  const _Background({required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glow vert haut-droite
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _kGreen.withValues(alpha: 0.09),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        // Glow jaune/orange bas-gauche
        Positioned(
          bottom: -80,
          left: -80,
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _kOrange.withValues(alpha: 0.07),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        // Petit glow vert milieu-gauche
        Positioned(
          top: size.height * 0.45,
          left: -20,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _kGreen.withValues(alpha: 0.07),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    );
  }
}
