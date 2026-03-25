import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class BienvenuPage extends StatefulWidget {
  const BienvenuPage({super.key});

  @override
  State<BienvenuPage> createState() => _BienvenuPageState();
}

class _BienvenuPageState extends State<BienvenuPage>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _floatController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Animation de rebond pour la mascotte
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Animation flottante pour les decorations
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- ARRIÈRE-PLAN DÉGRADÉ AMUSANT ---
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF87CEEB).withOpacity(0.6), 
                  const Color(0xFFFFB6C1).withOpacity(0.6), 
                  const Color(0xFFFFD700).withOpacity(0.5),
                  const Color(0xFFFFA500).withOpacity(0.6), 
                ],
              ),
            ),
          ),

          // --- DÉCORATIONS FLOTTANTES ---
          ...List.generate(8, (index) => _buildFloatingDecoration(index)),

          // --- CONTENU PRINCIPAL ---
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // --- TITRE AMUSANT ---
                    _buildTitle(),

                    const SizedBox(height: 20),

                    // --- MASCOTTE HEUREUSE AVEC ANIMATION ---
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_bounceAnimation.value),
                          child: child,
                        );
                      },
                      child: _buildMascotte(),
                    ),

                    const SizedBox(height: 10),

                    // --- CARTE DE BIENVENUE AMÉLIORÉE ---
                    _buildWelcomeCard(),

                    const SizedBox(height: 20),

                    // --- BOUTON D'ACTION AMÉLIORÉ ---
                    _buildActionButton(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingDecoration(int index) {
    final random = Random(index);
    final size = random.nextDouble() * 30 + 15;
    final left = random.nextDouble() * MediaQuery.of(context).size.width;
    final delay = random.nextDouble() * 1000;

    final shapes = [
      Icons.star,
      Icons.circle,
      Icons.favorite,
      Icons.auto_awesome,
    ];

    final colors = [
      Colors.yellow.shade600,
      Colors.white.withOpacity(0.8),
      Colors.pink.shade300,
      Colors.orange.shade300,
      Colors.blue.shade300,
      Colors.purple.shade200,
    ];

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Positioned(
          left: left,
          top: (index * 60.0 + _floatAnimation.value + delay) % MediaQuery.of(context).size.height - 30,
          child: Opacity(
            opacity: 0.6,
            child: Transform.rotate(
              angle: random.nextDouble() * pi,
              child: Icon(
                shapes[index % shapes.length],
                size: size,
                color: colors[index % colors.length],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Étoiles décoratives
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.yellow.shade600, size: 24),
            const SizedBox(width: 8),
            Icon(Icons.star, color: Colors.orange.shade400, size: 32),
            const SizedBox(width: 8),
            Icon(Icons.star, color: Colors.yellow.shade600, size: 24),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "LINGUALEARN 🌟",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.orange.shade300,
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Apprends en t'amusant !",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildMascotte() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Lottie.asset(
        'assets/lottie/Happy mascot.json',
        width: 180,
        height: 180,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.emoji_emotions,
            size: 100,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.orange.shade200,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF2D3436),
                height: 1.5,
              ),
              children: [
                const TextSpan(text: "Bienvenue sur "),
                TextSpan(
                  text: "LinguaLearn\n",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.orange.shade800,
                    fontSize: 24,
                  ),
                ),
                const TextSpan(
                  text: "Découvre les langues\nde nos racines ! 🌍\n\n",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: "Choisis tes langues préférées",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const TextSpan(text: " ✨"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.05),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      onEnd: () {
        
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Get.toNamed('/selection'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF8F00),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 65),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(
                color: Colors.orange.shade200,
                width: 2,
              ),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "COMMENCER",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

