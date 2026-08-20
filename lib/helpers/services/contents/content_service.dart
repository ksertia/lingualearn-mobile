import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../controller/apps/session_controller.dart';
import '../../../models/contents/content_model.dart';

class ContentService {
  Dio get _dio => Get.find<SessionController>().dio;

  Future<List<ContentModel>> getContentsBySubTheme(String subThemeId) async {
    final response = await _dio.get('/contents/sub-theme/$subThemeId');

    if (response.data['success'] != true) {
      throw Exception(
          'Réponse serveur inattendue (success=false) : ${response.data}');
    }

    final raw = response.data['data'];
    if (raw == null) return [];

    return (raw as List)
        .map((c) =>
            ContentModel.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList();
  }
}
