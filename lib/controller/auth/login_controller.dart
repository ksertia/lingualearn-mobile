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

        print("⏳ Récupération du profil via /users/me...");
        final profileRes = await session.dio.get('/users/me');
        
        UserModel loggedInUser;
        if (profileRes.statusCode == 200 && profileRes.data['success'] == true) {
          loggedInUser = UserModel.fromJson(profileRes.data['data']);
        } else {
          loggedInUser = UserModel.fromJson(apiData);
        }

        print("🔍 Vérification des listes de vérité sur le serveur...");
        
        List userLangs = [];
        List userLevels = [];

        try {
          final langRes = await session.dio.get('/users/${loggedInUser.id}/languages');
          userLangs = langRes.data['data'] ?? [];
        } catch (e) {
          print("ℹ️ Info : Pas de langues trouvées (404 ou vide), c'est un nouveau.");
        }

        try {
          final levelRes = await session.dio.get('/users/${loggedInUser.id}/levels');
          userLevels = levelRes.data['data'] ?? [];
        } catch (e) {
          print("ℹ️ Info : Aucun niveau trouvé (404 ou vide).");
        }

        await LocalStorage.setUserID(loggedInUser.id);
        await LocalStorage.setEmail(loggedInUser.email);
        String fullName = "${loggedInUser.firstName} ${loggedInUser.lastName}".trim();
        await LocalStorage.setUserName(fullName.isEmpty ? "Apprenant" : fullName);
        LocalStorage.setAlwaysLoggedIn(isChecked);

        var vraieLangueLocale = userLangs.firstWhere(
          (l) => l['language']['code'] != 'fr', 
          orElse: () => null
        );

        if (vraieLangueLocale != null) {
          loggedInUser = loggedInUser.copyWith(
            selectedLanguageId: vraieLangueLocale['languageId']
          );
        }
        
        session.updateUser(loggedInUser, accessToken);
        isLoading.value = false;

        if (vraieLangueLocale == null) {
          print("➡️ Direction : Bienvenue (Liste vide ou 404)");
          Get.offAllNamed('/bienvenue');
        } 
        else if (userLevels.isEmpty) {
          print("➡️ Direction : Sélection du niveau");
          Get.offAllNamed('/selection');
        } 
        else {
          print("✅ Direction : HomeScreen");
          Get.offAllNamed('/HomeScreen');
        }

      } else {
        isLoading.value = false;
        appSnackbar(
            heading: "Échec",
            message: response != null ? response['message'] : "Identifiants incorrects.");
      }
    } catch (e) {
      isLoading.value = false;
      print("❌ Erreur Critique Login: $e");
      appSnackbar(heading: "Erreur", message: "Problème de connexion au serveur.");
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}