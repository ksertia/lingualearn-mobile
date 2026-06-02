import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/remote/api_service.dart';
import 'package:fasolingo/models/progression/progression_detail_model.dart';

class ProgressionDetailService {
  /// GET /progression/user/{userId}/language/{languageId}
  static Future<ProgressionDetailModel?> getProgression({
    required String userId,
    required String languageId,
  }) async {
    final Response<Map<String, dynamic>?> response = await APIService.get(
      path: '/progression/user/$userId/language/$languageId',
    );

    if (response.statusCode == 200 &&
        response.data != null &&
        response.data!['success'] == true) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return ProgressionDetailModel.fromJson(data);
      }
    }
    return null;
  }
}
