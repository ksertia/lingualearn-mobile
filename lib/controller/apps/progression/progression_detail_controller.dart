import 'package:dio/dio.dart';
import 'package:tibi/helpers/services/progression/progression_detail_service.dart';
import 'package:tibi/models/progression/progression_detail_model.dart';
import 'package:get/get.dart';

class ProgressionDetailController extends GetxController {
  final Rxn<ProgressionDetailModel> progression = Rxn<ProgressionDetailModel>();
  final RxBool isLoading  = false.obs;
  final RxBool hasError   = false.obs;
  final RxString errorMsg = ''.obs;

  // Garde les paramètres pour pouvoir recharger
  String _userId     = '';
  String _languageId = '';

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> load({
    required String userId,
    required String languageId,
  }) async {
    _userId     = userId;
    _languageId = languageId;

    isLoading.value = true;
    hasError.value  = false;
    errorMsg.value  = '';

    try {
      final result = await ProgressionDetailService.getProgression(
        userId:     userId,
        languageId: languageId,
      );
      progression.value = result;
      if (result == null) {
        hasError.value = true;
        errorMsg.value = 'Aucune donnée reçue.';
      }
    } on DioException catch (e) {
      hasError.value = true;
      errorMsg.value = _dioMsg(e);
    } catch (e) {
      hasError.value = true;
      errorMsg.value = 'Erreur inattendue.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reload() => load(userId: _userId, languageId: _languageId);

  // ── Computed getters ───────────────────────────────────────────────────────

  String get languageName => progression.value?.language.name ?? '';
  String get languageCode => progression.value?.language.code ?? '';
  String get flagUrl      => progression.value?.language.flagUrl ?? '';

  int get totalXp       => progression.value?.overallProgress.totalXp ?? 0;
  int get totalMinutes  => progression.value?.overallProgress.totalTimeMinutes ?? 0;
  int get avgQuizScore  => progression.value?.avgQuizScore ?? 0;
  String get overallStatus => progression.value?.overallProgress.status ?? 'locked';

  List<ProgLevel> get levels => progression.value?.levels ?? [];

  int get totalModules    => progression.value?.totalModules ?? 0;
  int get completedModules => progression.value?.completedModules ?? 0;
  int get inProgressModules => progression.value?.inProgressModules ?? 0;
  int get lockedModules   => progression.value?.lockedModules ?? 0;

  /// XP du niveau sélectionné (ou premier niveau disponible)
  int xpForLevel(String levelId) {
    return levels
        .firstWhereOrNull((l) => l.id == levelId)
        ?.totalXp ?? 0;
  }

  /// Progression % du niveau sélectionné
  int progressForLevel(String levelId) {
    return levels
        .firstWhereOrNull((l) => l.id == levelId)
        ?.progressPercent ?? 0;
  }

  /// Nom du niveau sélectionné
  String nameForLevel(String levelId) {
    return levels
        .firstWhereOrNull((l) => l.id == levelId)
        ?.name ?? '';
  }

  /// Modules d'un niveau spécifique
  List<ProgModule> modulesForLevel(String levelId) {
    return levels
        .firstWhereOrNull((l) => l.id == levelId)
        ?.modules ?? [];
  }

  // ── Error helper ──────────────────────────────────────────────────────────

  String _dioMsg(DioException e) {
    if (e.type == DioExceptionType.connectionError || e.response == null) {
      return 'Pas de connexion internet.';
    }
    final code = e.response?.statusCode ?? 0;
    if (code == 401 || code == 403) return 'Session expirée.';
    if (code >= 500) return 'Erreur serveur. Réessaie.';
    return 'Impossible de charger la progression.';
  }
}
