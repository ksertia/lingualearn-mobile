import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/helpers/services/error_handling.dart';
import '../storage/local_storage.dart';

class SettingService {
  /// ************************* User Sign Out Data *************************///
  static Future<bool> userSignOut() async {
    try {
      final url = "${AppConstant.baseURl}/auth/logout";
      final token = await LocalStorage.getAuthToken();
      print("[Logout API] URL: $url");
      print("[Logout API] Token: $token");
      final response = await Dio().post(
        url,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
      print("[Logout API] StatusCode: ${response.statusCode}");
      print("[Logout API] Data: ${response.data}");
      return response.statusCode == 200;
    } on DioException catch (e) {
      print("[Logout API] DioException: ${e.message}");
      letMeHandleAllErrors(e);
      return false;
    }
  }
}
