import 'package:get/get.dart';
import '../../../helpers/services/etapes/step_content_service.dart';
import '../../../models/etapes/steps_model.dart';

class StepController extends GetxController {
  final StepService _stepService = StepService();

  var isLoading = false.obs;
  var stepData = Rxn<StepData>();

  var currentQuestionIndex = 0.obs; 

  Future<void> loadStepContent(String stepId, String userId) async {
    try {
      isLoading(true);
      currentQuestionIndex(0); 

      final result = await _stepService.getStepContent(stepId, userId: userId);

      if (result != null) {
        stepData.value = result;
      } else {
        Get.snackbar("Erreur", "Impossible de charger le contenu");
      }
    } catch (e) {
      Get.snackbar("Erreur", "Une erreur est survenue : $e");
    } finally {
      isLoading(false);
    }
  }

  void nextQuestion() {
    if (stepData.value != null && stepData.value!.content.questions != null) {
      final totalQuestions = stepData.value!.content.questions!.length;

      if (currentQuestionIndex.value < totalQuestions - 1) {
        currentQuestionIndex.value++;
      } else {
        Get.back();
        Get.snackbar(
          "Bravo !",
          "Tu as terminé cette étape avec succès.",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  void nextStep() {
    print("Navigation vers l'étape suivante...");
  }
}