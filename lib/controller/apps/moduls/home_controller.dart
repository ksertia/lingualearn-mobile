import 'package:dio/dio.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/services/module_service.dart';
import 'package:fasolingo/helpers/services/souscription/sousciption_service.dart';
import 'package:fasolingo/models/modules/modul_model.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final session = Get.find<SessionController>();

  RxBool isLoading = false.obs;
  RxBool hasSubscriptionError = false.obs;
  RxBool isSubscriptionActive = true.obs;
  RxList<ModuleModel> filteredModules = <ModuleModel>[].obs;
  RxMap<String, String> moduleDisplayStatus = <String, String>{}.obs;

  late final String _languageId;
  late final String _levelId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    final String argLang =
        args is Map ? (args['languageId'] as String? ?? '') : '';
    final String argLvl = args is Map ? (args['levelId'] as String? ?? '') : '';
    _languageId =
        argLang.isNotEmpty ? argLang : session.selectedLanguageId.value;
    _levelId = argLvl.isNotEmpty ? argLvl : session.selectedLevelId.value;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_languageId.isNotEmpty && _levelId.isNotEmpty) {
        loadModules();
        checkSubscription();
      }
    });
  }

  Future<void> loadModules() async {
    try {
      isLoading.value = true;
      hasSubscriptionError.value = false;

      if (_languageId.isEmpty || _levelId.isEmpty) {
        isLoading.value = false;
        return;
      }

      List<ModuleModel> modulesFromApi = await ModuleService.getAllModules(
        languageId: _languageId,
        levelId: _levelId,
      );

      if (modulesFromApi.isNotEmpty) {
        modulesFromApi.sort((a, b) => a.index.compareTo(b.index));
        filteredModules.assignAll(modulesFromApi);
        moduleDisplayStatus.clear();
        for (var m in modulesFromApi) {
          moduleDisplayStatus[m.id] = _resolveDisplayStatus(m);
        }
      } else {
        filteredModules.clear();
      }
    } catch (e) {
      final isSubError = (e is DioException &&
              (e.response?.statusCode == 402 ||
               e.response?.statusCode == 403)) ||
          e.toString().toLowerCase().contains('subscription') ||
          e.toString().toLowerCase().contains('abonnement') ||
          e.toString().toLowerCase().contains('expired') ||
          e.toString().toLowerCase().contains('souscription');
      if (isSubError) hasSubscriptionError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkSubscription() async {
    try {
      final planService = Get.put(PlanService());
      final data = await planService.checkCurrentSubscription();

      // null = aucun abonnement trouvé → bloquer
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
      // Pas de connexion internet → ne pas bloquer
      // Réponse serveur (401/403/404) → bloquer
      isSubscriptionActive.value = e.response == null;
    } catch (_) {
      isSubscriptionActive.value = true; // erreur inattendue → ne pas bloquer
    }
  }

  String _resolveDisplayStatus(ModuleModel m) {
    final status =
        (m.progress?.status ?? m.status ?? 'locked').toString().toLowerCase();
    if (status == 'completed' || status == 'complete') return 'completed';
    if (status == 'unlocked' ||
        status == 'started' ||
        status == 'in_progress' ||
        status == 'deblocked' ||
        status == 'debloque' ||
        status == 'debloqued') return 'unlocked';
    return 'locked';
  }

  bool isLocked(String moduleId) {
    return moduleDisplayStatus[moduleId]?.toLowerCase() == 'locked';
  }

  bool isUnlocked(String moduleId) {
    return moduleDisplayStatus[moduleId]?.toLowerCase() == 'unlocked';
  }

  bool isCompleted(String moduleId) {
    return moduleDisplayStatus[moduleId]?.toLowerCase() == 'completed';
  }

  Future<void> onRefresh() async {
    await loadModules();
  }

  Future<void> onModuleCompleted(String moduleId) async {
    try {
      final idx = filteredModules.indexWhere((m) => m.id == moduleId);
      if (idx == -1) return;

      final m = filteredModules[idx];
      final now = DateTime.now().toUtc();

      final completedProgress = ModuleProgress(
        id: m.progress?.id,
        userId: m.progress?.userId,
        moduleId: m.id,
        status: 'completed',
        progressPercentage: '100',
        totalXp: m.progress?.totalXp ?? m.totalXp,
        timeSpentMinutes: m.progress?.timeSpentMinutes ?? m.timeSpentMinutes,
        unlockedAt: m.progress?.unlockedAt,
        startedAt: m.progress?.startedAt ?? now,
        completedAt: now,
        lastAccessedAt: now,
      );

      final updated = ModuleModel(
        id: m.id,
        levelId: m.levelId,
        title: m.title,
        description: m.description,
        iconUrl: m.iconUrl,
        index: m.index,
        isActive: m.isActive,
        createdAt: m.createdAt,
        updatedAt: now,
        paths: m.paths,
        status: 'completed',
        progress: completedProgress,
        progressPercentage: '100',
      );

      filteredModules[idx] = updated;
      moduleDisplayStatus[updated.id] = 'completed';

      // Afficher un dialog de réussite
      Get.defaultDialog(
        title: 'Félicitations',
        middleText: 'Module terminé',
        textConfirm: 'Continuer',
        onConfirm: () {
          Get.back();
        },
      );

      final nextIdx = idx + 1;
      if (nextIdx < filteredModules.length) {
        final next = filteredModules[nextIdx];
        final unlockedProgress = ModuleProgress(
          id: next.progress?.id,
          userId: next.progress?.userId,
          moduleId: next.id,
          status: 'unlocked',
          progressPercentage: next.progressPercentage ?? '0',
          totalXp: next.progress?.totalXp ?? next.totalXp,
          timeSpentMinutes:
              next.progress?.timeSpentMinutes ?? next.timeSpentMinutes,
          unlockedAt: now,
          startedAt: next.progress?.startedAt,
          completedAt: next.progress?.completedAt,
          lastAccessedAt: now,
        );

        final updatedNext = ModuleModel(
          id: next.id,
          levelId: next.levelId,
          title: next.title,
          description: next.description,
          iconUrl: next.iconUrl,
          index: next.index,
          isActive: next.isActive,
          createdAt: next.createdAt,
          updatedAt: now,
          paths: next.paths,
          status: 'unlocked',
          progress: unlockedProgress,
          progressPercentage: next.progressPercentage ?? '0',
        );

        filteredModules[nextIdx] = updatedNext;
        moduleDisplayStatus[updatedNext.id] = 'unlocked';
      }
    } catch (e) {}
  }
}
