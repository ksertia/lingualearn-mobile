import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/services/langue/langue_service.dart';
import 'package:fasolingo/models/langue/langue_model.dart';
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

  // Variable pour stocker la progression complète
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
        print("⏳ Attente du userId...");
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

    if (selectedLanguageLevels.length >= 2) {
      _showErrorSnackbar(
          "Limite atteinte", "Vous pouvez sélectionner maximum 2 langues.");
      return false;
    }

    final isAlreadySelected =
        selectedLanguageLevels.any((item) => item['languageId'] == languageId);
    if (isAlreadySelected) {
      _showErrorSnackbar(
          "Déjà sélectionnée", "Cette langue est déjà dans votre sélection.");
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

      bool langOk = await _languageService.selectLanguageForUser(
          userId: userId, languageId: languageId);

      if (!langOk) {
        _showErrorSnackbar("Erreur", "Impossible de sauvegarder la langue.");
        return false;
      }

      // Attendre que le serveur finisse de traiter la langue avant de sauvegarder le niveau
      await Future.delayed(const Duration(milliseconds: 500));

      bool levelOk = await _languageService.selectLevelForUser(
          userId: userId, languageId: languageId, levelId: levelId);

      if (!levelOk) {
        _showErrorSnackbar("Erreur", "Langue sauvée mais erreur niveau.");
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
    } catch (e) {
      print("Erreur suppression : $e");
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

      // ✅ IMPORTANT : fallback sur la langue sauvegardée en session
      final String? langId = selectedLanguage.value?.id.isNotEmpty == true
          ? selectedLanguage.value!.id
          : session.selectedLanguageId.value;

      final result = await _languageService.fetchLevels(
        userId: userId,
        languageId: langId,
      );

      languageLevels.assignAll(result);

      print("Niveaux chargés : ${result.length} niveau(x)");
    } catch (e) {
      print("Erreur lors du chargement des niveaux : $e");
    } finally {
      isLoadingLevels(false);
    }
  }

  /// Récupère le nom d'un niveau à partir de son ID
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
    print(
        "Niveau sélectionné localement : ${level is Map ? (level['name'] ?? '') : (level?.name ?? '')}");
  }

  Future<void> loadAllLanguages() async {
    try {
      isLoading(true);
      final session = Get.find<SessionController>();
      final String userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : (session.user?.id ?? "");

      if (userId.isEmpty) {
        print("userId vide, impossible de charger les langues");
        isLoading(false);
        return;
      }

      final result = await _languageService.fetchLanguages(userId: userId);
      allLanguages.assignAll(result);
      print("Langues chargées : ${result.length} langue(s)");
    } catch (e) {
      print("Erreur dans le controller (loadAllLanguages) : $e");
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

      // La langue devrait déjà être enregistrée dans confirmLanguageSelection.
      bool levelOk = await _languageService.selectLevelForUser(
          userId: userId, languageId: languageId, levelId: levelId);

      if (levelOk) {
        session.selectedLanguageId.value = languageId;
        session.selectedLevelId.value = levelId;
        return true;
      } else {
        print("Échec lors de la sauvegarde du niveau.");
        _showErrorSnackbar(
            "Erreur Serveur", "Impossible de sauvegarder votre niveau.");
        return false;
      }
    } catch (e) {
      print("Erreur critique lors de la synchronisation : $e");
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
    } catch (e) {
      print("Erreur lors du chargement des modules : $e");
    } finally {
      isLoadingModules(false);
    }
  }

  /// Charge la progression complète (inclut les niveaux) via l'API
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
