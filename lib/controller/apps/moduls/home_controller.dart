import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/services/module_service.dart';
import 'package:fasolingo/models/modules/modul_model.dart'; 
import 'package:get/get.dart';

class HomeController extends GetxController {
  final session = Get.find<SessionController>();
  
  RxBool isLoading = false.obs;
  
  RxList<ModuleModel> filteredModules = <ModuleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadModules();
  }

  Future<void> loadModules() async {
    try {
      isLoading.value = true;
      
      List<ModuleModel> allModules = await ModuleService.getAllModules();
      
      String? userLevelId = session.user?.selectedLevelId;
      
      print("🏠 [Home] Tentative de filtrage pour le LevelID : $userLevelId");

      var modulesMatched = allModules.where((m) {
        return m.levelId == userLevelId && m.isActive;
      }).toList();

      if (modulesMatched.isNotEmpty) {
        print("✅ [Home] ${modulesMatched.length} modules correspondent exactement au niveau.");
        filteredModules.assignAll(modulesMatched);
      } else {
        print("⚠️ [Home] Aucun module trouvé pour l'ID $userLevelId. Affichage de secours activé.");
        
        var activeModules = allModules.where((m) => m.isActive).toList();
        filteredModules.assignAll(activeModules);
        
        print("ℹ️ [Home] ${activeModules.length} modules actifs affichés par défaut.");
      }
      
    } catch (e) {
      print("🚨 [Home] Erreur lors du chargement : $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await loadModules();
  }
}