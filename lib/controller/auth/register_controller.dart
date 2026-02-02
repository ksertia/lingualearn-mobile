import 'package:fasolingo/helpers/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../models/user_model.dart';
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

      if (response != null) {
        appSnackbar(
          heading: "Félicitations", 
          message: "Votre compte a été créé avec succès !"
        );

        await Future.delayed(const Duration(seconds: 2));
         Get.toNamed('/login');
      } else {

        appSnackbar(
          heading: "Erreur", 
          message: "Impossible de créer le compte. L'email est peut-être déjà utilisé."
        );
      }
    } on DioException catch (e) {

    } catch (e) {
      print("❗ Erreur RegisterController : $e");
      appSnackbar(heading: "Erreur", message: "Une erreur technique est survenue.");
    } finally {
      isLoading.value = false;
    }
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