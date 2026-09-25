import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../controller/apps/session_controller.dart';
import '../../../models/themes/theme_model.dart';

class ThemeService {
  Dio get _dio => Get.find<SessionController>().dio;

  // GET /themes/level/{levelId} — les thèmes sont désormais rattachés
  // directement au niveau (plus de couche module).
  Future<List<ThemeModel>> getThemesByLevel(String levelId, {String? userId}) async {
    final response = await _dio.get(
      '/themes/level/$levelId',
      queryParameters: (userId != null && userId.isNotEmpty) ? {'userId': userId} : null,
    );

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

  // ── À faire développer côté backend, sur le même modèle que les modules ────
  // POST /users/{userId}/themes/{themeId}/start
  // POST /users/{userId}/themes/{themeId}/complete
  // Réponse attendue identique à celle de POST .../modules/{moduleId}/start :
  // { id, userId, themeId, progressPercentage, startedAt, completedAt,
  //   lastAccessedAt, createdAt, updatedAt, state }

  Future<ThemeProgress?> startTheme({
    required String userId,
    required String themeId,
  }) async {
    try {
      final response = await _dio.post('/users/$userId/themes/$themeId/start');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data is Map) {
          return ThemeProgress.fromJson(Map<String, dynamic>.from(data));
        }
      }
      return null;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<ThemeProgress?> completeTheme({
    required String userId,
    required String themeId,
  }) async {
    try {
      final response = await _dio.post('/users/$userId/themes/$themeId/complete');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data is Map) {
          return ThemeProgress.fromJson(Map<String, dynamic>.from(data));
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
