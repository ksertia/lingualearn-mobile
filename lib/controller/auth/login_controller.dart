import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:fasolingo/controller/my_controller.dart';
import 'package:fasolingo/helpers/services/auth_services.dart';
import 'package:fasolingo/helpers/services/error_handling.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/helpers/utils/app_snackbar.dart';
import 'package:fasolingo/helpers/my_widgets/my_form_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/views/apps/home/home_page.dart';

class LoginController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();
  GlobalKey<FormState> formKey = GlobalKey();
  bool showPassword = false, loading = false, isChecked = false;
  RxBool isLoading = false.obs;

  TextEditingController email = TextEditingController();
  TextEditingController fullName = TextEditingController();
  TextEditingController password = TextEditingController();

  final firstName = LocalStorage.getUserName ?? '';
  RxInt timerSeconds = 3.obs;

  void onChangeShowPassword() {
    showPassword = !showPassword;
    update();
  }

  void onChangeCheckBox(bool? value) {
    isChecked = value ?? isChecked;
    update();
  }

  Future<void> startTimerAndLoadData() async {
    isLoading(true);
    await Future.delayed(const Duration(milliseconds: 300));
    isLoading(false);
  }

  //=================== Connexion classique
  Future<void> onLogin({String? email, required String password}) async {
    isLoading(true);
    try {
      final response = await AuthService.loginUser({
        "email": email,
        "password": password,
      });

      if (response != null && response['token'] != null) {
        if (isChecked) {
          LocalStorage.setAlwaysLoggedIn(true);
        } else {
          LocalStorage.setAlwaysLoggedIn(false);
        }
        await LocalStorage.setAuthToken(response['token']);
        await LocalStorage.setEmail(email ?? "");
        await LocalStorage.setPassword(password);
        await LocalStorage.setUserID(response['user']['id']);
        await LocalStorage.setUserName(
            "${response['user']['firstName']} ${response['user']['lastName']}");
        log("=================== Login réussi, redirection...");
        isLoading(false);

        if (LocalStorage.isAppLink() &&
            LocalStorage.getAppLinkStationID() != null) {
          final stationId = LocalStorage.getAppLinkStationID()!;
          LocalStorage.setAppLink(false);
          LocalStorage.setAppLinkStationID('');
          Get.offAllNamed('/stationDetails',
              arguments: {'stationId': stationId});
        } else {
          Get.to(() => HomeScreen());
        }
      } else {
        isLoading(false);
        appSnackbar(
          heading: "Erreur",
          message: "Identifiants invalides ou réponse inattendue.",
        );
      }
    } on DioException catch (e) {
      isLoading(false);
      letMeHandleAllErrors(e);
    }
  }

  //=================== Connexion via empreinte digitale

  void goToForgotPassword() {
    Get.toNamed('/auth/forgot_password');
  }

  void gotoRegister() {
    Get.offAndToNamed('/auth/register');
  }

  void gotoLogin() {
    Get.offAndToNamed('/auth/login');
  }
}
