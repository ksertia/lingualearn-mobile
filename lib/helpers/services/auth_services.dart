import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';

class AuthService {
  static bool isLoggedIn = false;
  static String? currentToken;
  static String? collectorId;
  static String? currentAgencyId;
  static String? currentUserId;

  static final Dio dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 5),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static Future<Map<String, dynamic>?> loginUser(
      Map<String, dynamic> data) async {
    try {
      final url = "${AppConstant.baseURl}/auth/login";
      final response = await dio.post(url, data: jsonEncode(data));

      if (response.statusCode == 200 && response.data != null) {
        isLoggedIn = true;
        currentToken = response.data['token'];
        collectorId = response.data['user']['_id'];
        currentAgencyId = response.data['user']['agencyId'];
        currentUserId = response.data['user']['id'];
        print(
            'Connexion réussie. Token: $currentToken, CollectorId: $collectorId, AgencyId: $currentAgencyId');
        return response.data;
      } else {
        print('Échec de connexion. Code: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('Erreur réseau: ${e.message}');
      return null;
    } catch (e, stackTrace) {
      print('Exception: $e');
      print('StackTrace: $stackTrace');
      return null;
    }
  }
}
