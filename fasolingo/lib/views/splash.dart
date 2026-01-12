import 'package:fasolingo/route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashCree extends StatefulWidget {
  const SplashCree({super.key});

  @override
  State<SplashCree> createState() => _SplashCreeState();
}

class _SplashCreeState extends State<SplashCree> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Données de ton Onboarding Fasolingo
  final List<Map<String, String>> _pages = [
    {
      "image": "assets/app/images/splash1.jpg",
      "title": "Bienvenue sur Fasolingo",
      "subtitle": "L'application pour maîtriser nos langues locales facilement.",
    },
    {
      "image": "assets/app/images/splash2.jpg",
      "title": "Apprenez partout",
      "subtitle": "Accédez à des cours interactifs et progressez à votre rythme.",
    },
    {
      "image": "assets/app/images/splash3.jpg",
      "title": "Prêt à commencer ?",
      "subtitle": "Rejoignez la communauté et préservez notre patrimoine linguistique.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Fond d'écran (Images)
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.blueGrey), 
                   Image.asset(_pages[index]["image"]!, fit: BoxFit.cover),

                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // 2. Texte et Boutons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                if (_currentPage == _pages.length - 1) ...[
    Image.asset(
      "assets/app/logo/logos1.png", 
      height: 350,
    ),
    const SizedBox(height: 10),
  ],
                Text(
                  _pages[_currentPage]["title"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  _pages[_currentPage]["subtitle"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),

                if (_currentPage == _pages.length - 1) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                      onPressed: () => Get.toNamed(AppRoutes.register),
                      child: const Text("S'inscrire"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
                      onPressed: () => Get.toNamed(AppRoutes.login),
                      child: const Text("Se connecter", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
                
                const SizedBox(height: 30),

                // Indicateurs (Dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) => _buildDot(index)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      height: 8,
      width: _currentPage == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}