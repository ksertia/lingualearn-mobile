import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/models/user_progress/user_progress_model.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class UserProgressService {
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

  static Future<List<UserProgressEntry>?> getMyProgress({
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        '/users/my-progress',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final data = response.data;
        final Map<String, dynamic> map = data is Map
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{};

        final list = map['data'];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => UserProgressEntry.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      return null;
    } on DioException catch (e) {
      Get.log('UserProgressService error: ${e.message}');
      return null;
    } catch (e) {
      Get.log('UserProgressService unexpected error: $e');
      return null;
    }
  }
}
