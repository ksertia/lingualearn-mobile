import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

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
  ))..interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

  ///******************************** Login User API ********************************///
  static Future<Map<String, dynamic>?> loginUser(Map<String, dynamic> data) async {
    try {
      final url = "${AppConstant.baseURl}/auth/login";
      final response = await dio.post(url, data: data);

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return response.data;
      } else {
        return null;
      }
    } on DioException catch (e) {
      _handleDioError(e, "Login");
      return null;
    } catch (_) {
      return null;
    }
  }

  ///******************************** Register User API ********************************///
  static Future<Map<String, dynamic>?> registerUser(Map<String, dynamic> data) async {
    try {
      final url = "${AppConstant.baseURl}/auth/register";
      final response = await dio.post(url, data: data);

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return response.data;
      } else {
        return null;
      }
    } on DioException catch (e) {
      _handleDioError(e, "Register");
      return null;
    } catch (_) {
      return null;
    }
  }

  ///******************************** Forgot Password Request API ********************************///
  static Future<Map<String, dynamic>?> forgotPassword(Map<String, dynamic> data) async {
    try {
      final url = "${AppConstant.baseURl}/auth/forgot-password";
      final response = await dio.post(url, data: data);

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return response.data;
      } else {
        return null;
      }
    } on DioException catch (e) {
      _handleDioError(e, "ForgotPassword");
      return null;
    } catch (_) {
      return null;
    }
  }

  ///******************************** Verify OTP API ********************************///
  static Future<Map<String, dynamic>?> verifyOtp(Map<String, dynamic> data) async {
    try {
      final url = "${AppConstant.baseURl}/auth/verify-otp";
      final response = await dio.post(url, data: data);

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return response.data;
      } else {
        return null;
      }
    } on DioException catch (e) {
      _handleDioError(e, "VerifyOtp");
      return null;
    } catch (_) {
      return null;
    }
  }

  ///******************************** Reset Password API ********************************///
  static Future<Map<String, dynamic>?> resetPassword(Map<String, dynamic> data) async {
    try {
      final url = "${AppConstant.baseURl}/auth/reset-password";
      final response = await dio.post(url, data: data);

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return response.data;
      } else {
        return null;
      }
    } on DioException catch (e) {
      _handleDioError(e, "ResetPassword");
      return null;
    } catch (_) {
      return null;
    }
  }

  ///******************************** Gestion des erreurs Dio ********************************///
  static void _handleDioError(DioException e, String method) {
    Get.log('Network error ($method): ${e.message}');
  }
}
