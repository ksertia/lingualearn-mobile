import 'package:fasolingo/controller/apps/langue/decouvert_langue_controller.dart';
import 'package:fasolingo/models/langue/decouvert_langue.dart';
import 'package:fasolingo/views/apps/decouvrir/deco_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class LanguageDcouvertPage extends StatefulWidget {
  const LanguageDcouvertPage({super.key});

  @override
  State<LanguageDcouvertPage> createState() => _LanguageDcouvertPageState();
}

class _LanguageDcouvertPageState extends State<LanguageDcouvertPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  final LanguageController _controller = LanguageController();

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

    _controller.fetchLanguages();
    
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4E6), Colors.white],
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
                        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                            .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack)),
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
              if (!_controller.isLoading && _controller.errorMessage == null)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildPrimaryButton(),
                ),
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
            style: TextStyle(fontSize: 16, color: Colors.grey),
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
    if (_controller.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    if (_controller.errorMessage != null) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.cloud_off, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(_controller.errorMessage!, textAlign: TextAlign.center),
            TextButton(
              onPressed: () => _controller.fetchLanguages(),
              child: const Text("Réessayer", style: TextStyle(color: Colors.orange)),
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
        final lang = _controller.languages[index];
        return _buildEnhancedCard(lang);
      },
    );
  }

  Widget _buildEnhancedCard(LanguageDiscover lang) {
    bool isSelected = _controller.selectedLanguageId == lang.id;
    
    String displayIcon = lang.name.contains("Dioula") ? "🌍" : 
    lang.name.contains("Mooré") ? "☀️" : "🌿";

    return GestureDetector(
      onTap: () => _controller.selectLanguage(lang.id),
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
              color: isSelected ? Colors.orange.withOpacity(0.15) : Colors.black.withOpacity(0.03),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.orange.shade900 : Colors.black87,
                    ),
                  ),
                  Text(
                    lang.description ?? "Découvrir la langue",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
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

  Widget _buildPrimaryButton() {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: _controller.selectedLanguageId != null
            ? [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]
            : [],
      ),
      child: ElevatedButton(
      onPressed: _controller.selectedLanguageId == null
    ? null
    : () {
        
        Get.to(
          () => const DiscoveryPage(),
          arguments: _controller.selectedLanguage!,
        );
      },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _controller.selectedLanguageId == null ? "Choisissez une langue" : "C'est parti !",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            if (_controller.selectedLanguageId != null) ...[
              const SizedBox(width: 10),
              const Icon(Icons.rocket_launch_rounded),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}