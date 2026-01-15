import 'dart:developer';
import 'dart:ui';
import 'package:fasolingo/helpers/extensions/string.dart';
import 'package:fasolingo/helpers/localizations/language.dart';
import 'package:fasolingo/helpers/services/auth_services.dart';
import 'package:fasolingo/helpers/services/setting_service.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/helpers/utils/app_snackbar.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class SettingsController extends GetxController {
  final isDarkMode = false.obs;
  // final selectedLanguage = ''.obs;
  RxBool isLoading = false.obs;
  RxList<String> languageList = <String>["french".tr(), "english".tr(), "moore".tr(), "dioula".tr()].obs;
  final RxInt selectedLanguageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedLanguageIndex();
  }

  Future<void> _loadSelectedLanguageIndex() async {
    final int? savedIndex = await LocalStorage.getLanguageIndex();

    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < languageList.length) {
      selectedLanguageIndex.value = savedIndex;
    } else {
      selectedLanguageIndex.value = 0;
      await LocalStorage.setLanguageIndex(0);
    }
  }

  // Method to handle language selection and save the index
  Future<void> selectLanguage(int index) async {
    selectedLanguageIndex.value = index;
    await LocalStorage.setLanguageIndex(index);
    if (index < Language.languages.length) {
      Get.updateLocale(Language.languages[index] as Locale);
    } else {
      Get.updateLocale(Language.languages.first as Locale);
    }
  }

  // Future<void> onLogout() async {
  //   try {
  //     AuthService.isLoggedIn = false;
  //     final isLogout = await SettingService.userSignOut();
  //
  //     if (isLogout) {
  //       await LocalStorage.removeLoggedInUser();
  //       Get.offAndToNamed('/auth/login');
  //     }
  //   } catch (e, st) {
  //     log("Logout error: $e\n$st");
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  Future<void> onLogout() async {
    try {
      print("➡️ [Logout] Début logout");
      AuthService.isLoggedIn = false;

      final isLogout = await SettingService.userSignOut();
      print("➡️ [Logout] API logout résultat: $isLogout");

      if (isLogout) {
        await LocalStorage.removeLoggedInUser();
        print("➡️ [Logout] Redirection vers /auth/login");
        Get.offAllNamed('/auth/login');
      } else {
        print("⚠️ [Logout] userSignOut a retourné false");
      }
    } catch (e, st) {
      print("❌ [Logout] Erreur: $e\n$st");
    } finally {
      isLoading(false);
    }
  }
}
