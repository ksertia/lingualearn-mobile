import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tibi/controller/apps/session_controller.dart';
import 'package:tibi/helpers/services/souscription/sousciption_service.dart';
import 'package:tibi/helpers/services/themes/theme_service.dart';
import 'package:tibi/helpers/services/themes/sub_theme_service.dart';
import 'package:tibi/models/themes/theme_model.dart';
import 'package:tibi/models/themes/sub_theme_model.dart';
import 'package:tibi/widgets/moduls/module_completed_dialog.dart';
import 'package:get/get.dart';

class ThemeNode {
  ThemeModel theme;
  final RxList<SubThemeModel> subThemes = <SubThemeModel>[].obs;
  final RxBool subThemesLoading = true.obs;
  final RxBool subThemesError = false.obs;
  ThemeNode(this.theme);
}

class HomeController extends GetxController {
  final session = Get.find<SessionController>();
  final _themeService = ThemeService();
  final _subThemeService = SubThemeService();

  RxBool isLoading = false.obs;
  RxBool hasSubscriptionError = false.obs;
  RxBool isSubscriptionActive = true.obs;
  RxMap<String, String> themeDisplayStatus = <String, String>{}.obs;
  RxMap<String, String> subThemeDisplayStatus = <String, String>{}.obs;
  // Les thèmes sont désormais le premier niveau de la hiérarchie
  // (niveau → thèmes → sous-thèmes), chargés via GET /themes/level/{levelId}.
  RxList<ThemeNode> themeNodes = <ThemeNode>[].obs;

  final PageController pageController = PageController();
  RxInt currentPage = 0.obs;

  late final String _languageId;
  late final String _levelId;

  void onPageChanged(int page) => currentPage.value = page;

