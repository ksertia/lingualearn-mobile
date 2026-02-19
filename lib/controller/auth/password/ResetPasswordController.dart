import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordController extends GetxController {
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  // Retourne true si succès, false sinon
  Future<bool> resetPassword(String token, String password) async {
    if (token.isEmpty) {
      Get.snackbar("Erreur", "Jeton de réinitialisation manquant",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    try {
      isLoading.value = true;
      final url = Uri.parse("${AppConstant.baseURl}/auth/reset-password");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "accept": "*/*",
        },
        body: jsonEncode({
          "token": token,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Échec", errorData['message'] ?? "Lien invalide ou expiré",
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar("Erreur", "Connexion au serveur impossible",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}