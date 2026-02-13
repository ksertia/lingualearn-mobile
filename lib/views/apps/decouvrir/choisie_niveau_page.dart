import 'package:fasolingo/controller/apps/langue/langue_controller.dart';
import 'package:fasolingo/models/langue/langue_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChoisieNiveauPage extends StatefulWidget {
  const ChoisieNiveauPage({super.key});

  @override
  State<ChoisieNiveauPage> createState() => _ChoisieNiveauPageState();
}

class _ChoisieNiveauPageState extends State<ChoisieNiveauPage> {
  late final LanguagesController languagesController;

  @override
  void initState() {
    super.initState();
    languagesController = Get.find<LanguagesController>();
    // Charger les niveaux pour la langue sélectionnée
    WidgetsBinding.instance.addPostFrameCallback((_) {
      languagesController.loadLanguageLevels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languagesController = this.languagesController;

    const Color primaryColor = Color.fromARGB(255, 0, 0, 153);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 127, 0),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
              'Apprendre le ${languagesController.selectedLanguage.value?.name ?? "..."}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            )),
      ),
      body: Obx(() {
        // Utiliser uniquement les niveaux récupérés depuis l'API
        final List<dynamic> backendLevels =
            languagesController.languageLevels;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              const Text(
                "Quel est votre niveau ?",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 10),
              Text(
                "Nous adapterons les leçons de ${languagesController.selectedLanguage.value?.name ?? 'votre langue'} pour vous.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 35),
              Expanded(
                child: backendLevels.isEmpty
                  ? (languagesController.isLoadingLevels.value
                    ? const Center(
                      child: CircularProgressIndicator(),
                      )
                    : const Center(
                      child: Text("Aucun niveau disponible pour le moment.")))
                    : ListView.separated(
                        itemCount: backendLevels.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final level = backendLevels[index];

                          return Obx(() {
                            final selected = languagesController.selectedLevel.value;
                            String? selectedId;
                            if (selected == null) selectedId = null;
                            else if (selected is Map) selectedId = selected['id']?.toString();
                            else selectedId = selected?.id?.toString();

                            final String levelId = (level is Map) ? (level['id']?.toString() ?? '') : (level.id?.toString() ?? '');
                            bool isSelected = selectedId != null && selectedId == levelId;

                            // Accès sûr aux propriétés du niveau (Map JSON ou modèle Dart)
                            final String levelName = (level is Map)
                                ? (level['name']?.toString() ?? '')
                                : (level.name?.toString() ?? '');
                            final String levelDescription = (level is Map)
                                ? (level['description']?.toString() ?? '')
                                : (level.description?.toString() ?? '');

                            return InkWell(
                              onTap: () => languagesController.selectLevel(level),
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor.withOpacity(0.05)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.grey.shade200,
                                    width: 2.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                              color:
                                                  primaryColor.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4))
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? primaryColor
                                            : Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.trending_up_rounded,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            levelName,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? primaryColor
                                                  : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            levelDescription,
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                                height: 1.3),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_off_rounded,
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.grey.shade300,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40, top: 20),
                child: Obx(() {
                  bool hasLevelSelected =
                      languagesController.selectedLevel.value != null;
                  bool isApiLoading = languagesController.isLoading.value;

                  return SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: (hasLevelSelected) ? 6 : 0,
                      ),
                      onPressed: (!hasLevelSelected || isApiLoading)
                          ? null
                          : () async {
                              // Double check de sécurité avant l'appel API
                              if (languagesController.selectedLanguage.value ==
                                  null) {
                                Get.snackbar(
                                  "Oups",
                                  "Veuillez recommencer la sélection de la langue.",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                Get.offAllNamed('/selection');
                                return;
                              }

                              // --- SAUVEGARDE SUR LE SERVEUR ---
                              bool success = await languagesController
                                  .saveLevelSelection();

                              if (success) {
                                Get.offAllNamed('/HomeScreen');
                              } else {
                                print(
                                    "⚠️ Échec de la synchronisation finale avec le backend");
                              }
                            },
                      child: isApiLoading
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3),
                            )
                          : const Text(
                              "C'EST PARTI !",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}