  void goToPage(int page) {
    currentPage.value = page;
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

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

    if (_languageId.isNotEmpty && _levelId.isNotEmpty) {
      isLoading.value = true;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_languageId.isNotEmpty && _levelId.isNotEmpty) {
        loadThemes();
        checkSubscription();
      }
    });
  }

  Future<void> loadThemes() async {
    try {
      isLoading.value = true;
      hasSubscriptionError.value = false;

      if (_languageId.isEmpty || _levelId.isEmpty) {
        isLoading.value = false;
        return;
      }

      final themes = await _themeService.getThemesByLevel(
        _levelId,
        userId: _userId,
      );
      themes.sort((a, b) => a.index.compareTo(b.index));

      themeNodes.assignAll(themes.map((t) => ThemeNode(t)));
      for (final t in themes) {
        themeDisplayStatus[t.id] = _displayStatusFor(t.isCompleted, t.isStarted);
      }
      currentPage.value = 0;
      if (pageController.hasClients) {
        pageController.jumpToPage(0);
      }
      for (final node in themeNodes) {
        _loadSubThemesForTheme(node);
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

  // 'locked' | 'unlocked' | 'completed' à partir du seul état de l'entité :
  // pas d'ordre imposé, le cadenas est purement informatif — le tap est
  // toujours possible et déclenche le passage 'not_started' → 'in_progress'
  // (voir markThemeOpened / markSubThemeOpened).
  String _displayStatusFor(bool isCompleted, bool isStarted) {
    if (isCompleted) return 'completed';
    if (isStarted) return 'unlocked';
    return 'locked';
  }

  Future<void> _loadSubThemesForTheme(ThemeNode node) async {
    try {
      final subThemes = await _subThemeService.getSubThemesByTheme(
        node.theme.id,
        userId: _userId,
      );
      subThemes.sort((a, b) => a.index.compareTo(b.index));
      node.subThemes.assignAll(subThemes);
      for (final s in subThemes) {
        subThemeDisplayStatus[s.id] = _displayStatusFor(s.isCompleted, s.isStarted);
      }
    } catch (_) {
      node.subThemesError.value = true;
    } finally {
      node.subThemesLoading.value = false;
    }
  }

  Future<void> retrySubThemesForTheme(ThemeNode node) async {
    node.subThemesLoading.value = true;
    node.subThemesError.value = false;
    await _loadSubThemesForTheme(node);
  }

  bool get hasStartedAnyTheme =>
      themeNodes.any((n) => n.theme.isStarted || n.theme.isCompleted);

  String get _userId =>
      session.userId.value.isNotEmpty ? session.userId.value : (session.user?.id ?? '');

  Future<void> onRefresh() async {
    await loadThemes();
  }

  // Appelé quand l'utilisateur ouvre un thème verrouillé pour la première
  // fois. L'endpoint POST .../themes/{themeId}/start n'existe pas encore côté
  // backend — l'appel échouera silencieusement (progress == null) tant qu'il
  // n'est pas disponible, et l'état optimiste local sera conservé.
  Future<void> markThemeOpened(ThemeNode node) async {
    final t = node.theme;
    if (t.isCompleted || t.isStarted || _userId.isEmpty) return;

    final optimistic =
        t.copyWith(state: 'in_progress', startedAt: DateTime.now().toUtc());
    node.theme = optimistic;
    themeNodes.refresh();
    themeDisplayStatus[t.id] = _displayStatusFor(false, true);

    final progress =
        await _themeService.startTheme(userId: _userId, themeId: t.id);
    if (progress == null) return;

    final confirmed = optimistic.copyWith(
      state: progress.state ?? 'in_progress',
      startedAt: progress.startedAt,
      lastAccessedAt: progress.lastAccessedAt,
      progressPercentage: num.tryParse(progress.progressPercentage ?? ''),
    );
    node.theme = confirmed;
    themeDisplayStatus[t.id] =
        _displayStatusFor(confirmed.isCompleted, confirmed.isStarted);
  }

  // Appelé quand l'utilisateur ouvre le premier contenu d'un sous-thème non
  // verrouillé : persiste 'not_started' → 'in_progress' côté backend.
  // Endpoint POST .../sub-themes/{subThemeId}/start à faire développer, même
  // modèle que les modules — en attendant, échoue silencieusement et l'état
  // optimiste local est conservé.
  Future<void> markSubThemeOpened(ThemeNode themeNode, SubThemeModel subTheme) async {
    if (subTheme.isCompleted || subTheme.isStarted || _userId.isEmpty) return;
    final idx = themeNode.subThemes.indexWhere((s) => s.id == subTheme.id);
    if (idx == -1) return;

    final optimistic =
        subTheme.copyWith(state: 'in_progress', startedAt: DateTime.now().toUtc());
    themeNode.subThemes[idx] = optimistic;
    subThemeDisplayStatus[subTheme.id] = _displayStatusFor(false, true);

    final progress = await _subThemeService.startSubTheme(
        userId: _userId, subThemeId: subTheme.id);
    if (progress == null) return;

    final confirmed = optimistic.copyWith(
      state: progress.state ?? 'in_progress',
      startedAt: progress.startedAt,
      lastAccessedAt: progress.lastAccessedAt,
      progressPercentage: num.tryParse(progress.progressPercentage ?? ''),
    );
    final currentIdx = themeNode.subThemes.indexWhere((s) => s.id == subTheme.id);
    if (currentIdx != -1) themeNode.subThemes[currentIdx] = confirmed;
    subThemeDisplayStatus[subTheme.id] =
        _displayStatusFor(confirmed.isCompleted, confirmed.isStarted);
  }

  // Suit les sous-thèmes terminés par thème. Une fois tous les sous-thèmes
  // d'un thème marqués, on complète le thème.
  final Map<String, Set<String>> _completedSubThemesByTheme = {};

  Future<void> markSubThemeCompleted(
      ThemeNode themeNode, String subThemeId) async {
    final set = _completedSubThemesByTheme.putIfAbsent(
        themeNode.theme.id, () => <String>{});
    set.add(subThemeId);

    final idx = themeNode.subThemes.indexWhere((s) => s.id == subThemeId);
    if (idx != -1 && !themeNode.subThemes[idx].isCompleted) {
      final now = DateTime.now().toUtc();
      final updated = themeNode.subThemes[idx].copyWith(
        state: 'completed',
        completedAt: now,
        lastAccessedAt: now,
        progressPercentage: 100,
      );
      themeNode.subThemes[idx] = updated;
      subThemeDisplayStatus[subThemeId] = 'completed';

      // Endpoint POST .../sub-themes/{subThemeId}/complete à faire
      // développer, même modèle que les modules.
      if (_userId.isNotEmpty) {
        final progress = await _subThemeService.completeSubTheme(
            userId: _userId, subThemeId: subThemeId);
        if (progress != null) {
          final confirmed = updated.copyWith(
            state: progress.state ?? 'completed',
            completedAt: progress.completedAt ?? now,
            lastAccessedAt: progress.lastAccessedAt ?? now,
            progressPercentage: num.tryParse(progress.progressPercentage ?? '100'),
          );
          final currentIdx =
              themeNode.subThemes.indexWhere((s) => s.id == subThemeId);
          if (currentIdx != -1) themeNode.subThemes[currentIdx] = confirmed;
          subThemeDisplayStatus[subThemeId] = 'completed';
        }
      }
    }

    final allSubThemeIds = themeNode.subThemes.map((s) => s.id).toSet();
    if (allSubThemeIds.isEmpty || !set.containsAll(allSubThemeIds)) return;

    onThemeCompleted(themeNode);
  }

  Future<void> onThemeCompleted(ThemeNode themeNode) async {
    if (themeNode.theme.isCompleted) return;

    final now = DateTime.now().toUtc();
    final updated = themeNode.theme.copyWith(
      state: 'completed',
      completedAt: now,
      lastAccessedAt: now,
      progressPercentage: 100,
    );
    themeNode.theme = updated;
    themeNodes.refresh();
    themeDisplayStatus[updated.id] = 'completed';

    ModuleCompletedDialog.show(updated.title);

    if (_userId.isNotEmpty) {
      final progress = await _themeService.completeTheme(
          userId: _userId, themeId: updated.id);
      if (progress != null) {
        final confirmed = updated.copyWith(
          state: progress.state ?? 'completed',
          completedAt: progress.completedAt ?? now,
          lastAccessedAt: progress.lastAccessedAt ?? now,
          progressPercentage: num.tryParse(progress.progressPercentage ?? '100'),
        );
        themeNode.theme = confirmed;
        themeDisplayStatus[confirmed.id] = 'completed';
      }
      // Si l'appel échoue (endpoint pas encore dispo), l'état local
      // optimiste ('completed') est conservé.
    }
  }
}
