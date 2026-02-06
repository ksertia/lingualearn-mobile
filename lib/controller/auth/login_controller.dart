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

      // Appel au service d'authentification
      final response = await AuthService.loginUser(credentials);

      if (response != null && response['success'] == true) {
        final apiData = response['data']; // Contient 'user', 'tokens' et 'currentLanguage'
        final String accessToken = apiData['tokens']['accessToken'];

        // 1. CRÉATION DE L'UTILISATEUR VIA LE MODÈLE
        // On passe 'apiData' car notre factory UserModel.fromJson va chercher 'currentLanguage' dedans
        final loggedInUser = UserModel.fromJson(apiData);

        // 2. STOCKAGE PERSISTANT (LocalStorage)
        await LocalStorage.setAuthToken(accessToken);
        await LocalStorage.setUserID(loggedInUser.id);
        await LocalStorage.setEmail(loggedInUser.email);
        
        String fullName = "${loggedInUser.firstName} ${loggedInUser.lastName}".trim();
        await LocalStorage.setUserName(fullName.isEmpty ? "Apprenant" : fullName);
        LocalStorage.setAlwaysLoggedIn(isChecked);

        // 3. MISE À JOUR DE LA SESSION GLOBALE
        final session = Get.find<SessionController>();
        session.updateUser(loggedInUser, accessToken);

        isLoading.value = false;

        // 4. NAVIGATION INTELLIGENTE
        // On utilise les champs calculés par le UserModel pour décider où aller
        
        if (loggedInUser.selectedLanguageId == null) {
          // Cas A : L'utilisateur n'a jamais choisi de langue (ex: Mooré, Dioula...)
          print("➡️ Direction : Bienvenue (Nouveau profil)");
          Get.offAllNamed('/bienvenue'); 
        } 
        else if (loggedInUser.selectedLevelId == null) {
          // Cas B : Langue choisie mais pas encore de niveau/progrès (Basique, Intermédiaire...)
          print("➡️ Direction : Sélection du niveau (Incomplet)");
          Get.offAllNamed('/selection'); // Assure-toi que cette route correspond à ton choix de niveau
        } 
        else {
          // Cas C : Profil complet, l'utilisateur a déjà commencé son apprentissage
          print("✅ Direction : Home (Déjà configuré)");
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
      appSnackbar(
        heading: "Erreur", 
        message: "Impossible de se connecter. Vérifiez votre connexion réseau."
      );
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}