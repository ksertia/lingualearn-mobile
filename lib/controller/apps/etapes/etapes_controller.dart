import 'package:fasolingo/helpers/services/etapes/etape_service.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart';
import 'package:get/get.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';

class StepsController extends GetxController {
  // Les IDs sont récupérés de façon sûre dans `onInit`
  late String moduleId;
  late String pathId;

  RxBool isLoading = false.obs;
  RxList<StepModel> steps = <StepModel>[].obs;

  // Instances
  final StepsService _stepsService = StepsService();
  final SessionController? session = Get.isRegistered<SessionController>() ? Get.find<SessionController>() : null;

  @override
  void onInit() {
    super.onInit();

    try {
      if (Get.arguments is Map) {
        moduleId = (Get.arguments['moduleId'] ?? "").toString();
        pathId = (Get.arguments['pathId'] ?? "").toString();
      } else {
        moduleId = Get.arguments?.toString() ?? "";
        pathId = "";
      }
    } catch (e) {
      moduleId = "";
      pathId = "";
      print("🚨 [StepsController] Erreur argument : $e");
    }

    fetchSteps();
  }

  Future<void> fetchSteps() async {
    // Sécurité : si pathId est vide, on ne fait rien
    if (pathId.isEmpty) {
      print("🚨 [StepsController] pathId manquant dans les arguments");
      return;
    }

    try {
      isLoading.value = true;
      
      print("🔍 [StepsController] Chargement des étapes pour pathId: $pathId");
      
      // Utiliser l'endpoint qui fonctionne pour charger les étapes d'un parcours
      List<StepModel> results = await StepsService.getStepsByPath(pathId);
      
      if (results.isNotEmpty) {
        // Tri par index (important pour l'ordre pédagogique)
        results.sort((a, b) => a.index.compareTo(b.index));
        steps.assignAll(results);
        print("🏠 [Steps] ${results.length} étapes reçues pour le parcours $pathId");
      } else {
        steps.clear();
        print("⚠️ [Steps] Aucune étape trouvée pour pathId: $pathId");
      }
    } catch (e) {
      print("🚨 [StepsController] Erreur lors du chargement : $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await fetchSteps();
  }
}