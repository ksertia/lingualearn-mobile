import 'package:fasolingo/controller/apps/langue/langue_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  
  String _getLanguageEmoji(String? name) {
    if (name == null) return "🌍";
    final lowerName = name.toLowerCase();
    
    if (lowerName.contains("français") || lowerName.contains("french")) {
      return "🗼"; 
    } else if (lowerName.contains("english") || lowerName.contains("anglais")) {
      return "🎯"; 
    } else if (lowerName.contains("español") || lowerName.contains("spanish") || lowerName.contains("espagnol")) {
      return "💃"; 
    } else if (lowerName.contains("mooré") || lowerName.contains("moore") || lowerName.contains("moré")) {
      return "☀️"; 
    } else if (lowerName.contains("dioula") || lowerName.contains("dyula")) {
      return "🌿"; 
    } else if (lowerName.contains("allemand") || lowerName.contains("german")) {
      return "🏰"; 
    } else if (lowerName.contains("italien") || lowerName.contains("italian")) {
      return "🍕"; 
    } else if (lowerName.contains("portugais") || lowerName.contains("portuguese")) {
      return "⚽"; 
    } else if (lowerName.contains("chinois") || lowerName.contains("chinese")) {
      return "🐉"; 
    } else if (lowerName.contains("arabe") || lowerName.contains("arabic")) {
      return "🕌"; 
    } else if (lowerName.contains("japonais") || lowerName.contains("japanese")) {
      return "🎌"; 
    }
    
    return "🌍"; // Default globe
  }

  @override
  Widget build(BuildContext context) {
    final languagesController = Get.isRegistered<LanguagesController>()
        ? Get.find<LanguagesController>()
        : Get.put(LanguagesController());

    final session = Get.find<SessionController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFB347), // Orange clair
              Color(0xFFFFE259), // Jaune soleil
              Color(0xFF88D8B0), // Vert clair menthe
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(_fadeController),
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                      .animate(_slideController),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button en haut
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Mascotte et titre en dessous
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Lottie.asset(
                                'assets/lottie/mascot.json',
                                width: 80,
                                height: 80,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.face, size: 70, color: Colors.orange),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Commencer\nvotre parcours",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.2,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black12,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "Choisissez une langue",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Languages Section
                      Obx(() {
                        if (languagesController.isLoading.value &&
                            languagesController.allLanguages.isEmpty) {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Lottie.asset(
                                    'assets/lottie/mascot.json',
                                    width: 100,
                                    height: 100,
                                  ),
                                  const SizedBox(height: 16),
                                  const CircularProgressIndicator(color: Colors.orange),
                                ],
                              ),
                            ),
                          );
                        }

                        if (languagesController.allLanguages.isEmpty) {
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  const Text("😢", style: TextStyle(fontSize: 50)),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Aucune langue disponible",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "🌟 Langues disponibles",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: languagesController.allLanguages.length,
                              itemBuilder: (context, index) {
                                final lang = languagesController.allLanguages[index];

                                return Obx(() {
                                  bool isSelected =
                                      languagesController.selectedLanguage.value?.id == lang.id;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _buildLanguageCard(
                                      lang: lang,
                                      isSelected: isSelected,
                                      onTap: () => languagesController.selectLanguage(lang),
                                      index: index,
                                    ),
                                  );
                                });
                              },
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 28),
                      
                      // Action Buttons
                      Obx(() {
                        final hasSelection = languagesController.selectedLanguage.value != null;
                        final hasLevel = languagesController.selectedLevel.value != null;
                        final isLoading = languagesController.isLoading.value;

                        return Column(
                          children: [
                            if (hasSelection && hasLevel)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildActionButton(
                                  label: "➕ Ajouter cette langue",
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                          await languagesController.addLanguageLevelToList();
                                        },
                                  isLoading: isLoading,
                                  isPrimary: false,
                                ),
                              ),

                            _buildActionButton(
                              label: languagesController.selectedLanguageLevels.isEmpty
                                  ? "🤔 Sélectionner une langue"
                                  : "🚀 Continuons !",
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (languagesController.selectedLanguageLevels.isNotEmpty) {
                                        await languagesController.confirmAndGoToHome();
                                        return;
                                      }

                                      if (hasSelection && !hasLevel) {
                                        await languagesController.confirmLanguageSelection();
                                        return;
                                      }

                                      if (hasSelection && hasLevel) {
                                        await languagesController.confirmAndGoToHome();
                                        return;
                                      }
                                    },
                              isLoading: isLoading,
                              isPrimary: true,
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required dynamic lang,
    required bool isSelected,
    required VoidCallback onTap,
    required int index,
  }) {
    final emoji = _getLanguageEmoji(lang.name);
    
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1)
          .animate(CurvedAnimation(parent: _slideController, curve: Interval(
        (index * 0.05).clamp(0.0, 1.0),
        ((index + 1) * 0.05).clamp(0.0, 1.0),
      ))),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.grey.shade200,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Emoji icon instead of image
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.orange.withOpacity(0.1) 
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.name ?? "Langue",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.orange.shade800 : Colors.black87,
                      ),
                    ),
                    if (lang.code != null)
                      Text(
                        lang.code!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB347), Color(0xFFFFE259)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required dynamic level,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final icon = _getLevelIcon(level['level_order'] ?? 1);
    final colors = _getLevelColors(level['level_order'] ?? 1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    colors[0].withOpacity(0.1),
                    colors[1].withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors[0] : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors[0].withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : colors[0],
            ),
            const SizedBox(height: 8),
            Text(
              level['name'] ?? "Niveau",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isLoading,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.orange : Colors.grey.shade100,
          foregroundColor: isPrimary ? Colors.white : Colors.black87,
          elevation: isPrimary ? 4 : 0,
          disabledBackgroundColor: Colors.grey.shade200,
          disabledForegroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  IconData _getLevelIcon(int order) {
    switch (order) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      case 4:
        return Icons.looks_4;
      default:
        return Icons.school;
    }
  }

  List<Color> _getLevelColors(int order) {
    switch (order) {
      case 1:
        return [Colors.blue.shade400, Colors.blue.shade600];
      case 2:
        return [Colors.amber.shade400, Colors.amber.shade600];
      case 3:
        return [Colors.red.shade400, Colors.red.shade600];
      case 4:
        return [Colors.purple.shade400, Colors.purple.shade600];
      default:
        return [Colors.grey.shade400, Colors.grey.shade600];
    }
  }
}

