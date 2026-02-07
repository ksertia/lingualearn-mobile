/*import 'package:get/get.dart';
import '../../helpers/services/api_service/api_service.dart';
import '../../models/step_model/step_model.dart';
//import '../models/step_model.dart';
//import '../services/api_service.dart';

class StepsController extends GetxController {
  var steps = <StepModel>[].obs;  // Liste observable
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSteps();
  }

  void fetchSteps() async {
    isLoading.value = true;
    steps.value = await ApiService.getSteps();
    isLoading.value = false;
  }
}*/
