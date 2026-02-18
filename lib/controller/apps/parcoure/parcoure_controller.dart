import 'package:fasolingo/helpers/services/parcoure/parcoure_service.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart';
import 'package:get/get.dart';

class ParcoursSelectionController extends GetxController {
  late String moduleId; 
  
  RxBool isLoading = false.obs;
  RxList<LearningPathModel> paths = <LearningPathModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    try {
      if (Get.arguments is Map) {
        moduleId = Get.arguments['moduleId'].toString();
      } else {
        moduleId = Get.arguments.toString();
      }
    } catch (e) {
      moduleId = "";
      print(" [ParcoursController] Erreur argument : $e");
    }

    fetchPaths();
  }

  Future<void> fetchPaths() async {
    if (moduleId.isEmpty || moduleId == "null") return;

    try {
      isLoading.value = true;
      
      print(" [ParcoursController] Chargement des parcours pour moduleId: $moduleId");
      
      // Utiliser l'endpoint spécifique pour charger les parcours d'un module donné
      List<LearningPathModel> results = await LearningPathService.getPathsBySpecificModule(moduleId);
      
      if (results.isNotEmpty) {
        results.sort((a, b) => (a.index).compareTo(b.index));
        paths.assignAll(results);
        print(" [ParcoursController] ${results.length} parcours reçus pour le module $moduleId");
      } else {
        paths.clear();
        print(" [ParcoursController] Aucun parcours trouvé pour le module $moduleId");
      }
    } catch (e) {
      print(" [ParcoursController] Erreur lors du chargement : $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await fetchPaths();
  }
}