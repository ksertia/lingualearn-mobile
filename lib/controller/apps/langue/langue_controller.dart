import 'package:tibi/controller/apps/session_controller.dart';
import 'package:tibi/controller/apps/user_progress/user_progress_controller.dart';
import 'package:tibi/helpers/services/langue/langue_service.dart';
import 'package:tibi/models/langue/langue_model.dart';
import 'package:get/get.dart';

class LanguagesController extends GetxController {
  final LanguageLevelService _languageService = LanguageLevelService();

  RxList<LanguageModel> allLanguages = <LanguageModel>[].obs;
  RxList<dynamic> languageLevels = <dynamic>[].obs;
  RxList<dynamic> modules = <dynamic>[].obs;
  RxList<Map<String, dynamic>> selectedLanguageLevels =
      <Map<String, dynamic>>[].obs;

  RxBool isLoading = false.obs;
  RxBool isLoadingLevels = false.obs;
  RxBool isLoadingModules = false.obs;
  RxBool isNewUser = true.obs;
  RxBool hasExistingLanguages = false.obs;

  Rxn<LanguageModel> selectedLanguage = Rxn<LanguageModel>();
  Rxn<dynamic> selectedLevel = Rxn<dynamic>();

  Rxn<Map<String, dynamic>> progressionData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    checkUserStatus();
  }

  Future<void> checkUserStatus() async {
    try {
      isLoading(true);
      final session = Get.find<SessionController>();

      if (session.userId.value.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      final String userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : (session.user?.id ?? "");

      if (userId.isEmpty) {
        isNewUser(true);
        hasExistingLanguages(false);
        isLoading(false);
        return;
      }
      await loadAllLanguages();
      if (allLanguages.isNotEmpty) {
        isNewUser(false);
        hasExistingLanguages(true);
      } else {
        isNewUser(true);
        hasExistingLanguages(false);
      }
    } catch (e) {
      isLoading(false);
    } finally {
      isLoading(false);
    }
  }

  Future<void> selectLanguage(LanguageModel lang) async {
    selectedLanguage.value = lang;
    selectedLevel.value = null;
  }

  // Étape 1 — POST /users/:userId/languages/:languageId/select
  Future<bool> selectLanguageOnly(LanguageModel lang) async {
    final session = Get.find<SessionController>();
    final String userId = session.userId.value.isNotEmpty
        ? session.userId.value
        : (session.user?.id ?? "");
    if (userId.isEmpty) {
      _showErrorSnackbar("Erreur", "Utilisateur non identifié.");
      return false;
    }
    selectedLanguage.value = lang;
    selectedLevel.value = null;
    try {
      isLoading(true);
      final ok = await _languageService.selectLanguageForUser(
          userId: userId, languageId: lang.id);
      if (!ok) {
        _showErrorSnackbar("Erreur", "Impossible de sélectionner cette langue.");
      }
      return ok;
    } finally {
      isLoading(false);
    }
  }

  Future<void> confirmLanguageSelection() async {
    final session = Get.find<SessionController>();
    final String userId = session.userId.value.isNotEmpty
        ? session.userId.value
        : (session.user?.id ?? "");
    final String? languageId = selectedLanguage.value?.id;

    if (userId.isEmpty || languageId == null) {
      _showErrorSnackbar("Erreur", "Veuillez sélectionner une langue.");
      return;
    }
    try {
      isLoading(true);
      bool saved = await _languageService.selectLanguageForUser(
          userId: userId, languageId: languageId);

      if (!saved) {
        _showErrorSnackbar("Erreur", "Impossible de sauvegarder la langue.");
        return;
      }
      session.selectedLanguageId.value = languageId;
      Get.toNamed('/niveau');
    } catch (e) {
      _showErrorSnackbar("Erreur", "Échec lors de la sauvegarde de la langue.");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> addLanguageLevelToList() async {
    final String? languageId = selectedLanguage.value?.id;
    String? levelId;
    if (selectedLevel.value == null) {
      levelId = null;
    } else if (selectedLevel.value is Map) {
      levelId = selectedLevel.value['id']?.toString();
    } else {
      levelId = selectedLevel.value?.id?.toString();
    }
    final String? languageName = selectedLanguage.value?.name;
    if (languageId == null || levelId == null) {
      _showErrorSnackbar(
          "Complet", "Veuillez sélectionner une langue et un niveau.");
      return false;
    }
    // Vérification doublon — combine progressList + session locale
    final List<String> serverIds = () {
      try {
        return Get.find<UserProgressController>()
            .progressList
            .map((e) => e.language.id)
            .toList();
      } catch (_) {
        return <String>[];
      }
    }();
    final List<String> sessionIds = selectedLanguageLevels
        .map((e) => e['languageId'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
    if ({...serverIds, ...sessionIds}.contains(languageId)) {
      _showErrorSnackbar("Déjà inscrite", "Vous êtes déjà inscrit(e) dans cette langue.");
      return false;
    }
    try {
      isLoading(true);
      final session = Get.find<SessionController>();
      final String userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : (session.user?.id ?? "");
      if (userId.isEmpty) {
        _showErrorSnackbar("Erreur", "Utilisateur non identifié.");
        return false;
      }
      // La langue a déjà été sélectionnée (étape 1) avant le chargement des niveaux.
      bool levelOk = await _languageService.selectLevelForUser(
          userId: userId, languageId: languageId, levelId: levelId);
      if (!levelOk) {
        _showErrorSnackbar("Erreur", "Impossible de sauvegarder le niveau.");
        return false;
      }
      selectedLanguageLevels.add({
        'languageId': languageId,
        'levelId': levelId,
        'languageName': languageName,
      });
      selectedLanguage.value = null;
      selectedLevel.value = null;
      languageLevels.clear();
      return true;
    } catch (e) {
      _showErrorSnackbar("Erreur", "Problème lors de l'ajout.");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> removeLanguageFromList(String languageId) async {
    try {
      isLoading(true);
      selectedLanguageLevels
          .removeWhere((item) => item['languageId'] == languageId);
    } catch (_) {
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadLanguageLevels() async {
    try {
      isLoadingLevels(true);

      final session = Get.find<SessionController>();

      final String userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : (session.user?.id ?? "");

      if (userId.isEmpty) {
        return;
      }

      final String? langId = selectedLanguage.value?.id.isNotEmpty == true
          ? selectedLanguage.value!.id
          : session.selectedLanguageId.value;

      final result = await _languageService.fetchLevels(
        userId: userId,
        languageId: langId,
      );
      languageLevels.assignAll(result);
    } catch (_) {
    } finally {
      isLoadingLevels(false);
    }
  }

  Future<String> getLevelNameById(String levelId) async {
    for (var level in languageLevels) {
      String levelIdFromList;
      if (level is Map) {
        levelIdFromList = level['id']?.toString() ?? '';
      } else {
        levelIdFromList = level.id?.toString() ?? '';
      }
      if (levelIdFromList == levelId) {
        if (level is Map) {
          return level['name']?.toString() ?? 'Niveau';
        } else {
          return level.name?.toString() ?? 'Niveau';
        }
      }
    }
    for (var lang in allLanguages) {
      for (var level in lang.levels) {
        if (level.id == levelId) {
          return level.name;
        }
      }
    }

    return 'Niveau';
  }

  Future<void> selectLevel(dynamic level) async {
    selectedLevel.value = level;
  }

  Future<void> loadAllLanguages() async {
    try {
      isLoading(true);
      final session = Get.find<SessionController>();
      final String userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : (session.user?.id ?? "");

      if (userId.isEmpty) {
        isLoading(false);
        return;
      }

      final result = await _languageService.fetchLanguages(userId: userId);
      allLanguages.assignAll(result);
    } catch (_) {
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
    String? levelId;
    if (selectedLevel.value == null) {
      levelId = null;
    } else if (selectedLevel.value is Map) {
      levelId = selectedLevel.value['id']?.toString();
    } else {
      levelId = selectedLevel.value?.id?.toString();
    }

    if (userId.isEmpty || languageId == null || levelId == null) {
      _showErrorSnackbar(
          "Sélection incomplète", "Veuillez choisir une langue et un niveau.");
      return false;
    }

    try {
      isLoading(true);
      bool levelOk = await _languageService.selectLevelForUser(
          userId: userId, languageId: languageId, levelId: levelId);
      if (levelOk) {
        session.selectedLanguageId.value = languageId;
        session.selectedLevelId.value = levelId;
        return true;
      } else {
        _showErrorSnackbar(
            "Erreur Serveur", "Impossible de sauvegarder votre niveau.");
        return false;
      }
    } catch (e) {
      _showErrorSnackbar(
          "Erreur de connexion", "Le serveur ne répond pas correctement.");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> confirmAndGoToHome() async {
    if (isLoading.value) return;

    if (selectedLanguageLevels.isEmpty && selectedLanguage.value == null) {
      _showErrorSnackbar("Attention", "Sélectionnez au moins une langue.");
      return;
    }

    try {
      isLoading(true);

      if (selectedLanguage.value != null &&
          selectedLevel.value != null &&
          selectedLanguageLevels.isEmpty) {
        await addLanguageLevelToList();
      }

      await loadModules();

      if (isNewUser.value) {
        Get.offAllNamed('/HomeScreen');
      } else {
        Get.offAllNamed('/HomeScreen');
      }
    } catch (e) {
      _showErrorSnackbar("Erreur", "Erreur lors de la confirmation.");
    } finally {
      isLoading(false);
    }
  }

  Future<void> quickGoToHome() async {
    if (isLoading.value) return;

    try {
      isLoading(true);
      await loadModules();
      Get.offAllNamed('/HomeScreen');
    } catch (e) {
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadModules() async {
    try {
      isLoadingModules(true);
      final session = Get.find<SessionController>();
      final String userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : (session.user?.id ?? "");

      if (userId.isEmpty) {
        isLoadingModules(false);
        return;
      }

      final result = await _languageService.fetchModules(userId: userId);
      modules.assignAll(result);
    } catch (_) {
    } finally {
      isLoadingModules(false);
    }
  }

  Future<Map<String, dynamic>?> loadProgression() async {
    try {
      isLoading(true);
      final session = Get.find<SessionController>();
      final String userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : (session.user?.id ?? "");

      final String languageId = session.selectedLanguageId.value;

      if (userId.isEmpty || languageId.isEmpty) {
        return null;
      }

      final result = await _languageService.fetchProgression(
          userId: userId, languageId: languageId);

      if (result != null) {
        progressionData.value = result;
      }

      return result;
    } catch (e) {
      return null;
    } finally {
      isLoading(false);
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
