import 'package:fasolingo/controller/apps/langue/discover_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:fasolingo/views/apps/decouvrir/deco_page.dart';

class LanguageDcouvertPage extends StatefulWidget {
  const LanguageDcouvertPage({super.key});

  @override
  State<LanguageDcouvertPage> createState() => _LanguageDcouvertPageState();
}

class _LanguageDcouvertPageState extends State<LanguageDcouvertPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // Utilisation de notre DiscoverController
  final DiscoverController _controller = DiscoverController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    // Initialisation : charge les langues au démarrage
    _controller.init();

    // Ecoute les changements du controller pour rafraîchir l'UI
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(160, 255, 216, 61),
              Color.fromARGB(184, 255, 138, 66),
              Color.fromARGB(152, 107, 203, 120),
              Color.fromARGB(185, 77, 151, 255),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: FadeTransition(
                      opacity: _fadeController,
                      child: SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0, 0.1), end: Offset.zero)
                            .animate(CurvedAnimation(
                                parent: _slideController,
                                curve: Curves.easeOutBack)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildBackButton(context),
                            _buildHeader(),
                            const SizedBox(height: 40),
                            _buildLanguageListHeader(),
                            const SizedBox(height: 16),
                            _buildMainContent(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Lottie.asset(
            'assets/lottie/mascot.json',
            width: 180,
            height: 180,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.auto_awesome, size: 100, color: Colors.orange),
          ),
          const Text(
            "Exploration",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
              letterSpacing: -0.5,
            ),
          ),
          const Text(
            "Quelle culture souhaitez-vous découvrir ?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageListHeader() {
    return const Text(
      "LANGUES DISPONIBLES",
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.orange,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildMainContent() {
    // Affiche un loader si on n'a pas encore de langues
    if (_controller.isLoading && _controller.languages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    // Gestion de l'erreur
    if (_controller.error != null && _controller.languages.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(_controller.error!,
                style: const TextStyle(color: Colors.white)),
            TextButton(
              onPressed: () => _controller.init(),
              child: const Text("Réessayer",
                  style: TextStyle(color: Colors.orange)),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _controller.languages.length,
      itemBuilder: (context, index) {
        final langName = _controller.languages[index];
        return _buildEnhancedCard(langName);
      },
    );
  }

  Widget _buildEnhancedCard(String langName) {
    bool isSelected = _controller.selectedLanguage == langName;

    // Logique d'icône visuelle
    String displayIcon = langName.toLowerCase().contains("dioula")
        ? "🌍"
        : langName.toLowerCase().contains("mooré")
            ? "☀️"
            : "🌿";

    return GestureDetector(
      onTap: () => _controller.selectLanguage(langName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.orange.withOpacity(0.15)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(displayIcon, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                langName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.orange.shade900 : Colors.black87,
                ),
              ),
            ),
            if (_controller.isLoading && isSelected)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.orange),
              )
            else if (isSelected)
              const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.orange,
                child: Icon(Icons.check, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: _controller.selectedLanguage != null
              ? [
                  BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed:
              _controller.selectedLanguage == null || _controller.isLoading
                  ? null
                  : () {
                      Get.toNamed(
                        '/decouverte',
                        arguments: _controller.languageContent,
                      );
                    },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _controller.selectedLanguage == null
                    ? "Choisissez une langue"
                    : "C'est parti !",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              if (_controller.selectedLanguage != null &&
                  !_controller.isLoading) ...[
                const SizedBox(width: 10),
                const Icon(Icons.rocket_launch_rounded),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            size: 20, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
