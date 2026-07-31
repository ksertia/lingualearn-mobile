import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tibi/controller/apps/session_controller.dart';
import 'package:tibi/helpers/services/etapes/etape_service.dart';
import 'package:tibi/helpers/services/module_service.dart';
import 'package:tibi/helpers/services/parcoure/parcoure_service.dart';
import 'package:tibi/helpers/services/souscription/sousciption_service.dart';
import 'package:tibi/models/parcoure/parcour_model.dart';
import 'package:get/get.dart';

class StepsController extends GetxController {
  late String moduleId;
  late String pathId;
  late String userId;
  late bool showAllSteps;

  RxBool isLoading = false.obs;
  RxBool isSubscriptionActive = true.obs;
  RxInt currentPage = 0.obs;
  RxList<dynamic> items = <dynamic>[].obs;

  late PageController pageController;
  final SessionController? session = Get.isRegistered<SessionController>()
      ? Get.find<SessionController>()
      : null;

  bool _isAutoChecking = false;

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
    }

    pageController = PageController();
    fetchSteps();
    checkSubscription();
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
          items.clear();
          return;
        }

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
        } else {
          items.clear();
        }
      } else {
        if (pathId.isEmpty) {
          items.clear();
          return;
        }

        final List<StepModel> results =
            await StepsService.getStepsByPath(pathId);

        // Charge aussi le parcours lui-même : sans lui, `page.path` reste
        // null côté UI et le bouton "Parcours terminé !" (qui appelle
        // completePath) ne s'affiche jamais.
        LearningPathModel? currentPathModel;
        if (moduleId.isNotEmpty) {
          final paths =
              await LearningPathService.getPathsBySpecificModule(moduleId);
          for (final p in paths) {
            if (p.id == pathId) {
              currentPathModel = p;
              break;
            }
          }
        }

        final List<dynamic> allItems = [];
        if (currentPathModel != null) allItems.add(currentPathModel);
        if (results.isNotEmpty) {
          results.sort((a, b) => a.index.compareTo(b.index));
          allItems.addAll(results);
        }

        if (allItems.isNotEmpty) {
          items.assignAll(allItems);
        } else {
          items.clear();
        }
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
    }

    // Débloque en cascade étape → parcours → module dès que les conditions
    // sont réunies, sans attendre un refresh manuel ou un aller-retour.
    if (!_isAutoChecking) {
      _isAutoChecking = true;
      try {
        await _autoUnlockCheck();
      } finally {
        _isAutoChecking = false;
      }
    }
  }

  Future<void> onRefresh() async {
    await fetchSteps();
  }

  String _statusOf(Map<String, dynamic>? progress, String? status) {
    if (progress != null && progress['status'] != null) {
      return progress['status'].toString().toLowerCase();
    }
    return (status ?? 'locked').toLowerCase();
  }

  // Termine automatiquement chaque parcours dont toutes les étapes sont
  // marquées "completed", puis vérifie si le module associé doit lui aussi
  // être marqué terminé (débloquant ainsi le suivant côté serveur).
  Future<void> _autoUnlockCheck() async {
    if (userId.isEmpty || items.isEmpty) return;

    final paths = items.whereType<LearningPathModel>().toList();
    if (paths.isEmpty) return;

    final Map<String, List<StepModel>> stepsByPath = {};
    LearningPathModel? current;
    for (final item in items) {
      if (item is LearningPathModel) {
        current = item;
        stepsByPath[current.id] = [];
      } else if (item is StepModel && current != null) {
        stepsByPath[current.id]!.add(item);
      }
    }

    bool anyCompleted = false;
    final Set<String> moduleIdsToCheck = {};

    for (final path in paths) {
      if (_statusOf(path.progress, path.status) == 'completed') continue;
      final steps = stepsByPath[path.id] ?? [];
      if (steps.isEmpty) continue;
      final allStepsDone = steps
          .every((s) => _statusOf(s.progress, s.status) == 'completed');
      if (!allStepsDone) continue;

      final ok = await LearningPathService.completePath(
          userId: userId, pathId: path.id);
      if (ok) {
        anyCompleted = true;
        if (path.moduleId.isNotEmpty) moduleIdsToCheck.add(path.moduleId);
      }
    }

    for (final modId in moduleIdsToCheck) {
      await _checkModuleCompletion(modId);
    }

    if (anyCompleted) {
      await fetchSteps();
    }
  }

  Future<void> _checkModuleCompletion(String modId) async {
    final modulePaths =
        await LearningPathService.getPathsBySpecificModule(modId);
    if (modulePaths.isEmpty) return;
    final allDone = modulePaths
        .every((p) => _statusOf(p.progress, p.status) == 'completed');
    if (allDone) {
      await ModuleService.completeModule(userId: userId, moduleId: modId);
    }
  }

  Future<void> checkSubscription() async {
    try {
      final planService = Get.put(PlanService());
      final data = await planService.checkCurrentSubscription();
      if (data == null) {
        isSubscriptionActive.value = false;
        return;
      }
      final sub = data['subscription'];
      final active = data['isActive'] == true ||
          data['active'] == true ||
          data['status']?.toString().toLowerCase() == 'active' ||
          data['hasActiveSubscription'] == true ||
          (sub is Map &&
              (sub['status']?.toString().toLowerCase() == 'active' ||
               sub['isActive'] == true));
      isSubscriptionActive.value = active;
    } on DioException catch (e) {
      isSubscriptionActive.value = e.response == null;
    } catch (_) {
      isSubscriptionActive.value = true;
    }
  }
}
