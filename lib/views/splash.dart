import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/models/user_model.dart'; // Assure-toi que l'import est correct
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  // --- LOGIQUE DE REDIRECTION SYNCHRONISÉE ---
  void _checkStatus() async {
    // Petit délai pour laisser le temps à l'UI de s'initialiser
    await Future.delayed(const Duration(milliseconds: 800));

    String? token = LocalStorage.getAuthToken();

    // 1. Si pas de token, on affiche l'onboarding
    if (token == null || token.isEmpty || token == "null") {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final session = Get.find<SessionController>();

      // 2. On récupère le profil complet depuis le backend
      // On utilise l'instance Dio du SessionController qui a déjà le Token
      final response = await session.dio.get('/users/me');

      if (response.statusCode == 200) {
        // On utilise notre factory UserModel.fromJson qui analyse langue et niveau
        final fullUser = UserModel.fromJson(response.data['data']);
        
        // Mise à jour de la session globale avec les données fraîches
        session.updateUser(fullUser, token);

        // 3. AIGUILLAGE AUTOMATIQUE (Identique au LoginController)
        if (fullUser.selectedLanguageId == null) {
          print("➡️ Splash : Direction Bienvenue");
          Get.offAllNamed('/bienvenue');
        } 
        else if (fullUser.selectedLevelId == null) {
          print("➡️ Splash : Direction Sélection du niveau");
          Get.offAllNamed('/selection');
        } 
        else {
          print("✅ Splash : Direction Accueil");
          Get.offAllNamed('/HomeScreen');
        }
      } else {
        // Token expiré ou invalide
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("🚨 Erreur Splash (API me) : $e");
      // En cas d'erreur réseau, on affiche l'onboarding par défaut
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/images/app/splash1.jpg",
      "title": "Bienvenue sur LinguaLearn",
      "subtitle": "L'application pour maîtriser nos langues locales facilement.",
    },
    {
      "image": "assets/images/app/splash2.jpg",
      "title": "Apprenez partout",
      "subtitle": "Accédez à des cours interactifs et progressez à votre rythme.",
    },
    {
      "image": "assets/images/app/splash3.jpg",
      "title": "Prêt à commencer ?",
      "subtitle": "Rejoignez la communauté et préservez notre patrimoine linguistique.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Écran de chargement pendant la vérification API (Splash technique)
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 255, 127, 0),
          ),
        ),
      );
    }

    final session = Get.find<SessionController>();

    // Affichage de l'Onboarding (Splash visuel) si non connecté
    return Scaffold(
      body: Stack(
        children: [
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_currentPage == _pages.length - 1) ...[
                  Image.asset("assets/images/logo/login.png", height: 150),
                  const SizedBox(height: 10),
                ],
                Text(
                  _pages[_currentPage]["title"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  _pages[_currentPage]["subtitle"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),
                if (_currentPage == _pages.length - 1) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 127, 0),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        session.vientDeLaDecouverte = true;
                        Get.toNamed('/intro');
                      },
                      child: const Text("Découvrir"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        session.vientDeLaDecouverte = false;
                        Get.toNamed('/register');
                      },
                      child: const Text("S'inscrire"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                      ),
                      onPressed: () {
                        session.vientDeLaDecouverte = false;
                        Get.toNamed('/login');
                      },
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildDot(index),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
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