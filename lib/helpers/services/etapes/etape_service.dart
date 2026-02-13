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
        print("🚨 [StepsService] userId manquant dans la session !");
        return [];
      }

      final String url = '/users/$userId/paths/$pathId/steps';
      
      print("🚀 [Steps API] Appel URL : $url");
      print("🔑 [Steps API] UserId: $userId");
      print("🔑 [Steps API] PathId: $pathId");
      print("🔑 [Steps API] Token présent: ${session.token.value.isNotEmpty}");

      final response = await session.dio.get(url);
      
      print("📊 [Steps API] Status Code: ${response.statusCode}");
      print("📊 [Steps API] Response Data: ${response.data}");

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
    } catch (e) {
      print("🚨 [StepsService] Erreur API : $e");
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
        print("🚨 [StepsService] userId manquant dans la session !");
        return [];
      }

      final String url = '/users/$userId/modules/$moduleId/paths/$pathId/steps';
      
      print("🚀 [Steps API] Appel URL spécifique : $url");
      print("🔑 [Steps API] UserId: $userId");
      print("🔑 [Steps API] ModuleId: $moduleId");
      print("🔑 [Steps API] PathId spécifique: $pathId");
      print("🔑 [Steps API] Token présent: ${session.token.value.isNotEmpty}");

      final response = await session.dio.get(url);
      
      print("📊 [Steps API] Status Code: ${response.statusCode}");
      print("📊 [Steps API] Response Data: ${response.data}");

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
    } catch (e) {
      print("🚨 [StepsService] Erreur API getStepsBySpecificPath: $e");
      return [];
    }
  }
}