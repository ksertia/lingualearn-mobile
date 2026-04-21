import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/controller/my_controller.dart';
import 'package:fasolingo/helpers/services/languages_service.dart';
import 'package:fasolingo/models/child_progress_models.dart';
import 'package:get/get.dart';

class ChildProgressController extends MyController {
  final RxBool isLoading = false.obs;
  final Rxn<ChildProgressResponseModel> progress =
      Rxn<ChildProgressResponseModel>();

  Future<void> fetchProgress(String childId) async {
    try {
      isLoading(true);
      final session = Get.find<SessionController>();

      final res = await LanguagesService.getChildProgress(
        childId,
        token: session.token.value,
      );

      progress.value = res;
    } catch (_) {
    } finally {
      isLoading(false);
    }
  }
}
