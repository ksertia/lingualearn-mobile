import 'package:dio/dio.dart';
import 'package:tibi/controller/apps/session_controller.dart';
import 'package:tibi/models/user_progress/user_progress_model.dart';
import 'package:get/get.dart';

class UserProgressService {
  static Future<List<UserProgressEntry>?> getMyProgress({
    String? token,
  }) async {
    try {
      final dio = Get.find<SessionController>().dio;
      final response = await dio.get('/users/my-progress');

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
