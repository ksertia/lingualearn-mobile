import 'package:fasolingo/controller/apps/langue/langue_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languagesController = Get.isRegistered<LanguagesController>()
        ? Get.find<LanguagesController>()
        : Get.put(LanguagesController());

    final session = Get.find<SessionController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
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
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.face, size: 80, color: Colors.orange),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: const Text(
                      "Que veux-tu\napprendre ?",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.2),
                    ),
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
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.blue.shade200, width: 1.5),
                      color: Colors.blue.withOpacity(0.05),
                    ),
                    child: const Text("Français",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            Expanded(
              child: Obx(() {
                if (languagesController.isLoading.value &&
                    languagesController.allLanguages.isEmpty) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.orange));
                }

                if (languagesController.allLanguages.isEmpty) {
                  return const Center(
                    child: Text("Aucune langue disponible pour le moment."),
                  );
                }

                return ListView.builder(
                  itemCount: languagesController.allLanguages.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final lang = languagesController.allLanguages[index];

                    return Obx(() {
                      bool isSelected =
                          languagesController.selectedLanguage.value?.id ==
                              lang.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: InkWell(
                          onTap: () => languagesController.selectLanguage(lang),
                          borderRadius: BorderRadius.circular(15),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.grey.shade300,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                          color: Colors.orange.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4))
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: (lang.iconUrl != null &&
                                            lang.iconUrl!.isNotEmpty)
                                        ? Image.network(
                                            lang.iconUrl!, 
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child: SizedBox(
                                                  width: 15,
                                                  height: 15,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Icon(Icons.flag_rounded,
                                                    color: Colors.grey),
                                          )
                                        : const Icon(Icons.language,
                                            color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  lang.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.orange.shade900
                                        : Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      color: Colors.orange),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
            ),

           Padding(
  padding: const EdgeInsets.symmetric(vertical: 30),
  child: Obx(() {
    final isSelected = languagesController.selectedLanguage.value != null;
    final isApiLoading = languagesController.isLoading.value;

    return ElevatedButton(
      onPressed: (!isSelected || isApiLoading)
          ? null
          : () {
              Get.toNamed(session.vientDeLaDecouverte
                  ? '/decouvrir'
                  : '/niveau');
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 255, 127, 0),
        disabledBackgroundColor: Colors.grey.shade300,
        minimumSize: const Size(double.infinity, 60),
        elevation: isSelected ? 4 : 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)),
      ),
      child: isApiLoading
          ? const SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 3))
          : const Text(
              "CONTINUER",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
    );
  }),
),
          ],
        ),
      ),
    );
  }
}
