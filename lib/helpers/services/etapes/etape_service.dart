import 'dart:convert';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart';
import 'package:get/get.dart';

class StepsService {
  static Future<List<StepModel>> getStepsByPath(String pathId) async {
    try {
      final session = Get.find<SessionController>();
      final String? userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : session.user?.id;

      if (userId == null || userId.isEmpty) {
        return [];
      }

      final String url = '/users/$userId/paths/$pathId/steps';

      final response = await session.dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List? stepsRaw = data['data'];

          if (stepsRaw == null) return [];

          return stepsRaw.map((json) {
            return StepModel.fromJson(Map<String, dynamic>.from(json));
          }).toList();
        }
      }
      
      return [];
    } catch (_) {
      return [];
    }
  }

  // Nouvelle méthode pour charger les étapes d'un parcours spécifique
  static Future<List<StepModel>> getStepsBySpecificPath(String moduleId, String pathId) async {
    try {
      final session = Get.find<SessionController>();
      final String? userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : session.user?.id;

      if (userId == null || userId.isEmpty) {
        return [];
      }

      final String url = '/users/$userId/modules/$moduleId/paths/$pathId/steps';

      final response = await session.dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List? stepsRaw = data['data'];

          if (stepsRaw == null) return [];

          return stepsRaw.map((json) {
            return StepModel.fromJson(Map<String, dynamic>.from(json));
          }).toList();
        }
      }
      
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> startStep({
    required String userId,
    required String stepId,
  }) async {
    try {
      final session = Get.find<SessionController>();
      final response = await session.dio.post(
        '/users/$userId/steps/$stepId/start',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> completeStep({
    required String userId,
    required String stepId,
  }) async {
    try {
      final session = Get.find<SessionController>();
      final response = await session.dio.post(
        '/users/$userId/steps/$stepId/complete',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}