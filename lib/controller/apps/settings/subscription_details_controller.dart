import 'package:fasolingo/helpers/services/souscription/subscription_status_service.dart';
import 'package:fasolingo/models/souscription/subscription_status_model.dart';
import 'package:get/get.dart';

class SubscriptionDetailsController extends GetxController {
  final Rxn<SubscriptionStatusModel> status = Rxn<SubscriptionStatusModel>();
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatus();
  }

  Future<void> loadStatus() async {
    isLoading(true);
    hasError(false);
    try {
      final result = await SubscriptionStatusService.fetchMyStatus();
      status.value = result;
      if (result == null) hasError(true);
    } catch (_) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  @override
  Future<void> refresh() => loadStatus();
}
