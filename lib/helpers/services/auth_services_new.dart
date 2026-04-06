import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:get/get.dart';

class AuthService {
  static bool isLoggedIn = false;
  static String? currentToken;

  static final Dio dio = Dio(BaseOptions(
    baseUrl: AppConstant.baseURl, 
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  ///******************************** Login User API ********************************///
  static Future<Map<String, dynamic>?> loginUser(Map<String, dynamic> data) async {
    try {
      final url = "${AppConstant.baseURl}/auth/login";

      print("\n===================== Webservice Login envoyé =====================");
      print("=================== URL  : $url");
      print("=================== Body : ${jsonEncode(data)}");
      print("===============================================================\n");

      final response = await dio.post(url, data: data);

      print("===================== Réponse Login reçue =====================");
      print("===================== Statut Code : ${response.statusCode}");
      print("===================== Data         : ${response.data}");
      print("=============================================================\n");

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        print('✅ Connexion réussie');
        return response.data;
      } else {
        print('❌ Échec de connexion : ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      _handleDioError(e, "Login");
      return null;
    } catch (e) {
      print("❗ Exception critique Login : $e");
      return null;
    }
  }

  ///******************************** Register User API ********************************///
  static Future<Map<String, dynamic>?> registerUser(Map<String, dynamic> data) async {
    try {
      final url = "${AppConstant.baseURl}/auth/register";

      print("\n===================== Webservice Register envoyé =====================");
      print("=================== URL  : $url");
      print("=================== Body : ${jsonEncode(data)}");
      print("===============================================================\n");

      final response = await dio.post(url, data: data);

      print("===================== Réponse Register reçue =====================");
      print("===================== Statut Code : ${response.statusCode}");
      print("===================== Data         : ${response.data}");
      print("=============================================================\n");

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        print('✅ Inscription réussie');
        return response.data;
      } else {
        print('❌ Échec Inscription : ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      _handleDioError(e, "Register");
      return null;
    } catch (e) {
      print("❗ Exception critique Register : $e");
      return null;
    }
  }

  ///******************************** Forgot Password Request API ********************************///
  static Future<Map<String, dynamic>?> forgotPassword(Map<String, dynamic> data) async {
    try {
      final url = "${AppConstant.baseURl}/auth/forgot-password";

      print("\n===================== Webservice Forgot Password envoyé =====================");
      print("=================== URL  : $url");
      print("=================== Body : ${jsonEncode(data)}");
      print("===============================================================\n");

      final response = await dio.post(url, data: data);

      print("===================== Réponse Forgot Password reçue =====================");
      print("===================== Statut Code : ${response.statusCode}");
      print("===================== Data         : ${response.data}");
      print("=============================================================\n");

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        print('✅ Forgot Password request success');
        return response.data;
      } else {
        print('❌ Forgot Password failed : ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      _handleDioError(e, "ForgotPassword");
      return null;
    } catch (e) {
      print("❗ Exception critique ForgotPassword : $e");
      return null;
    }
  }

  ///******************************** Verify OTP API ********************************///
  static Future<Map<String, dynamic>?> verifyOtp(Map<String, dynamic> data) async {
    try {
      final url = "${AppConstant.baseURl}/auth/verify-otp";

      print("\n===================== Webservice Verify OTP envoyé =====================");
      print("=================== URL  : $url");
      print("=================== Body : ${jsonEncode(data)}");
      print("===============================================================\n");

      final response = await dio.post(url, data: data);

      print("===================== Réponse Verify OTP reçue =====================");
      print("===================== Statut Code : ${response.statusCode}");
      print("===================== Data         : ${response.data}");
      print("=============================================================\n");

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        print('✅ OTP verified success');
        return response.data;
      } else {
        print('❌ OTP verification failed : ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      _handleDioError(e, "VerifyOtp");
      return null;
    } catch (e) {
      print("❗ Exception critique VerifyOtp : $e");
      return null;
    }
  }

  ///******************************** Reset Password API ********************************///
  static Future<Map<String, dynamic>?> resetPassword(Map<String, dynamic> data) async {
    try {
      final url = "${AppConstant.baseURl}/auth/reset-password";

      print("\n===================== Webservice Reset Password envoyé =====================");
      print("=================== URL  : $url");
      print("=================== Body : ${jsonEncode(data)}");
      print("===============================================================\n");

      final response = await dio.post(url, data: data);

      print("===================== Réponse Reset Password reçue =====================");
      print("===================== Statut Code : ${response.statusCode}");
      print("===================== Data         : ${response.data}");
      print("=============================================================\n");

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        print('✅ Password reset success');
        return response.data;
      } else {
        print('❌ Password reset failed : ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      _handleDioError(e, "ResetPassword");
      return null;
    } catch (e) {
      print("❗ Exception critique ResetPassword : $e");
      return null;
    }
  }

  ///******************************** Gestion des erreurs Dio ********************************///
  static void _handleDioError(DioException e, String method) {
    print("=================== Erreur réseau $method ===================");
    print("Type : ${e.type}");
    print("Message : ${e.message}");
    if (e.response != null) {
      print("Code de retour : ${e.response?.statusCode}");
      print("Données d'erreur : ${e.response?.data}");
    }
    print("==============================================================\n");
  }
}
