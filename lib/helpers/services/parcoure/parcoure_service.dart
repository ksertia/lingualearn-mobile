import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart'; 
import 'package:get/get.dart';

class LearningPathService {
  // Il est préférable de récupérer la session à l'intérieur de la méthode 
  // pour éviter des problèmes d'initialisation au démarrage.
  
  static Future<List<LearningPathModel>> getPathsByModule(String moduleId) async {
    try {
      final session = Get.find<SessionController>();
      final String? userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : session.user?.id;

      if (userId == null || userId.isEmpty) {
        print("🚨 [LearningPathService] userId manquant dans la session !");
        return [];
      }

      final String url = '/users/$userId/paths?moduleId=$moduleId';
      
      print("🚀 [Path API] Appel URL : $url");
      print("🔑 [Path API] UserId: $userId");
      print("🔑 [Path API] ModuleId: $moduleId");
      print("🔑 [Path API] Token présent: ${session.token.value.isNotEmpty}");

      final response = await session.dio.get(url);
      
      print("📊 [Path API] Status Code: ${response.statusCode}");
      print("📊 [Path API] Response Data: ${response.data}");

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
    } catch (e) {
      print("🚨 [LearningPathService] Erreur API : $e");
      return [];
    }
  }

  static Future<List<LearningPathModel>> getPathsByUser(String userId) async {
    try {
      final session = Get.find<SessionController>();

      final String url = '/users/$userId/paths';
      print("🚀 [Path API] Appel URL : $url");

      final response = await session.dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List? pathsRaw = data['data'];
          if (pathsRaw == null) return [];

          return pathsRaw.map((json) => LearningPathModel.fromJson(Map<String, dynamic>.from(json))).toList();
        }
      }

      return [];
    } catch (e) {
      print("🚨 [LearningPathService] Erreur API getPathsByUser: $e");
      return [];
    }
  }

  // Nouvelle méthode pour charger les parcours d'un module spécifique
  static Future<List<LearningPathModel>> getPathsBySpecificModule(String moduleId) async {
    try {
      final session = Get.find<SessionController>();
      final String? userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : session.user?.id;

      if (userId == null || userId.isEmpty) {
        print("🚨 [LearningPathService] userId manquant dans la session !");
        return [];
      }

      final String url = '/users/$userId/modules/$moduleId/paths';
      
      print("🚀 [Path API] Appel URL spécifique : $url");
      print("🔑 [Path API] UserId: $userId");
      print("🔑 [Path API] ModuleId spécifique: $moduleId");
      print("🔑 [Path API] Token présent: ${session.token.value.isNotEmpty}");

      final response = await session.dio.get(url);
      
      print("📊 [Path API] Status Code: ${response.statusCode}");
      print("📊 [Path API] Response Data: ${response.data}");

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
    } catch (e) {
      print("🚨 [LearningPathService] Erreur API getPathsBySpecificModule: $e");
      return [];
    }
  }
}