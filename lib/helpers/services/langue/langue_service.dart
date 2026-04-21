import 'package:dio/dio.dart';
import 'package:fasolingo/helpers/constant/app_constant.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import 'package:fasolingo/models/langue/langue_model.dart';
import 'package:get/get.dart'; 
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class LanguageLevelService {
  late final Dio _dio;

  LanguageLevelService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstant.baseURl, 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
    ))..interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        try {
          final session = Get.find<SessionController>();
          
          String? tokenToUse = session.token.value.isNotEmpty 
              ? session.token.value 
              : null;
          
          tokenToUse ??= LocalStorage.getAuthToken();
          
          if (tokenToUse != null && tokenToUse.isNotEmpty && tokenToUse != "null") {
            options.headers['Authorization'] = 'Bearer $tokenToUse';
          }
        } catch (e) {
        }
        return handler.next(options);
      },
    ));
  }

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
    } on DioException catch (e) {
      return [];
    }
  }

  // --- SAUVEGARDE DE LA LANGUE ---
  Future<bool> selectLanguageForUser({required String userId, required String languageId}) async {
    try {
      final String path = '/users/$userId/languages/$languageId/select';
      
      final response = await _dio.post(path);
      
      return (response.statusCode == 201 || response.statusCode == 200);
    } on DioException catch (e) {
      return false;
    }
  }

  // --- RÉCUPÉRATION DES NIVEAUX ---
  Future<List<dynamic>> fetchLevels({required String userId, String? languageId}) async {
    try {
      final response = await _dio.get(
        '/users/$userId/levels'
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
