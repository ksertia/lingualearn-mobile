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

  @override
  Widget build(BuildContext context) {
    final languagesController = Get.isRegistered<LanguagesController>()
        ? Get.find<LanguagesController>()
        : Get.put(LanguagesController());

    final session = Get.find<SessionController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
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
                  // 🎨 En-tête avec mascotte
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: [
                        Lottie.asset(
                          'assets/lottie/mascot.json',
                          width: 90,
                          height: 90,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.face, size: 80, color: Colors.orange),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Commencer\nvotre parcours",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Choisissez une langue",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 📊 Barre de progression
                  Obx(() {
                    int selected = languagesController.selectedLanguageLevels.length;
                    int max = 2;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Langues sélectionnées",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "$selected/$max",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: selected / max,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              selected == 0
                                  ? Colors.grey.shade300
                                  : Colors.orange.shade400,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 32),

                  // 🎯 Langues disponibles
                  Obx(() {
                    if (languagesController.isLoading.value &&
                        languagesController.allLanguages.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: Colors.orange),
                        ),
                      );
                    }

                    if (languagesController.allLanguages.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            "Aucune langue disponible",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Langues disponibles",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              languagesController.allLanguages.length,
                          itemBuilder: (context, index) {
                            final lang =
                                languagesController.allLanguages[index];

                            return Obx(() {
                              bool isSelected =
                                  languagesController.selectedLanguage.value
                                          ?.id ==
                                      lang.id;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildLanguageCard(
                                  lang: lang,
                                  isSelected: isSelected,
                                  onTap: () =>
                                      languagesController
                                          .selectLanguage(lang),
                                  index: index,
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  const SizedBox(height: 24),

                  // ✅ Boutons d'action
                  Obx(() {
                    final hasSelection =
                        languagesController.selectedLanguage.value != null;
                    final hasLevel =
                        languagesController.selectedLevel.value != null;
                    final isLoading = languagesController.isLoading.value;

                    return Column(
                      children: [
                        // Bouton Ajouter la langue
                        if (hasSelection && hasLevel)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildActionButton(
                              label: "Ajouter cette langue",
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      await languagesController
                                          .addLanguageLevelToList();
                                    },
                              isLoading: isLoading,
                              isPrimary: false,
                            ),
                          ),

                        // Bouton Continuer / Sélectionner
                        _buildActionButton(
                          label: languagesController.selectedLanguageLevels.isEmpty
                              ? "Sélectionner une langue"
                              : "Continuer",
                          onPressed: isLoading
                              ? null
                              : () async {
                                  // if user already added languages -> continue to home
                                  if (languagesController.selectedLanguageLevels.isNotEmpty) {
                                    await languagesController.confirmAndGoToHome();
                                    return;
                                  }

                                  // if a language selected but no level yet -> confirm language then go to niveau
                                  if (hasSelection && !hasLevel) {
                                    await languagesController.confirmLanguageSelection();
                                    return;
                                  }

                                  // if both language and level selected -> save and go home
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
    );
  }

  /// Carte de langue avec animation
  Widget _buildLanguageCard({
    required dynamic lang,
    required bool isSelected,
    required VoidCallback onTap,
    required int index,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1)
          .animate(CurvedAnimation(parent: _slideController, curve: Interval(
        (index * 0.05).clamp(0.0, 1.0),
        ((index + 1) * 0.05).clamp(0.0, 1.0),
      ))),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Drapeau/Icône
              Container(
                width: 48,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: (lang.iconUrl != null && lang.iconUrl!.isNotEmpty)
                      ? Image.network(
                          lang.iconUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.language, color: Colors.grey),
                        )
                      : const Icon(Icons.language, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.name ?? "Langue",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (lang.code != null)
                      Text(
                        lang.code!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Carte de niveau avec gradient
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

  /// Bouton d'action personnalisé
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
            borderRadius: BorderRadius.circular(14),
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

  /// Helper pour l'icône du niveau
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

  /// Helper pour les couleurs du niveau
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
