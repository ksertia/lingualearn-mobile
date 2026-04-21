import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart';
import 'package:get/get.dart';

class LearningPathService {
  static Future<List<LearningPathModel>> getPathsByModule(
      String moduleId) async {
    try {
      final session = Get.find<SessionController>();
      final String? userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : session.user?.id;

      if (userId == null || userId.isEmpty) {
        return [];
      }

      final String url = '/users/$userId/paths?moduleId=$moduleId';
      final response = await session.dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List? pathsRaw = data['data'];

          if (pathsRaw == null) return [];

          return pathsRaw.map((json) {
            return LearningPathModel.fromJson(Map<String, dynamic>.from(json));
          }).toList();
        }
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<LearningPathModel>> getPathsByUser(String userId) async {
    try {
      final session = Get.find<SessionController>();

      final String url = '/users/$userId/paths';
      final response = await session.dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List? pathsRaw = data['data'];
          if (pathsRaw == null) return [];

          return pathsRaw
              .map((json) =>
                  LearningPathModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        }
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  // Nouvelle méthode pour charger les parcours d'un module spécifique
  static Future<List<LearningPathModel>> getPathsBySpecificModule(
      String moduleId) async {
    try {
      final session = Get.find<SessionController>();
      final String? userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : session.user?.id;

      if (userId == null || userId.isEmpty) {
        return [];
      }

      final String url = '/users/$userId/modules/$moduleId/paths';
      final response = await session.dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List? pathsRaw = data['data'];

          if (pathsRaw == null) return [];

          return pathsRaw.map((json) {
            return LearningPathModel.fromJson(Map<String, dynamic>.from(json));
          }).toList();
        }
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> startPath({
    required String userId,
    required String pathId,
  }) async {
    try {
      final session = Get.find<SessionController>();
      final response = await session.dio.post(
        '/users/$userId/paths/$pathId/start',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> completePath({
    required String userId,
    required String pathId,
  }) async {
    try {
      final session = Get.find<SessionController>();
      final response = await session.dio.post(
        '/users/$userId/paths/$pathId/complete',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
