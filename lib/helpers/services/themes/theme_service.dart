import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../controller/apps/session_controller.dart';
import '../../../models/themes/theme_model.dart';

class ThemeService {
  Dio get _dio => Get.find<SessionController>().dio;

  Future<List<ThemeModel>> getThemesByModule(String moduleId) async {
    final response = await _dio.get('/themes/module/$moduleId');

    if (response.data['success'] != true) {
      throw Exception(
          'Réponse serveur inattendue (success=false) : ${response.data}');
    }

    final raw = response.data['data'];
    if (raw == null) return [];

    return (raw as List)
        .map((t) => ThemeModel.fromJson(Map<String, dynamic>.from(t as Map)))
        .toList();
  }
}
