import 'package:fasolingo/controller/my_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/services/children_service.dart';
import 'package:fasolingo/helpers/utils/app_snackbar.dart';
import 'package:fasolingo/model/child_model.dart';
import 'package:get/get.dart';

class ChildrenController extends MyController {
  final RxBool isLoading = false.obs;
  final RxBool isFetching = false.obs;

  final RxList<ChildModel> children = <ChildModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyChildren();
  }

  Future<void> fetchMyChildren() async {
    try {
      isFetching(true);
      final session = Get.find<SessionController>();

      final res = await ChildrenService.getMyChildren(
        token: session.token.value,
      );

      if (res != null) {
        children.assignAll(res);
      }
    } catch (_) {
      
    } finally {
      isFetching(false);
    }
  }

  Future<bool> createSubAccount({
    required String firstName,
    required String lastName,
    required String password,
    String? email,
    String? phone,
  }) async {
    try {
      isLoading(true);

      final session = Get.find<SessionController>();
      final res = await ChildrenService.createChild(
        {
          'firstName': firstName,
          'lastName': lastName,
          'password': password,
          'email': (email != null && email.trim().isNotEmpty) ? email.trim() : null,
          'phone': (phone != null && phone.trim().isNotEmpty) ? phone.trim() : null,
        },
        token: session.token.value,
      );

      if (res != null) {
        appSnackbar(
          heading: 'Succès',
          message: 'Sous-compte créé avec succès',
        );
        await fetchMyChildren();
        return true;
      }

      appSnackbar(
        heading: 'Erreur',
        message: "Impossible de créer le sous-compte",
      );
      return false;
    } catch (_) {
      appSnackbar(
        heading: 'Erreur',
        message: "Une erreur est survenue",
      );
      return false;
    } finally {
      isLoading(false);
    }
  }
}
