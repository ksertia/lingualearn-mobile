import 'dart:developer';
import 'dart:ui';
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
  
  // Variable pour stocker l'utilisateur ---
  Rx<UserModel?> user = Rx<UserModel?>(null);

  RxList<String> languageList = <String>["french", "english", "moore", "dioula"].obs;
  final RxInt selectedLanguageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedLanguageIndex();
    fetchUserProfile();
  }

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

  Future<void> onLogout() async {
    try {
      isLoading(true);
      print("➡️ [Logout] Début logout");
      AuthService.isLoggedIn = false;

      final isLogout = await SettingService.userSignOut();
      print("➡️ [Logout] API logout résultat: $isLogout");

      if (isLogout) {
        await LocalStorage.removeLoggedInUser();
        print("➡️ [Logout] Redirection vers /auth/login");
        Get.offAllNamed('/auth/login');
      }
    } catch (e, st) {
      print("❌ [Logout] Erreur: $e\n$st");
    } finally {
      isLoading(false);
    }
  }
}