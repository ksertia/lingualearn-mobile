import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/helpers/services/error_handling.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../storage/local_storage.dart';

class ChangePasswordService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstant.baseURl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
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

  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final url = "${AppConstant.baseURl}/auth/change-password";
      final token = await LocalStorage.getAuthToken();

      final response = await _dio.post(
        url,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      letMeHandleAllErrors(e);
      return false;
    } catch (_) {
      return false;
    }
  }
}
