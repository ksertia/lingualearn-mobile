import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
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

  void onChangeShowPassword() { showPassword = !showPassword; update(); }
  void onChangeCheckBox(bool? value) { isChecked = value ?? false; update(); }

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
        final String token = apiData['tokens']['accessToken'];
        final userJson = apiData['user'];

        if (userJson != null) {
          final user = UserModel.fromJson(userJson);

          await LocalStorage.setAuthToken(token);
          await LocalStorage.setUserID(userJson['id'] ?? ""); 
          String fullName = "${user.firstName ?? ''} ${user.lastName ?? ''}".trim();
          await LocalStorage.setUserName(fullName.isEmpty ? "Utilisateur" : fullName);
          LocalStorage.setAlwaysLoggedIn(isChecked);

          final session = Get.find<SessionController>();

          isLoading.value = false;

          if (session.vientDeLaDecouverte) {
            print("🚀 Redirection : Mode Découverte activé");
            Get.offAllNamed('/niveau');
          } else {
            print("👋 Redirection : Premier accès direct");
            Get.offAllNamed('/bienvenue');
          }
        }
      } else {
        isLoading.value = false;
        appSnackbar(heading: "Échec", message: "Identifiants incorrects.");
      }
    } catch (e) {
      isLoading.value = false;
      appSnackbar(heading: "Erreur", message: "Une erreur est survenue.");
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}