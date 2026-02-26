import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordController extends GetxController {
  var isLoading = false.obs;

  Future<void> sendResetEmail(String email) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar("Erreur", "Email invalide",
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red, 
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final String rawUrl = "${AppConstant.baseURl}/auth/forgot-password";
      final url = Uri.parse(rawUrl);

      print("Tentative sur : $url");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "accept": "*/*",
        },
        body: jsonEncode({"loginInfo": email.trim()}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        Get.snackbar("Succès", responseData['message'] ?? "Lien envoyé !",
            backgroundColor: Colors.green, colorText: Colors.white);
            
        Get.toNamed("/newPassword", arguments: email);
      } else {
        print("Erreur ${response.statusCode}: ${response.body}");
        
        String errorMsg = "Erreur serveur (${response.statusCode})";
        try {
          final errorBody = jsonDecode(response.body);
          errorMsg = errorBody['message'] ?? errorMsg;
        } catch (_) {}

        Get.snackbar("Erreur", errorMsg,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("Exception: $e");
      Get.snackbar("Erreur", "Impossible de joindre le serveur. Vérifiez la connexion.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}