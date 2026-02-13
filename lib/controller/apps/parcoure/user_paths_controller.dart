import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/services/parcoure/parcoure_service.dart';
import 'package:fasolingo/models/parcoure/parcour_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserPathsController extends GetxController {
  final session = Get.find<SessionController>();

  RxBool isLoading = false.obs;
  RxList<LearningPathModel> userPaths = <LearningPathModel>[].obs;
  RxMap<String, String> pathDisplayStatus = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final userId = session.user?.id ?? '';
    if (userId.isNotEmpty) fetchUserPaths(userId);
  }

  Future<void> fetchUserPaths(String userId) async {
    try {
      isLoading.value = true;
      final results = await LearningPathService.getPathsByUser(userId);
      if (results.isNotEmpty) {
        results.sort((a, b) => a.index.compareTo(b.index));
        userPaths.assignAll(results);

        pathDisplayStatus.clear();
        for (var p in results) {
          pathDisplayStatus[p.id] = _resolveDisplayStatus(p);
        }
      } else {
        userPaths.clear();
      }
    } catch (e) {
      print('🚨 [UserPathsController] Erreur fetchUserPaths: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _resolveDisplayStatus(LearningPathModel p) {
    final status = (p.progress != null && p.progress!['status'] != null)
        ? p.progress!['status'].toString().toLowerCase()
        : (p.status ?? 'locked').toString().toLowerCase();

    if (status == 'completed' || status == 'complete') return 'completed';
    if (status == 'unlocked' || status == 'started' || status == 'in_progress') return 'unlocked';
    return 'locked';
  }

  bool isLocked(String pathId) => pathDisplayStatus[pathId] == 'locked';
  bool isUnlocked(String pathId) => pathDisplayStatus[pathId] == 'unlocked';
  bool isCompleted(String pathId) => pathDisplayStatus[pathId] == 'completed';

  Future<void> onPathCompleted(String pathId) async {
    try {
      final idx = userPaths.indexWhere((p) => p.id == pathId);
      if (idx == -1) return;

      final p = userPaths[idx];
      final now = DateTime.now().toUtc();

      final currentProgress = (p.progress != null) ? Map<String, dynamic>.from(p.progress!) : <String, dynamic>{};
      currentProgress['status'] = 'completed';
      currentProgress['completedAt'] = now.toIso8601String();

      final updatedCurrent = LearningPathModel(
        id: p.id,
        moduleId: p.moduleId,
        title: p.title,
        description: p.description,
        index: p.index,
        tempResaListime: p.tempResaListime,
        thumbnailUrl: p.thumbnailUrl,
        difficulty: p.difficulty,
        estimatedHours: p.estimatedHours,
        isActive: p.isActive,
        createdAt: p.createdAt,
        updatedAt: now,
        steps: p.steps,
        status: 'completed',
        progress: currentProgress,
        progressPercentage: '100',
        currentStepIndex: p.currentStepIndex,
        totalXp: p.totalXp,
        timeSpentMinutes: p.timeSpentMinutes,
        quizScore: p.quizScore,
      );

      userPaths[idx] = updatedCurrent;
      pathDisplayStatus[updatedCurrent.id] = 'completed';

      final nextIdx = idx + 1;
      if (nextIdx < userPaths.length) {
        final next = userPaths[nextIdx];
        final nextProgress = (next.progress != null) ? Map<String, dynamic>.from(next.progress!) : <String, dynamic>{};
        
        nextProgress['status'] = 'unlocked';
        nextProgress['unlockedAt'] = now.toIso8601String();

        final updatedNext = LearningPathModel(
          id: next.id,
          moduleId: next.moduleId,
          title: next.title,
          description: next.description,
          index: next.index,
          tempResaListime: next.tempResaListime,
          thumbnailUrl: next.thumbnailUrl,
          difficulty: next.difficulty,
          estimatedHours: next.estimatedHours,
          isActive: next.isActive,
          createdAt: next.createdAt,
          updatedAt: now,
          steps: next.steps,
          status: 'unlocked',
          progress: nextProgress,
          progressPercentage: next.progressPercentage,
          currentStepIndex: next.currentStepIndex,
          totalXp: next.totalXp,
          timeSpentMinutes: next.timeSpentMinutes,
          quizScore: next.quizScore,
        );

        userPaths[nextIdx] = updatedNext;
        pathDisplayStatus[updatedNext.id] = 'unlocked';
      }

      Get.defaultDialog(
        title: 'Bravo ! 🎉',
        middleText: 'Parcours terminé, le suivant est débloqué.',
        textConfirm: 'Super',
        buttonColor: const Color(0xFF00008B),
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );

    } catch (e) {
      print('🚨 [UserPathsController] Erreur onPathCompleted: $e');
    }
  }
}