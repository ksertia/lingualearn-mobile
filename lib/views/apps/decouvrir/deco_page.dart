import 'package:fasolingo/controller/apps/discovery_controller.dart';
import 'package:fasolingo/models/langue/decouvert_langue.dart'; 
import 'package:fasolingo/widgets/decouvrir_page/and_page.dart';
import 'package:fasolingo/widgets/decouvrir_page/audio_page.dart';
import 'package:fasolingo/widgets/decouvrir_page/choise_page.dart';
import 'package:fasolingo/widgets/decouvrir_page/memory/frist_page.dart';
import 'package:fasolingo/widgets/decouvrir_page/memory/remplie_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageDiscover language = Get.arguments;
    
    final DiscoveryController controller = Get.put(DiscoveryController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Découvrir le ${language.name}",
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: Obx(
          () => controller.currentPage.value == 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                  onPressed: () => Get.back(),
                )
              : IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Get.back(),
                ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Obx(() => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: controller.progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 0, 0, 153)),
                  ),
                )),
          ),
          
          Expanded(
            child: PageView(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => controller.currentPage.value = index,
              children: const [
                StepMemorise(
                  titre: "Cultive ton jardin de mots😃",
                  texteAMemoriser: "Ne yibeogo, yamba laafi ?",
                ),
                StepMemorise(
                  titre: "Cultive ton jardin de mots😃",
                  texteAMemoriser: "Ne y tūūma, Wend na sõng-y.",
                ),
                StepMemorise(
                  titre: "Cultive ton jardin de mots😃",
                  texteAMemoriser: "Yãmb modga woto!",
                ),
                StepQuiz(
                  question: "Comment dit-on 'École' ?",
                  options: ["School", "House", "Car", "Bread"],
                ),
                StepQuizFill(
                  phraseDebut: "Tu es ",
                  phraseFin: " école",
                  options: ["à l'", "au", "la", "dans"],
                ),
                StepQuizAudio(
                  correctWord: "Bonjour",
                  options: ["Bonjour", "Bonsoir", "Salut", "Merci"],
                ),
                StepSuccess(),
              ],
            ),
          ),

          Obx(
            () => controller.currentPage.value < 6 
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (controller.currentPage.value > 0)
                          OutlinedButton(
                            onPressed: () => controller.previousPage(),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 0, 0, 153)),
                            ),
                            child: const Text("Précédent",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 153))),
                          )
                        else
                          const SizedBox.shrink(),

                        ElevatedButton(
                          onPressed: () => controller.nextPage(),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            backgroundColor:
                                const Color.fromARGB(255, 0, 0, 153),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                          ),
                          child: Text(
                            controller.currentPage.value == 5
                                ? "FINIR"
                                : "Suivant",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(), 
          ),
        ],
      ),
    );
  }
}