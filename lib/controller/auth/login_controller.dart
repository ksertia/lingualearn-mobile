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
          // Utilisez la réponse complète de /users/me
          loggedInUser = UserModel.fromJson(profileRes.data['data']);
          print("✅ Profil récupéré de /users/me");
        } else {
          // Fallback sur les données de login
          loggedInUser = UserModel.fromJson(apiData);
          print("⚠️ Utilisation des données de login");
        }

        // Log détaillé des données critiques
        print("🔍 VÉRIFICATION DES DONNÉES UTILISATEUR:");
        print("📊 ID: ${loggedInUser.id}");
        print("📊 Email: ${loggedInUser.email}");
        print("📊 Prénom: ${loggedInUser.firstName}");
        print("📊 Nom: ${loggedInUser.lastName}");
        print("📊 selectedLanguageId: '${loggedInUser.selectedLanguageId}'");
        print("📊 selectedLevelId: '${loggedInUser.selectedLevelId}'");

        // Sauvegarde locale
        await LocalStorage.setUserID(loggedInUser.id);
        await LocalStorage.setEmail(loggedInUser.email);
        String fullName = "${loggedInUser.firstName} ${loggedInUser.lastName}".trim();
        await LocalStorage.setUserName(fullName.isEmpty ? "Apprenant" : fullName);
        await LocalStorage.setAlwaysLoggedIn(isChecked);

        // Mise à jour de la session
        session.updateUser(loggedInUser, accessToken);
        isLoading.value = false;

        await Future.delayed(const Duration(milliseconds: 100));

        // Logique de redirection basée sur les données
        bool hasLanguage = loggedInUser.selectedLanguageId != null && 
                           loggedInUser.selectedLanguageId!.isNotEmpty;
        bool hasLevel = loggedInUser.selectedLevelId != null && 
                        loggedInUser.selectedLevelId!.isNotEmpty;
        
        print("🔀 LOGIQUE DE REDIRECTION:");
        print("📊 a une langue: $hasLanguage");
        print("📊 a un niveau: $hasLevel");

        if (hasLanguage && hasLevel) {
          print("✅ Redirection vers HomeScreen (langue et niveau sélectionnés)");
          Get.offAllNamed('/HomeScreen');
        }
        else if (hasLanguage) {
          print("➡️ Redirection vers sélection du niveau (langue sélectionnée, niveau manquant)");
          Get.offAllNamed('/selection');
        }
        else {
          print("➡️ Redirection vers bienvenue (nouvel utilisateur)");
          Get.offAllNamed('/bienvenue');
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