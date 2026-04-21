import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/controller/my_controller.dart';
import 'package:fasolingo/helpers/services/languages_service.dart';
import 'package:fasolingo/helpers/utils/app_snackbar.dart';
import 'package:fasolingo/model/language_model.dart';
import 'package:fasolingo/model/level_model.dart';
import 'package:get/get.dart';

class ChildLanguageAssignController extends MyController {
  final RxBool isFetchingLanguages = false.obs;
  final RxBool isFetchingLevels = false.obs;
  final RxBool isAssigning = false.obs;

  final RxList<LanguageModel> languages = <LanguageModel>[].obs;
  final RxList<LevelModel> levels = <LevelModel>[].obs;

  final Rxn<LanguageModel> selectedLanguage = Rxn<LanguageModel>();
  final RxString selectedLevelId = ''.obs;

  Future<void> fetchLanguages() async {
    try {
      isFetchingLanguages(true);
      final session = Get.find<SessionController>();

      final res = await LanguagesService.getLanguages(token: session.token.value);
      if (res != null) languages.assignAll(res);
    } catch (_) {
    } finally {
      isFetchingLanguages(false);
    }
  }

  Future<void> fetchLevels(String languageId) async {
    try {
      isFetchingLevels(true);
      levels.clear();
      selectedLevelId.value = '';

      final session = Get.find<SessionController>();

      final res = await LanguagesService.getLanguageLevels(
        languageId,
        token: session.token.value,
      );
      if (res != null) levels.assignAll(res);
    } catch (_) {
    } finally {
      isFetchingLevels(false);
    }
  }

  Future<bool> assign({
    required String childId,
    required String languageId,
    required String levelId,
  }) async {
    try {
      isAssigning(true);
      final session = Get.find<SessionController>();

      var ok = await LanguagesService.assignLanguageLevel(
        childId: childId,
        languageId: languageId,
        levelId: levelId,
        token: session.token.value,
      );

      if (!ok) {
        final preOk = await LanguagesService.assignLanguageToChild(
          childId: childId,
          languageId: languageId,
          token: session.token.value,
        );

        if (preOk) {
          ok = await LanguagesService.assignLanguageLevel(
            childId: childId,
            languageId: languageId,
            levelId: levelId,
            token: session.token.value,
          );
        }
      }

      if (ok) {
        appSnackbar(
          heading: 'Succès',
          message: 'Langue assignée avec succès',
        );
        return true;
      }

      appSnackbar(
        heading: 'Erreur',
        message: "Impossible d'assigner la langue",
      );
      return false;
    } catch (_) {
      appSnackbar(
        heading: 'Erreur',
        message: "Une erreur est survenue",
      );
      return false;
    } finally {
      isAssigning(false);
    }
  }
}
