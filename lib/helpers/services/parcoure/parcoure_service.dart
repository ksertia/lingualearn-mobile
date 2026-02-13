import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart'; 
import 'package:get/get.dart';

class LearningPathService {
  // Il est préférable de récupérer la session à l'intérieur de la méthode 
  // pour éviter des problèmes d'initialisation au démarrage.
  
  static Future<List<LearningPathModel>> getPathsByModule(String moduleId) async {
    try {
      final session = Get.find<SessionController>();
      String langId = session.selectedLanguageId.value;
      String levelId = session.selectedLevelId.value;

      final String url = '/languages/$langId/levels/$levelId/modules/$moduleId/paths';
      
      print("🚀 [Path API] Appel URL : $url");

      final response = await session.dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        // On vérifie la structure de manière ultra-sécurisée
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List? pathsRaw = data['data']['paths'];

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
}