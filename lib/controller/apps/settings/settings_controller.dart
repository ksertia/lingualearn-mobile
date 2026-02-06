import 'dart:developer';
import 'dart:ui';
import 'package:fasolingo/controller/apps/session_controller.dart'; // Import important
import 'package:fasolingo/helpers/extensions/string.dart';
import 'package:fasolingo/helpers/localizations/language.dart';
import 'package:fasolingo/helpers/services/auth_services.dart';
import 'package:fasolingo/helpers/services/setting_service.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/helpers/utils/app_snackbar.dart';
import 'package:fasolingo/models/user_model.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final isDarkMode = false.obs;
  RxBool isLoading = false.obs;
  
  // Variable pour stocker l'utilisateur
  Rx<UserModel?> user = Rx<UserModel?>(null);

  RxList<String> languageList = <String>["french", "english", "moore", "dioula"].obs;
  final RxInt selectedLanguageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedLanguageIndex();
    fetchUserProfile();
  }

  // Récupère le profil pour l'afficher dans les paramètres (SettingsScreen)
  Future<void> fetchUserProfile() async {
    try {
      isLoading(true);
      final userData = await SettingService.getUserProfile();
      if (userData != null) {
        user.value = userData;
      }
    } catch (e) {
      log("Erreur lors de la récupération du profil: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> _loadSelectedLanguageIndex() async {
    final int? savedIndex = await LocalStorage.getLanguageIndex();
    if (savedIndex != null && savedIndex >= 0 && savedIndex < languageList.length) {
      selectedLanguageIndex.value = savedIndex;
    } else {
      selectedLanguageIndex.value = 0;
      await LocalStorage.setLanguageIndex(0);
    }
  }

  Future<void> selectLanguage(int index) async {
    selectedLanguageIndex.value = index;
    await LocalStorage.setLanguageIndex(index);
    if (index < Language.languages.length) {
      Get.updateLocale(Language.languages[index] as Locale);
    } else {
      Get.updateLocale(Language.languages.first as Locale);
    }
  }

  // --- LA LOGIQUE DE DÉCONNEXION COMPLÈTE ---
  Future<void> onLogout() async {
    try {
      isLoading(true);
      print("➡️ [Logout] Début de la procédure de déconnexion");

      // 1. Appel API via ton SettingService (POST /api/v1/auth/logout)
      final isLogout = await SettingService.userSignOut();
      print("➡️ [Logout] Réponse serveur: $isLogout");

      // 2. Nettoyage, que l'API réponde true ou non (pour ne pas bloquer l'utilisateur)
      if (isLogout) {
        // Vider le LocalStorage (Token, UserID, etc.)
        await LocalStorage.removeLoggedInUser();
        
        // Vider la Session en mémoire vive (Get.find)
        final session = Get.find<SessionController>();
        session.user = null;
        // session.isLoggedIn = false;
        // session.langueChoisie = "";

        print("➡️ [Logout] Nettoyage local terminé. Redirection...");
        
        // 3. Message de succès
        appSnackbar(heading: "Déconnexion", message: "À bientôt !");

        // 4. Retour à l'écran de login et effacement de l'historique
        Get.offAllNamed('/auth/login');
      } else {
        appSnackbar(heading: "Erreur", message: "Le serveur n'a pas pu valider la déconnexion.");
      }
    } catch (e, st) {
      print("❌ [Logout] Erreur fatale: $e\n$st");
      appSnackbar(heading: "Erreur", message: "Une erreur est survenue lors de la déconnexion.");
    } finally {
      isLoading(false);
    }
  }
}