import 'package:flutter/material.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/services/etapes/etape_service.dart';
import 'package:fasolingo/helpers/services/parcoure/parcoure_service.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart';
import 'package:get/get.dart';

class StepsController extends GetxController {
  late String moduleId;
  late String pathId;
  late String userId;
  late bool showAllSteps;

  RxBool isLoading = false.obs;
  RxInt currentPage = 0.obs;
  RxList<dynamic> items = <dynamic>[].obs;

  late PageController pageController;
  final StepsService _stepsService = StepsService();
  final SessionController? session = Get.isRegistered<SessionController>()
      ? Get.find<SessionController>()
      : null;

  @override
  void onInit() {
    super.onInit();

    moduleId = "";
    pathId = "";
    userId = session?.userId.value ?? "";
    showAllSteps = false;

    try {
      if (Get.arguments is Map) {
        final Map args = Get.arguments as Map;
        moduleId = (args['moduleId'] ?? "").toString();
        pathId = (args['pathId'] ?? "").toString();
        userId = (args['userId'] ?? userId).toString();
        showAllSteps = args['showAllSteps'] == true;
      } else {
        moduleId = Get.arguments?.toString() ?? "";
        pathId = "";
      }
    } catch (e) {
      moduleId = "";
      pathId = "";
      userId = session?.userId.value ?? "";
      showAllSteps = false;
      print("🚨 [StepsController] Erreur argument : $e");
    }

    pageController = PageController();
    fetchSteps();
  }

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void goToPage(int page) {
    if (pageController.hasClients) {
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> fetchSteps() async {
    try {
      isLoading.value = true;

      if (showAllSteps) {
        if (userId.isEmpty) {
          userId = session?.userId.value ?? "";
        }

        if (userId.isEmpty) {
          print(
              "🚨 [StepsController] userId manquant pour charger toutes les étapes");
          items.clear();
          return;
        }

        print(
            "🔍 [StepsController] Chargement de toutes les étapes pour l'utilisateur $userId");
        final paths = await LearningPathService.getPathsByUser(userId);
        final List<dynamic> allItems = [];

        paths.sort((a, b) => a.index.compareTo(b.index));

        for (final path in paths) {
          // Ajouter le parcours comme en-tête
          allItems.add(path);

          final List<StepModel> pathSteps =
              await StepsService.getStepsByPath(path.id);
          if (pathSteps.isNotEmpty) {
            pathSteps.sort((a, b) => a.index.compareTo(b.index));
            allItems.addAll(pathSteps);
          }
        }

        if (allItems.isNotEmpty) {
          items.assignAll(allItems);
          print(
              "🏠 [Steps] ${allItems.whereType<StepModel>().length} étapes reçues pour tous les parcours");
        } else {
          items.clear();
          print(
              "⚠️ [Steps] Aucune étape trouvée pour les parcours de l'utilisateur $userId");
        }
      } else {
        if (pathId.isEmpty) {
          print("🚨 [StepsController] pathId manquant dans les arguments");
          items.clear();
          return;
        }

        print(
            "🔍 [StepsController] Chargement des étapes pour pathId: $pathId");
        final List<StepModel> results =
            await StepsService.getStepsByPath(pathId);

        if (results.isNotEmpty) {
          results.sort((a, b) => a.index.compareTo(b.index));
          items.assignAll(results);
          print(
              "🏠 [Steps] ${results.length} étapes reçues pour le parcours $pathId");
        } else {
          items.clear();
          print("⚠️ [Steps] Aucune étape trouvée pour pathId: $pathId");
        }
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
