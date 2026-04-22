import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/services/user_progress_service.dart';
import 'package:fasolingo/models/user_progress/user_progress_model.dart';
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
      if (result != null) {
        progressList.assignAll(result);
      } else {
        hasError.value = true;
      }
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() => loadProgress();
}
