import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/services/langue/langue_service.dart';
import 'package:fasolingo/models/langue/langue_model.dart';
import 'package:get/get.dart';

class LanguagesController extends GetxController {
  final LanguageLevelService _languageService = LanguageLevelService();

  RxList<LanguageModel> allLanguages = <LanguageModel>[].obs;
  RxBool isLoading = false.obs;

  Rxn<LanguageModel> selectedLanguage = Rxn<LanguageModel>();
  Rxn<LevelModel> selectedLevel = Rxn<LevelModel>();

  @override
  void onInit() {
    super.onInit();
    loadAllLanguages();
  }

  void selectLanguage(LanguageModel lang) {
    selectedLanguage.value = lang;
    selectedLevel.value = null;
    print("📍 Langue sélectionnée localement : ${lang.name}");
  }

  void selectLevel(LevelModel level) {
    selectedLevel.value = level;
    print("📍 Niveau sélectionné localement : ${level.name}");
  }

  Future<void> loadAllLanguages() async {
    try {
      isLoading(true);
      final result = await _languageService.fetchLanguages();
      allLanguages.assignAll(result);
    } catch (e) {
      print("❌ Erreur dans le controller (loadAllLanguages) : $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> saveLevelSelection() async {
    final session = Get.find<SessionController>();

    final String userId = session.userId.value.isNotEmpty
        ? session.userId.value
        : (session.user?.id ?? "");

    final String? languageId = selectedLanguage.value?.id;
    final String? levelId = selectedLevel.value?.id;

    if (userId.isEmpty || languageId == null || levelId == null) {
      print(
          "⚠️ Données incomplètes : User=$userId, Lang=$languageId, Level=$levelId");
      _showErrorSnackbar(
          "Sélection incomplète", "Veuillez choisir une langue et un niveau.");
      return false;
    }

    try {
      isLoading(true);

      print(
          "⏳ Étape 1/2 : Sauvegarde de la langue ($languageId) sur le serveur...");
      bool langOk = await _languageService.selectLanguageForUser(
          userId: userId, languageId: languageId);

      if (!langOk) {
        print("❌ Échec lors de la sauvegarde de la langue.");
        _showErrorSnackbar("Erreur Serveur",
            "Impossible de sauvegarder votre choix de langue.");
        return false;
      }

      print("⏳ Étape 2/2 : Sauvegarde du niveau ($levelId) sur le serveur...");
      bool levelOk = await _languageService.selectLevelForUser(
          userId: userId, levelId: levelId);

      if (levelOk) {
        print("✅ SUCCÈS TOTAL : Profil mis à jour sur le backend.");

        session.selectedLanguageId.value = languageId;
        session.selectedLevelId.value = levelId;
        return true;
      } else {
        print("❌ Échec lors de la sauvegarde du niveau.");
        _showErrorSnackbar(
            "Erreur Serveur", "La langue est sauvée mais pas le niveau.");
        return false;
      }
    } catch (e) {
      print("❌ Erreur critique lors de la synchronisation : $e");
      _showErrorSnackbar(
          "Erreur de connexion", "Le serveur ne répond pas correctement.");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> confirmAndGoToHome() async {
    if (isLoading.value) return;

    bool isSaved = await saveLevelSelection();
    if (isSaved) {
      Get.offAllNamed('/home');
    }
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
      duration: const Duration(seconds: 3),
    );
  }
}
