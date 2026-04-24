import 'dart:async';

import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _spOrange1 = Color(0xFFFF7043);
const Color _spOrange2 = Color(0xFFFFB74D);

class SplashCree extends StatefulWidget {
  const SplashCree({super.key});

  @override
  State<SplashCree> createState() => _SplashCreeState();
}

class _SplashCreeState extends State<SplashCree> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = true;
  Timer? _autoTimer;

  static const List<Map<String, String>> _pages = [
    {
      "image": "assets/images/app/splash11.png",
      "tag": "Découverte",
      "title": "Bienvenue sur TiBi",
      "subtitle":
          "L'application pour maîtriser nos langues locales facilement.",
    },
    {
      "image": "assets/images/app/splash22.jpeg",
      "tag": "Flexibilité",
      "title": "Apprenez partout",
      "subtitle":
          "Accédez à des cours interactifs et progressez à votre rythme.",
    },
    {
      "image": "assets/images/app/splash33.jpeg",
      "tag": "Communauté",
      "title": "Prêt à commencer ?",
      "subtitle":
          "Rejoignez la communauté et préservez notre patrimoine linguistique.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoTimer() {
    _autoTimer?.cancel();
    if (_currentPage < _pages.length - 1) {
      _autoTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && _currentPage < _pages.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _startAutoTimer();
  }

  Future<void> _checkStatus() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final String? storedToken = LocalStorage.getAuthToken();

    if (storedToken == null || storedToken.isEmpty || storedToken == 'null') {
      if (mounted) {
        setState(() => _isLoading = false);
        _startAutoTimer();
      }
      return;
    }

    try {
      final session = Get.find<SessionController>();
      session.token.value = storedToken;

      final response = await session.dio.get('/users/me');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final UserModel loggedInUser =
            UserModel.fromJson(response.data['data']);
        session.updateUser(loggedInUser, storedToken);

        if (loggedInUser.selectedLanguageId != null &&
            loggedInUser.selectedLanguageId!.isNotEmpty &&
            loggedInUser.selectedLevelId != null &&
            loggedInUser.selectedLevelId!.isNotEmpty) {
          Get.offAllNamed('/HomeScreen');
        } else if (loggedInUser.selectedLanguageId != null &&
            loggedInUser.selectedLanguageId!.isNotEmpty) {
          Get.offAllNamed('/selection');
        } else {
          Get.offAllNamed('/bienvenue');
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          _startAutoTimer();
        }
      }
    } catch (e) {
      debugPrint('Erreur Splash : $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _startAutoTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo/login.png', height: 90),
              const SizedBox(height: 28),
              const CircularProgressIndicator(color: _spOrange1, strokeWidth: 2.5),
            ],
          ),
        ),
      );
    }

    final session = Get.find<SessionController>();

    return Scaffold(
      body: Stack(
        children: [
          // ── Images de fond
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (_, index) => _buildPage(index),
          ),

          // ── Barre supérieure : retour + passer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  AnimatedOpacity(
                    opacity: _currentPage > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: GestureDetector(
                      onTap: _currentPage > 0
                          ? () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              )
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 17),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_currentPage < _pages.length - 1)
                    GestureDetector(
                      onTap: () => _pageController.animateToPage(
                        _pages.length - 1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Passer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Contenu bas de page
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_spOrange1, _spOrange2]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _pages[_currentPage]['tag']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Titre
                    Text(
                      _pages[_currentPage]['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Sous-titre
                    Text(
                      _pages[_currentPage]['subtitle']!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Indicateurs de page
                    Row(
                      children: List.generate(
                          _pages.length, (i) => _buildDot(i)),
                    ),
                    const SizedBox(height: 28),
                    // Boutons
                    if (_currentPage == _pages.length - 1) ...[
                      _buildPrimaryButton("C'est parti !", () {
                        session.vientDeLaDecouverte = true;
                        Get.toNamed('/step');
                      }),
                      const SizedBox(height: 12),
                      _buildSecondaryButton("J'ai déjà un compte", () {
                        session.vientDeLaDecouverte = false;
                        Get.toNamed('/login');
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(_pages[index]['image']!, fit: BoxFit.cover),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0x55000000),
                Color(0xE0000000),
              ],
              stops: [0.25, 0.55, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    final bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 7),
      height: 6,
      width: isActive ? 28 : 6,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white
            : Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_spOrange1, _spOrange2],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _spOrange1.withValues(alpha: 0.40),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
              color: Colors.white.withValues(alpha: 0.50), width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
