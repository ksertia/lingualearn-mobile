import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/helpers/services/error_handling.dart';
import 'package:fasolingo/models/user_model.dart';
import '../storage/local_storage.dart';

class SettingService {
  static Future<UserModel?> getUserProfile() async {
    try {
      final url = "${AppConstant.baseURl}/auth/profile"; 
      final token = await LocalStorage.getAuthToken();

      print("[Profile API] URL: $url");

      final response = await Dio().get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      print("[Profile API] StatusCode: ${response.statusCode}");
      
if (response.statusCode == 200) {
  final dynamic userData = response.data['data']['user']; 
  
  if (userData != null) {
    return UserModel.fromJson(userData);
  }
}
      return null;
    } on DioException catch (e) {
      print("[Profile API] DioException: ${e.message}");
      letMeHandleAllErrors(e);
      return null;
    } catch (e) {
      print("[Profile API] Erreur inconnue: $e");
      return null;
    }
  }

  /// ************************* User Sign Out Data *************************///
  static Future<bool> userSignOut() async {
    try {
      final url = "${AppConstant.baseURl}/auth/logout";
      final token = await LocalStorage.getAuthToken();
      
      print("[Logout API] URL: $url");
      
      final response = await Dio().post(
        url,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
      
      print("[Logout API] StatusCode: ${response.statusCode}");
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("[Logout API] DioException: ${e.message}");
      letMeHandleAllErrors(e);
      return false;
    }
  }
}