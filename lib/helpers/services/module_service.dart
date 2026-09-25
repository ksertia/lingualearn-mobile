import 'package:dio/dio.dart';
import 'package:tibi/models/modules/modul_model.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../controller/apps/session_controller.dart';

class ModuleService {
  static final session = Get.find<SessionController>();
  static bool _prettyLoggerAdded = false;

  static void _ensurePrettyLogger() {
    if (_prettyLoggerAdded) return;
    session.dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 120,
      ),
    );
    _prettyLoggerAdded = true;
  }

  static Future<List<ModuleModel>> getAllModules({
    String? languageId,
    String? levelId,
  }) async {
    try {
      _ensurePrettyLogger();
      final String? userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : session.user?.id;

      if (userId == null || userId.isEmpty) {
        return [];
      }
      final String url = '/users/$userId/modules';
      final Map<String, dynamic> queryParams = {};
      if (languageId != null && languageId.isNotEmpty) {
        queryParams['languageId'] = languageId;
      }
      if (levelId != null && levelId.isNotEmpty) {
        queryParams['levelId'] = levelId;
      }
      final response = await session.dio.get(
        url,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response.statusCode == 200) {
        dynamic data = response.data['data'] ?? response.data;
        List modulesData = [];
        if (data is Map && data['modules'] != null) {
          modulesData = data['modules'];
        } else if (data is List) {
          modulesData = data;
        } else if (data is Map) {
          modulesData = data['data'] ?? [];
        }
        return modulesData.map<ModuleModel>((m) {
          return ModuleModel.fromJson(Map<String, dynamic>.from(m));
        }).toList();
      }
      return [];
    } on DioException catch (_) {
      return [];
    } catch (_) {
      return [];
    }
  }

  // Retourne la progression persistée par le backend (state, startedAt...),
  // ou null si l'appel a échoué (l'appelant garde alors son état optimiste).
  static Future<ModuleProgress?> startModule({
    required String userId,
    required String moduleId,
  }) async {
    try {
      _ensurePrettyLogger();
      final response = await session.dio.post(
        '/users/$userId/modules/$moduleId/start',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data is Map) {
          return ModuleProgress.fromJson(Map<String, dynamic>.from(data));
        }
      }
      return null;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<ModuleProgress?> completeModule({
    required String userId,
    required String moduleId,
  }) async {
    try {
      _ensurePrettyLogger();
      final response = await session.dio.post(
        '/users/$userId/modules/$moduleId/complete',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data is Map) {
          return ModuleProgress.fromJson(Map<String, dynamic>.from(data));
        }
      }
      return null;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<List<ModuleModel>> getModulesByLanguageLevel({
    required String languageId,
    required String levelId,
  }) async {
    try {
      final response = await session.dio.get(
        '/languages/$languageId/levels/$levelId/modules',
      );
      if (response.statusCode == 200) {
        dynamic data = response.data['data'];
        List modulesData = [];
        if (data is Map && data['modules'] != null) {
          modulesData = data['modules'];
        } else if (data is List) {
          modulesData = data;
        }
        return modulesData
            .map<ModuleModel>(
                (m) => ModuleModel.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
      return [];
    } on DioException catch (_) {
      return [];
    } catch (_) {
      return [];
    }
  }
}
