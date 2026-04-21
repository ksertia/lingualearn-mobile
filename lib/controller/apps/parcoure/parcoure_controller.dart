import 'package:fasolingo/helpers/services/module_service.dart';
import 'package:fasolingo/helpers/services/parcoure/parcoure_service.dart';
import 'package:fasolingo/models/modules/modul_model.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart';
import 'package:get/get.dart';

class ParcoursSelectionController extends GetxController {
  late String moduleId;
  late String userId;
  late String languageId;
  late String levelId;
  late bool showAllPaths;

  RxBool isLoading = false.obs;
  RxList<dynamic> items = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();

    moduleId = "";
    userId = "";
    languageId = "";
    levelId = "";
    showAllPaths = false;

    try {
      if (Get.arguments is Map) {
        final Map args = Get.arguments as Map;
        moduleId = (args['moduleId'] ?? "").toString();
        userId = (args['userId'] ?? "").toString();
        languageId = (args['languageId'] ?? "").toString();
        levelId = (args['levelId'] ?? "").toString();
        showAllPaths = args['showAllPaths'] == true || moduleId.isEmpty;
      } else if (Get.arguments != null) {
        moduleId = Get.arguments.toString();
        showAllPaths = moduleId.isEmpty;
      } else {
        showAllPaths = true;
      }
    } catch (e) {
      moduleId = "";
      showAllPaths = true;
      print(" [ParcoursController] Erreur argument : $e");
    }

    fetchPaths();
  }

  Future<void> fetchPaths() async {
    try {
      isLoading.value = true;
      items.clear();

      if (showAllPaths) {

        final modules = await ModuleService.getAllModules();

        if (modules.isNotEmpty) {
          modules.sort((a, b) => a.index.compareTo(b.index));

          for (final module in modules) {
            // Add module header
            items.add(module);

            // Load paths for this module
            final paths = await LearningPathService.getPathsBySpecificModule(module.id);
            if (paths.isNotEmpty) {
              paths.sort((a, b) => a.index.compareTo(b.index));
              items.addAll(paths);
            }
          }


        } else {
          print(" [ParcoursController] Aucun module trouvé");
        }
      } else {
        if (moduleId.isEmpty || moduleId == "null") {
          print(
              " [ParcoursController] moduleId vide, impossible de charger les parcours spécifiques.");
        } else {
          print(
              " [ParcoursController] Chargement des parcours pour moduleId: $moduleId");
          final results =
              await LearningPathService.getPathsBySpecificModule(moduleId);

          if (results.isNotEmpty) {
            results.sort((a, b) => a.index.compareTo(b.index));
            items.assignAll(results);
            print(
                " [ParcoursController] ${results.length} parcours reçus pour le module $moduleId");
          } else {
            print(
                " [ParcoursController] Aucun parcours trouvé pour le module $moduleId");
          }
        }
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
