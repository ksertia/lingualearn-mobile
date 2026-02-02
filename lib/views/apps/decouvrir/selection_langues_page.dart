import 'package:fasolingo/controller/apps/langue/langue_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart'; 
import 'package:fasolingo/models/langue/langue_model.dart'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  final languagesController = Get.put(LanguagesController());
  
  String selectedLanguageName = ""; 
  String userSourceLanguage = "Français";

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie/mascot.json',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: const Text(
                    "Que veux-tu\napprendre ?",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, height: 1.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "POUR LES PERSONNES PARLANT :",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200, width: 1.5),
                      color: Colors.blue.withOpacity(0.05),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: userSourceLanguage,
                        items: <String>['Français', 'Anglais'].map((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                        onChanged: (newValue) =>
                            setState(() => userSourceLanguage = newValue!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            // --- LISTE DES LANGUES DU BACKEND ---
            Expanded(
              child: Obx(() {
                if (languagesController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Colors.orange));
                }

                if (languagesController.allLanguages.isEmpty) {
                  return const Center(child: Text("Aucune langue disponible"));
                }

                return ListView.builder(
                  itemCount: languagesController.allLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = languagesController.allLanguages[index];
                    bool isSelected = selectedLanguageName == lang.name;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: InkWell(
                        onTap: () {
                          languagesController.selectLanguage(lang);
                          setState(() => selectedLanguageName = lang.name);
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected ? Colors.orange : Colors.grey.shade300,
                              width: 2.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: (lang.iconUrl != null && lang.iconUrl!.isNotEmpty)
                                      ? Image.network(
                                          lang.iconUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => 
                                              const Icon(Icons.flag, color: Colors.grey),
                                        )
                                      : const Icon(Icons.language, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                lang.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.orange.shade900 : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: Colors.orange),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            
            // --- BOUTON CONTINUER ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: ElevatedButton(
                onPressed: selectedLanguageName.isEmpty
                    ? null
                    : () {
                        // Récupération de l'objet complet via le controller
                        final langModel = languagesController.selectedLanguage.value;

                        if (langModel != null) {
                          session.langueChoisie = langModel.name;

                          // 🎯 VERIFICATION : Est-ce que cette langue a des niveaux ?
                          if (langModel.levels.isEmpty) {
                            Get.snackbar(
                              "Contenu à venir",
                              "Les cours pour le ${langModel.name} sont en cours de création.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.blueGrey,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          } else {
                            // On navigue vers la page des niveaux
                            Get.toNamed(session.vientDeLaDecouverte ? '/decouvrir' : '/niveau');
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 127, 0),
                  disabledBackgroundColor: Colors.grey.shade300,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  "CONTINUER",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selectedLanguageName.isEmpty
                          ? Colors.grey.shade600
                          : Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}