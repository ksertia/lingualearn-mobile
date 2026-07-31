import 'package:tibi/controller/apps/session_controller.dart';
import 'package:tibi/helpers/services/user_progress_service.dart';
import 'package:tibi/models/user_model.dart';
import 'package:tibi/models/user_progress/user_progress_model.dart';
import 'package:get/get.dart';

class UserProgressController extends GetxController {
  final session = Get.find<SessionController>();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxList<UserProgressEntry> progressList = <UserProgressEntry>[].obs;

  // Entry de la langue la plus récemment accédée
  UserProgressEntry? get mostRecentEntry {
    if (progressList.isEmpty) return null;
    return progressList.reduce((a, b) {
      final aTime = a.language.lastAccessedAt;
      final bTime = b.language.lastAccessedAt;
      if (aTime == null) return b;
      if (bTime == null) return a;
      return aTime.isAfter(bTime) ? a : b;
    });
  }

  @override
  void onInit() {
    super.onInit();
    loadProgress();
  }

  Future<void> loadProgress() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final result = await UserProgressService.getMyProgress(
        token: session.token.value,
      );
      if (result != null && result.isNotEmpty) {
        progressList.assignAll(result);
        return;
      }
      // /users/my-progress ne renvoie encore rien pour ce compte (ex: langue
      // sélectionnée mais pas de progression détaillée côté endpoint dédié)
      // — on retombe sur les infos du profil utilisateur (currentState), en
      // le rechargeant d'abord pour refléter la progression la plus récente
      // (le snapshot pris au login devient vite obsolète en cours de session).
      await _refreshSessionUser();
      final fallback = _buildFallbackFromSession();
      progressList.assignAll(fallback != null ? [fallback] : []);
      if (result == null && fallback == null) hasError.value = true;
    } catch (_) {
      await _refreshSessionUser();
      final fallback = _buildFallbackFromSession();
      if (fallback != null) {
        progressList.assignAll([fallback]);
      } else {
        hasError.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshSessionUser() async {
    try {
      final response = await session.dio.get('/users/me');
      if (response.statusCode == 200 && response.data['success'] == true) {
        session.user = UserModel.fromJson(response.data['data']);
      }
    } catch (_) {
      // Échec silencieux — on garde les données de session déjà en mémoire.
    }
  }

  UserProgressEntry? _buildFallbackFromSession() {
    final user = session.user;
    if (user == null || user.currentLanguageId == null) return null;

    final state = user.currentState;
    return UserProgressEntry(
      language: ProgressLanguageInfo(
        id: user.currentLanguageId!,
        name: user.currentLanguageName ?? '',
        code: user.currentLanguageCode ?? '',
        status: 'started',
        progressPercentage: user.currentLanguageProgressPercentage,
      ),
      level: ProgressLevelInfo(
        id: state?.levelId ?? '',
        name: state?.levelName ?? '',
        code: '',
        status: 'unlocked',
        totalModules: 0,
        completedModules: 0,
        progressPercentage: 0,
      ),
      module: state?.moduleId != null
          ? ProgressModuleInfo(
              id: state!.moduleId!,
              title: state.moduleTitle ?? '',
              status: 'started',
              totalPaths: 0,
              completedPaths: 0,
              progressPercentage: 0,
            )
          : null,
      path: state?.pathId != null
          ? ProgressPathInfo(
              id: state!.pathId!,
              title: state.pathTitle ?? '',
              status: 'started',
              totalSteps: 0,
              completedSteps: 0,
              progressPercentage: 0,
            )
          : null,
      step: state?.stepId != null
          ? ProgressStepInfo(
              id: state!.stepId!,
              title: state.stepTitle ?? '',
              stepType: state.stepType ?? '',
              status: 'started',
              progressPercentage: 0,
            )
          : null,
    );
  }

  // Fetch silencieux — ne touche ni isLoading ni progressList.
  // Retourne la liste brute pour que l'appelant décide quoi en faire.
  Future<List<UserProgressEntry>?> fetchSilent() async {
    try {
      return await UserProgressService.getMyProgress(token: session.token.value);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> refresh() => loadProgress();
}
