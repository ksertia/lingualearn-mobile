import 'package:fasolingo/controller/apps/langue/langue_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/models/langue/langue_model.dart';
import 'package:fasolingo/views/apps/home/dashboard_screen.dart';
import 'package:fasolingo/views/apps/home/screens/parcours.dart';
import 'package:fasolingo/views/apps/home/screens/stepsscreens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class AcceuilleSreen extends StatefulWidget {
  const AcceuilleSreen({super.key});

  @override
  State<AcceuilleSreen> createState() => _AcceuilleSreenState();
}

class _AcceuilleSreenState extends State<AcceuilleSreen> {
  final SessionController session = Get.find<SessionController>();
  final LanguagesController langController =
      Get.isRegistered<LanguagesController>()
          ? Get.find<LanguagesController>()
          : Get.put(LanguagesController());

  RxString levelName = "Chargement...".obs;

  @override
  void initState() {
    super.initState();
    _initHomeData();
  }

  void _loadLevelName() {
    final String levelId = session.selectedLevelId.value.isNotEmpty
        ? session.selectedLevelId.value
        : session.user?.selectedLevelId ?? "";
    if (levelId.isNotEmpty) {
      langController.getLevelNameById(levelId).then((name) {
        levelName.value = name;
      });
    } else {
      levelName.value = "Niveau non défini";
    }
  }

  Future<void> _initHomeData() async {
    await langController.loadLanguageLevels();

    _loadLevelName();

    ever(session.selectedLevelId, (_) async {
      await langController.loadLanguageLevels();
      _loadLevelName();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, session),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    _buildSectionTitle("Ma langue", "Changer"),
                    const SizedBox(height: 15),
                    Obx(() {
                      final String languageId =
                          session.selectedLanguageId.value.isNotEmpty
                              ? session.selectedLanguageId.value
                              : session.user?.selectedLanguageId ?? "";
                      final LanguageModel? selectedLanguage = langController
                          .allLanguages
                          .firstWhereOrNull((lang) => lang.id == languageId);

                      return _buildLanguageCard(
                          languageId, selectedLanguage, levelName.value);
                    }),
                    const SizedBox(height: 25),
                    _buildSectionTitle("Navigation", null),
                    const SizedBox(height: 15),
                    _buildNavigationGrid(),
                    const SizedBox(height: 25),
                    _buildSectionTitle("Mon parcours actuel", null),
                    const SizedBox(height: 15),
                    _buildCurrentPathCard(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SessionController session) {
    final String firstName =
        session.user?.firstName ?? LocalStorage.getUserName() ?? "Apprenant";

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.withOpacity(0.8),
                Colors.orange.withOpacity(0.5)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(34),
              bottomRight: Radius.circular(34),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Coucou, $firstName !",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Prêt pour une super aventure ?🌟",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Lottie.asset(
                      'assets/lottie/mascot.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        Positioned(
          right: -30,
          bottom: -20,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -20,
          bottom: 10,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBadge(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.17),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(subtitle,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(
      String languageId, LanguageModel? selectedLanguage, String levelName) {
    final String languageName = selectedLanguage?.name ??
        (languageId.isNotEmpty
            ? "Langue choisie"
            : "Aucune langue sélectionnée");

    final String languageShortCode = selectedLanguage?.code.toUpperCase() ??
        (languageName.length >= 2
            ? languageName.substring(0, 2).toUpperCase()
            : "LN");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueAccent, Colors.blueAccent],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    languageShortCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(languageName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("Niveau : $levelName",
                        style: const TextStyle(
                            color: Color(0xFFF0F4FF), fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  "Kids",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const LinearProgressIndicator(
                    value: 0.68,
                    minHeight: 10,
                    backgroundColor: Color(0x55FFFFFF),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFFFFFFFF)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text("68%",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Icon(Icons.emoji_objects, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text("Continue ton aventure !",
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildNavigationGrid() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: Colors.white.withOpacity(0.10),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(-2, -2),
        ),
      ],
    ),
    child: GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 0.78,
      padding: EdgeInsets.zero,
      children: [
        _buildNavBtn(
          Icons.menu_book,
          "Modules",
          Colors.purpleAccent,
          () => Get.to(() => const HomePage()),
        ),
        _buildNavBtn(
          Icons.map,
          "Parcours",
          Colors.blueAccent,
          () => Get.to(() => const ParcoursSelectionPage()),
        ),
        _buildNavBtn(
          Icons.flag,
          "Étapes",
          Colors.orangeAccent,
          () => Get.to(() => const StepsScreensPages()),
        ),
      ],
    ),
  );
}

  Widget _buildCurrentPathCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFF),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildGradientIcon(Icons.rocket_launch),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Ton parcours du jour",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text("5 modules • 5 étapes",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPathStat("1/5", "MODULES"),
              _buildPathStat("1/4", "PARCOURS"),
              _buildPathStat("1/5", "ÉTAPES"),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.blueAccent]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ElevatedButton(
              onPressed: () => Get.to(() => const HomePage()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  "Explorer les modules",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String? action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A))),
        if (action != null)
          Text(action,
              style: const TextStyle(
                  color: Color(0xFF4A90E2),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4)),
      ],
    );
  }

  Widget _cardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 12))
        ],
      ),
      child: child,
    );
  }

  Widget _buildNavBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.95)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathStat(String val, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(val,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGradientIcon(IconData icon) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFF8B9A), Color(0xFFFFCC6F)],
      ).createShader(bounds),
      child: Icon(icon, size: 44, color: Colors.white),
    );
  }
}
