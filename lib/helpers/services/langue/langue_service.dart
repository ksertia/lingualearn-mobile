import 'package:dio/dio.dart';
import 'package:tibi/models/langue/langue_model.dart';
import 'package:get/get.dart';
import 'package:tibi/controller/apps/session_controller.dart';

class LanguageLevelService {
  Dio get _dio => Get.find<SessionController>().dio;

  // --- RÉCUPÉRATION DES LANGUES ---
  Future<List<LanguageModel>> fetchLanguages({required String userId}) async {
    try {
      final response = await _dio.get('/users/$userId/languages'); 
      if (response.statusCode == 200) {
        final dynamic responseData = response.data['data'];
        if (responseData == null || responseData is! List) return [];
        return responseData
    .map((item) => LanguageModel.fromJson(item as Map<String, dynamic>))
    .where((lang) => lang.isActive)
    .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // --- SAUVEGARDE DE LA LANGUE ---
  Future<bool> selectLanguageForUser({required String userId, required String languageId}) async {
    final String path = '/users/$userId/languages/$languageId/select';
    int attempts = 0;

    while (true) {
      try {
        final response = await _dio.post(path);
        return (response.statusCode == 201 || response.statusCode == 200);
      } on DioException catch (e) {
        final int? status = e.response?.statusCode;
        if (status == 500 && attempts == 0) {
          attempts++;
          await Future.delayed(const Duration(milliseconds: 800));
          continue;
        }
        return false;
      }
    }
  }

  // --- RÉCUPÉRATION DES NIVEAUX ---
  Future<List<dynamic>> fetchLevels({required String userId, String? languageId}) async {
    try {
      final response = await _dio.get(
        '/users/$userId/levels',
        queryParameters: languageId != null && languageId.isNotEmpty
            ? {'languageId': languageId}
            : null,
      );
      if (response.statusCode == 200) {
        final levels = response.data['data'] as List<dynamic>;
      return levels
    .map((l) => LevelModel.fromJson(l))
    .where((level) => level.isActive)
    .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- SAUVEGARDE DU NIVEAU ---
  Future<bool> selectLevelForUser({
    required String userId,
    required String languageId,
    required String levelId,
  }) async {
    final String path = '/users/$userId/levels/$levelId/select';
    int attempts = 0;

    while (true) {
      try {
        final response = await _dio.post(
          path,
          data: {
            'languageId': languageId,
          },
        );

        return (response.statusCode == 201 || response.statusCode == 200);
      } on DioException catch (e) {
        final int? status = e.response?.statusCode;

        if (status == 500 && attempts == 0) {
          attempts++;
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }
        return false;
      }
    }
  }

  // --- RÉCUPÉRATION DES MODULES ---
  Future<List<dynamic>> fetchModules({required String userId}) async {
    try {
      final response = await _dio.get('/users/$userId/modules'); 
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchProgression({required String userId, required String languageId}) async {
    try {
      final response = await _dio.get('/progression/user/$userId/language/$languageId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
