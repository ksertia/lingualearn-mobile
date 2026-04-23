import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../helpers/storage/local_storage.dart';
import '../../helpers/utils/app_snackbar.dart';
import '../../helpers/services/auth_services.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  RxBool isLoading = false.obs;
  bool showPassword = false;
  bool isChecked = false;

  void onChangeShowPassword() {
    showPassword = !showPassword;
    update();
  }

  void onChangeCheckBox(bool? value) {
    isChecked = value ?? false;
    update();
  }

  Future<void> onLogin() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final Map<String, dynamic> credentials = {
        "loginInfo": email.text.trim(),
        "password": password.text,
      };

      final response = await AuthService.loginUser(credentials);
      if (response != null && response['success'] == true) {
        final apiData = response['data'];
        final String accessToken = apiData['tokens']['accessToken'];
        final session = Get.find<SessionController>();
        await LocalStorage.setAuthToken(accessToken);
        final profileRes = await session.dio.get('/users/me');
        UserModel loggedInUser;
        if (profileRes.statusCode == 200 &&
            profileRes.data['success'] == true) {
          loggedInUser = UserModel.fromJson(profileRes.data['data']);
        } else {
          loggedInUser = UserModel.fromJson(apiData);
        }
        await LocalStorage.setUserID(loggedInUser.id);
        await LocalStorage.setEmail(loggedInUser.email);
        String fullName =
            "${loggedInUser.firstName} ${loggedInUser.lastName}".trim();
        await LocalStorage.setUserName(
            fullName.isEmpty ? "Apprenant" : fullName);
        await LocalStorage.setAlwaysLoggedIn(isChecked);
        session.updateUser(loggedInUser, accessToken);
        isLoading.value = false;
        await Future.delayed(const Duration(milliseconds: 100));
        bool hasLanguage = loggedInUser.selectedLanguageId != null &&
            loggedInUser.selectedLanguageId!.isNotEmpty;
        bool hasLevel = loggedInUser.selectedLevelId != null &&
            loggedInUser.selectedLevelId!.isNotEmpty;
        if (hasLanguage && hasLevel) {
          Get.offAllNamed('/HomeScreen');
        } else if (hasLanguage) {
          Get.offAllNamed('/selection');
        } else {
          Get.offAllNamed('/bienvenue');
        }
      } else {
        isLoading.value = false;
        appSnackbar(
            heading: "Échec",
            message: response != null
                ? response['message']
                : "Identifiants incorrects.");
      }
    } catch (e) {
      isLoading.value = false;
      appSnackbar(
          heading: "Erreur", message: "Problème de connexion au serveur.");
    }
  }

  /// Clear form fields (for post-reset UX)
  void clear() {
    email.clear();
    password.clear();
    update();
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
