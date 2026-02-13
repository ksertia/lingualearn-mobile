import 'package:fasolingo/helpers/services/etapes/etape_service.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart';
import 'package:get/get.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';

class StepsController extends GetxController {
  // 1. Récupération des IDs passés par la page précédente
  // On s'attend à : Get.toNamed('/steps', arguments: {'moduleId': '...', 'pathId': '...'})
  final String moduleId = Get.arguments['moduleId'] ?? "";
  final String pathId = Get.arguments['pathId'] ?? "";
  
  RxBool isLoading = false.obs;
  RxList<StepModel> steps = <StepModel>[].obs;

  // Instances
  final StepsService _stepsService = StepsService();
  final SessionController session = Get.find<SessionController>();

  @override
  void onInit() {
    super.onInit();
    fetchSteps();
  }

  Future<void> fetchSteps() async {
    // Sécurité : si les IDs sont vides, on ne fait rien
    if (moduleId.isEmpty || pathId.isEmpty) {
      print("🚨 [StepsController] moduleId ou pathId manquant dans les arguments");
      return;
    }

    try {
      isLoading.value = true;
      
      // 2. On prépare les données requises par ton service
      // On utilise .value pour les RxString du SessionController
      String token = session.token.value;
      String languageId = session.user?.selectedLanguageId ?? "";
      String levelId = session.user?.selectedLevelId ?? "";

      // 3. Appel de ton service avec TOUS les paramètres requis
      List<StepModel> results = await _stepsService.getSteps(
        token: token,
        languageId: languageId,
        levelId: levelId,
        moduleId: moduleId,
        pathId: pathId,
      );
      
      if (results.isNotEmpty) {
        // Tri par index (important pour l'ordre pédagogique)
        results.sort((a, b) => a.index.compareTo(b.index));
        steps.assignAll(results);
      } else {
        steps.clear();
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