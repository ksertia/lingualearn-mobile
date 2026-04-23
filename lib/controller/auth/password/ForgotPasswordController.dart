import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/helpers/services/auth_services.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = false.obs;

  Future<void> requestOtp() async {
    String login = emailController.text.trim();
    if (login.isEmpty) {
      Get.snackbar("Attention", "Veuillez entrer votre identifiant",
          backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return;
    }
    isLoading.value = true;
    final data = {"loginInfo": login};
    final response = await AuthService.forgotPassword(data);
    isLoading.value = false;

    if (response != null) {
      Get.toNamed('/otpCode');
    } else {
      Get.snackbar("Erreur", "Compte introuvable ou erreur serveur.");
    }
  }

  Future<void> verifyOtp() async {
    String code = otpController.text.trim();
    if (code.isEmpty) {
      Get.snackbar("Code requis", "Veuillez saisir le code reçu.");
      return;
    }

    isLoading.value = true;
    final data = {
      "loginInfo": emailController.text.trim(),
      "otp": code,
    };
    final response = await AuthService.verifyOtp(data);
    isLoading.value = false;

    if (response != null) {
      Get.toNamed('/newPassword');
    } else {
      Get.snackbar("Erreur", "Le code est incorrect ou a expiré.");
    }
  }

  Future<void> resetPassword() async {
    String pass = newPasswordController.text;
    String confirm = confirmPasswordController.text;

    if (pass.isEmpty || pass.length < 6) {
      Get.snackbar("Sécurité", "6 caractères minimum requis.");
      return;
    }

    if (pass != confirm) {
      Get.snackbar("Attention", "Les mots de passe ne sont pas identiques.");
      return;
    }

    isLoading.value = true;
    final data = {
      "loginInfo": emailController.text.trim(),
      "otp": otpController.text.trim(),
      "password": pass,
    };
    final response = await AuthService.resetPassword(data);
    isLoading.value = false;

    if (response != null) {
      Get.offAllNamed('/login');
      Get.snackbar("Succès", "Mot de passe modifié avec succès.",
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar("Erreur", "Échec de l'opération.");
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
