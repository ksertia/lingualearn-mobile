import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../controller/apps/session_controller.dart';
import '../../../models/themes/sub_theme_model.dart';

class SubThemeService {
  Dio get _dio => Get.find<SessionController>().dio;

  Future<List<SubThemeModel>> getSubThemesByTheme(String themeId, {String? userId}) async {
    final response = await _dio.get(
      '/sub-themes/theme/$themeId',
      queryParameters: (userId != null && userId.isNotEmpty) ? {'userId': userId} : null,
    );

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

  // ── À faire développer côté backend, sur le même modèle que les modules ────
  // POST /users/{userId}/sub-themes/{subThemeId}/start
  // POST /users/{userId}/sub-themes/{subThemeId}/complete

  Future<SubThemeProgress?> startSubTheme({
    required String userId,
    required String subThemeId,
  }) async {
    try {
      final response = await _dio.post('/users/$userId/sub-themes/$subThemeId/start');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data is Map) {
          return SubThemeProgress.fromJson(Map<String, dynamic>.from(data));
        }
      }
      return null;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<SubThemeProgress?> completeSubTheme({
    required String userId,
    required String subThemeId,
  }) async {
    try {
      final response = await _dio.post('/users/$userId/sub-themes/$subThemeId/complete');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data is Map) {
          return SubThemeProgress.fromJson(Map<String, dynamic>.from(data));
        }
      }
      return null;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }
}
