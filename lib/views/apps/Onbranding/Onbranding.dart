import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingTibiPro extends StatefulWidget {
  const OnboardingTibiPro({super.key});

  @override
  State<OnboardingTibiPro> createState() => _OnboardingTibiProState();
}

class _OnboardingTibiProState extends State<OnboardingTibiPro> {
  final PageController _pageController = PageController();
  int _currentPage = 0;


  final Color tibiOrange = const Color(0xFFFF7F00);
  final Color tibiCyan = const Color(0xFF00CED1);
  final Color scaffoldBg = const Color(0xFF0A120F);
  final Color cardBg = const Color(0xFF13221C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [

          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [tibiOrange.withOpacity(0.08), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      _buildCircleBtn(Icons.arrow_back),
                      const Spacer(),
                      _buildSegmentedProgress(),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // Pages d'Onboarding
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      _buildActivityStep(),
                      _buildTopicStep(),
                      _buildGoalStep(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ÉTAPE 1
  Widget _buildActivityStep() {
    return _StepLayout(
      title: "À quel point es-tu exposé à la langue ?",
      child: Column(
        children: [
          _buildSelectableTile("Rarement", "Je ne l'entends jamais", Icons.visibility_off, false),
          _buildSelectableTile("Parfois", "Je l'entends lors de fêtes", Icons.celebration, false),
          _buildSelectableTile("Souvent", "Ma famille la parle à la maison", Icons.home, true),
          _buildSelectableTile("Quotidiennement", "C'est ma langue principale", Icons.forum, false),
        ],
      ),
    );
  }

  // ÉTAPE 2
  Widget _buildTopicStep() {
    return _StepLayout(
      title: "Que veux-tu apprendre en priorité ?",
      child: Column(
        children: [
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 25,
            children: [
              _buildTopicCard("Salutations", Icons.handshake, false, rotation: -0.06),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: _buildTopicCard("Famille", Icons.people, true, rotation: 0.12),
              ),
              _buildTopicCard("Commerce", Icons.shopping_cart, false, rotation: 0.05),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: _buildTopicCard("Contes", Icons.menu_book, false, rotation: -0.10),
              ),
              _buildTopicCard("Culture", Icons.account_balance, false, rotation: 0.04),
            ],
          ),
        ],
      ),
    );
  }

  //  ÉTAPE 3
  Widget _buildGoalStep() {
    final session = Get.find<SessionController>();

    return _StepLayout(
      title: "Reste concentré, et gagne ton défi.",

      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72, // Ajuste la zone pour pousser le spacer
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: tibiOrange,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Row(
                children: [
                  Icon(Icons.flag, size: 40, color: Colors.black),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "À ce rythme, tu maîtriseras les bases dans 21 jours !",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildProgressCircle(),
            const SizedBox(height: 30),
            _buildStatLine("Vocabulaire", 0.7, tibiCyan, "150 mots"),
            _buildStatLine("Prononciation", 0.4, tibiOrange, "40%"),

            //  espace dynamique
            const Spacer(),

            // les boutons
            _buildPrimaryButton("C’EST PARTI", () {
              session.vientDeLaDecouverte = true;
              Get.toNamed('/step');
            }, true),
            const SizedBox(height: 12),
            _buildPrimaryButton("J’AI DÉJÀ UN COMPTE", () {
              session.vientDeLaDecouverte = false;
              Get.toNamed('/login');
            }, false),


            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  // Widget S

  Widget _buildTopicCard(String l, IconData i, bool sel, {double rotation = 0}) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 145,
        height: 145,
        decoration: BoxDecoration(
          color: sel ? tibiOrange : cardBg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: sel ? [BoxShadow(color: tibiOrange.withOpacity(0.3), blurRadius: 20)] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, size: 35, color: sel ? Colors.black : Colors.white70),
            const SizedBox(height: 12),
            Text(l, style: TextStyle(color: sel ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPress, bool isFull) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: isFull
          ? ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: tibiOrange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      )
          : OutlinedButton(
        onPressed: onPress,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: tibiOrange, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(text, style: TextStyle(color: tibiOrange, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white10),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildSegmentedProgress() {
    return Row(
      children: List.generate(10, (index) {
        bool isCurrent = index == (_currentPage * 3 + 1);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 4,
          width: isCurrent ? 25 : 6,
          decoration: BoxDecoration(
            color: isCurrent ? tibiOrange : Colors.white12,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildSelectableTile(String t, String s, IconData i, bool sel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: sel ? tibiOrange : cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(i, color: sel ? Colors.black : tibiOrange),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t, style: TextStyle(color: sel ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
              Text(s, style: TextStyle(color: sel ? Colors.black54 : Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: CircularProgressIndicator(
            value: 0.65,
            strokeWidth: 10,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(tibiCyan),
          ),
        ),
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("65%", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Prêt", style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatLine(String label, double val, Color color, String trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
              Text(trailing, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: val, color: color, backgroundColor: Colors.white10, minHeight: 6),
        ],
      ),
    );
  }
}

class _StepLayout extends StatelessWidget {
  final String title;
  final Widget child;
  const _StepLayout({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          child,
        ],
      ),
    );
  }
}