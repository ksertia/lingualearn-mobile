import 'package:dio/dio.dart';
import 'package:fasolingo/models/modules/modul_model.dart';
import 'package:get/get.dart';
import '../../controller/apps/session_controller.dart';

class ModuleService {
  static final session = Get.find<SessionController>();

  static Future<List<ModuleModel>> getAllModules() async {
    try {
      // Utiliser d'abord les RxString dans la session (mis à jour après sélection),
      // puis fallback sur les valeurs présentes dans `session.user`.
      final String? langId = session.selectedLanguageId.value.isNotEmpty
          ? session.selectedLanguageId.value
          : session.user?.selectedLanguageId;
      final String? levelId = session.selectedLevelId.value.isNotEmpty
          ? session.selectedLevelId.value
          : session.user?.selectedLevelId;

      if (langId == null || langId.isEmpty || levelId == null || levelId.isEmpty) {
        print("🚨 [ModuleService] languageId ou levelId manquant dans la session !");
        return [];
      }

      final String url = '/languages/$langId/levels/$levelId/modules';

      print("🚀 [Module API] Appel URL : $url");
      final response = await session.dio.get(url);

      if (response.statusCode == 200) {
        // Le backend peut renvoyer soit { success: true, data: { modules: [...] } }
        // soit directement { success: true, data: [...] }
        dynamic data = response.data['data'] ?? response.data;
        List modulesData = [];

        if (data is Map && data['modules'] != null) {
          modulesData = data['modules'];
        } else if (data is List) {
          modulesData = data;
        } else if (data is Map) {
          // Parfois le back renvoie un object contenant la liste sous une clé inattendue
          modulesData = data['data'] ?? [];
        }

        return modulesData.map<ModuleModel>((m) {
          return ModuleModel.fromJson(Map<String, dynamic>.from(m));
        }).toList();
      }

      print("⚠️ [Module API] Échec : ${response.data['message'] ?? 'Réponse incomplète'}");
      return [];
    } on DioException catch (e) {
      print("🚨 [Module API] Erreur Dio (${e.response?.statusCode}) : ${e.message}");
      return [];
    } catch (e) {
      print("🚨 [Module API] Erreur critique : $e");
      return [];
    }
  }
}