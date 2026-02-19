import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/models/user_model.dart'; 
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

void _checkStatus() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    String? storedToken = LocalStorage.getAuthToken();

    if (storedToken == null || storedToken.isEmpty || storedToken == "null") {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final session = Get.find<SessionController>();
      
      // ✅ CORRECTION ICI : On utilise .value car c'est un RxString
      session.token.value = storedToken; 

      final response = await session.dio.get('/users/me');

      if (response.statusCode == 200 && response.data['success'] == true) {
        UserModel loggedInUser = UserModel.fromJson(response.data['data']);
        
        // Mise à jour globale (userId, token, selectedLanguageId, etc.)
        session.updateUser(loggedInUser, storedToken);

        print("🔍 Splash : Analyse de l'état...");

        // On utilise directement les valeurs du modèle reçu
        if (loggedInUser.selectedLanguageId != null && 
            loggedInUser.selectedLanguageId!.isNotEmpty &&
            loggedInUser.selectedLevelId != null && 
            loggedInUser.selectedLevelId!.isNotEmpty) {
          
          Get.offAllNamed('/HomeScreen');
        } 
        else if (loggedInUser.selectedLanguageId != null && 
                 loggedInUser.selectedLanguageId!.isNotEmpty) {
          
          Get.offAllNamed('/selection');
        } 
        else {
          Get.offAllNamed('/bienvenue');
        }

      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("🚨 Erreur Splash : $e");
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
    // Écran de chargement pendant la vérification du token et du profil
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

    // Design de l'Onboarding si l'utilisateur n'est pas connecté
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
                  _buildButton("Découvrir", const Color.fromARGB(255, 255, 127, 0), Colors.white, () {
                    session.vientDeLaDecouverte = true;
                    Get.toNamed('/intro');
                  }),
                  const SizedBox(height: 8),
                  _buildButton("S'inscrire", Colors.white, Colors.black, () {
                    session.vientDeLaDecouverte = false;
                    Get.toNamed('/register');
                  }),
                  const SizedBox(height: 8),
                  _buildOutlinedButton("Se connecter", () {
                    session.vientDeLaDecouverte = false;
                    Get.toNamed('/login');
                  }),
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

  // --- Helpers de Widgets ---

  Widget _buildButton(String text, Color bg, Color fg, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: fg),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  Widget _buildOutlinedButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white)),
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