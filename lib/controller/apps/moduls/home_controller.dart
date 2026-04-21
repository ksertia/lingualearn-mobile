import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/services/module_service.dart';
import 'package:fasolingo/models/modules/modul_model.dart'; 
import 'package:get/get.dart';

class HomeController extends GetxController {
  final session = Get.find<SessionController>();
  
  RxBool isLoading = false.obs;
  RxList<ModuleModel> filteredModules = <ModuleModel>[].obs;
  // Map moduleId -> resolved status ('locked' | 'unlocked' | 'completed')
  RxMap<String, String> moduleDisplayStatus = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Attendre un petit moment pour que SessionController.updateUser() finisse
    // puis charger les modules quand les ids sont disponibles.
    Future.delayed(const Duration(milliseconds: 100), () {
      if (session.selectedLanguageId.value.isNotEmpty && 
          session.selectedLevelId.value.isNotEmpty) {
        loadModules();
      }
    });
  }

  Future<void> loadModules() async {
    try {
      isLoading.value = true;
      
      // Vérifier que les ids sont présents
      if (session.selectedLanguageId.value.isEmpty || 
          session.selectedLevelId.value.isEmpty) {
        isLoading.value = false;
        return;
      }
      
      List<ModuleModel> modulesFromApi = await ModuleService.getAllModules();

      if (modulesFromApi.isNotEmpty) {
        modulesFromApi.sort((a, b) => a.index.compareTo(b.index));
        filteredModules.assignAll(modulesFromApi);

        // Remplir la map de statuts pour que l'UI puisse se baser dessus
        moduleDisplayStatus.clear();
        for (var m in modulesFromApi) {
          moduleDisplayStatus[m.id] = _resolveDisplayStatus(m);
        }
      } else {
        filteredModules.clear();
      }
      
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  String _resolveDisplayStatus(ModuleModel m) {
    // Priorité: progress.status > module.status > locked
    final status = (m.progress?.status ?? m.status ?? 'locked').toString().toLowerCase();
    if (status == 'completed' || status == 'complete') return 'completed';
    if (status == 'unlocked' || status == 'started' || status == 'in_progress' || status == 'deblocked' || status == 'debloque' || status == 'debloqued') return 'unlocked';
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
      final userId = session.userId.value.isNotEmpty
          ? session.userId.value
          : (session.user?.id ?? '');
      if (userId.isNotEmpty) {
        await ModuleService.completeModule(userId: userId, moduleId: moduleId);
      }

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
        middleText: 'Module terminé 🎉',
        textConfirm: 'Continuer',
        onConfirm: () {
          Get.back();
        },
      );

      // Débloquer le module suivant si présent
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
          timeSpentMinutes: next.progress?.timeSpentMinutes ?? next.timeSpentMinutes,
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
    } catch (e) {
    }
  }
}