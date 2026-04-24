import 'package:fasolingo/helpers/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../helpers/utils/app_snackbar.dart';

class RegisterController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  RxBool isLoading = false.obs;
  RxString selectedAccountType = "learner".obs; 
  bool showPassword = false;

  void toggleShowPassword() {
    showPassword = !showPassword;
    update();
  }

  void setSelectedAccountType(String value) {
    selectedAccountType.value = value;
  }

  Future<void> onRegister() async {
    if (!formKey.currentState!.validate()) return;

    if (password.text != confirmPassword.text) {
      appSnackbar(heading: "Erreur", message: "Les mots de passe ne correspondent pas.");
      return;
    }

    isLoading.value = true;

    try {
  
      final Map<String, dynamic> userData = {
        "firstName": firstName.text.trim(),
        "lastName": lastName.text.trim(),
        "email": email.text.trim(),
        "phone": phone.text.trim(),
        "password": password.text.trim(),
        "accountType": selectedAccountType.value,
        "username": null, 
        "parentId": null,
      };

      final response = await AuthService.registerUser(userData);

      if (response != null && response['success'] == true) {
        appSnackbar(
          heading: "Félicitations",
          message: "Votre compte a été créé avec succès !",
          snackbarState: SnackbarState.success,
        );
        await Future.delayed(const Duration(seconds: 2));
        Get.toNamed('/login');
      } else if (response != null) {
        // Erreur API — on affiche un message précis selon le problème identifié
        final rawMsg = response['message']?.toString() ?? '';
        appSnackbar(
          heading: "Échec de l'inscription",
          message: _parseRegisterError(rawMsg),
          snackbarState: SnackbarState.danger,
        );
      } else {
        // Pas de réponse — erreur réseau
        appSnackbar(
          heading: "Erreur",
          message: "Connexion impossible. Vérifiez votre connexion internet.",
          snackbarState: SnackbarState.danger,
        );
      }
    } on DioException catch (_) {
      appSnackbar(heading: "Erreur", message: "Problème de connexion au serveur.", snackbarState: SnackbarState.danger);
    } catch (e) {
      appSnackbar(heading: "Erreur", message: "Une erreur technique est survenue.", snackbarState: SnackbarState.danger);
    } finally {
      isLoading.value = false;
    }
  }

  /// Traduit le message brut de l'API en message lisible pour l'utilisateur,
  /// en identifiant précisément le champ ou le type d'erreur concerné.
  String _parseRegisterError(String rawMsg) {
    final msg = rawMsg.toLowerCase();

    // Email déjà utilisé
    if (msg.contains('email') &&
        (msg.contains('exist') ||
            msg.contains('already') ||
            msg.contains('utilisé') ||
            msg.contains('déjà'))) {
      return "Cette adresse email est déjà utilisée. Essayez de vous connecter.";
    }

    // Numéro de téléphone déjà utilisé
    if ((msg.contains('phone') ||
            msg.contains('téléphone') ||
            msg.contains('numero') ||
            msg.contains('numéro')) &&
        (msg.contains('exist') ||
            msg.contains('already') ||
            msg.contains('utilisé') ||
            msg.contains('déjà'))) {
      return "Ce numéro de téléphone est déjà enregistré.";
    }

    // Format email invalide
    if (msg.contains('email') &&
        (msg.contains('invalid') ||
            msg.contains('invalide') ||
            msg.contains('format') ||
            msg.contains('valid'))) {
      return "L'adresse email n'est pas valide. Vérifiez le format (exemple@mail.com).";
    }

    // Numéro de téléphone invalide
    if ((msg.contains('phone') ||
            msg.contains('téléphone') ||
            msg.contains('numéro')) &&
        (msg.contains('invalid') || msg.contains('invalide'))) {
      return "Le numéro de téléphone n'est pas valide.";
    }

    // Champ requis manquant
    if (msg.contains('required') ||
        msg.contains('requis') ||
        msg.contains('obligatoire') ||
        msg.contains('missing')) {
      return "Tous les champs sont obligatoires. Veuillez les remplir entièrement.";
    }

    // Mot de passe trop court ou invalide
    if (msg.contains('password') || msg.contains('mot de passe')) {
      return "Le mot de passe ne respecte pas les exigences de sécurité.";
    }

    // Message brut de l'API s'il est lisible, sinon message générique
    return rawMsg.isNotEmpty
        ? rawMsg
        : "Impossible de créer le compte. Vérifiez vos informations.";
  }

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}