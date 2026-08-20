import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../controller/apps/session_controller.dart';
import '../../../models/themes/sub_theme_model.dart';

class SubThemeService {
  Dio get _dio => Get.find<SessionController>().dio;

  Future<List<SubThemeModel>> getSubThemesByTheme(String themeId) async {
    final response = await _dio.get('/sub-themes/theme/$themeId');

    if (response.data['success'] != true) {
      throw Exception(
          'Réponse serveur inattendue (success=false) : ${response.data}');
    }

    final raw = response.data['data'];
    if (raw == null) return [];

    return (raw as List)
        .map((s) =>
            SubThemeModel.fromJson(Map<String, dynamic>.from(s as Map)))
        .toList();
  }
}
