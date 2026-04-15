import 'package:get/get.dart';
import '../../../helpers/services/etapes/step_content_service.dart';
import '../../../models/etapes/steps_model.dart';

class StepController extends GetxController {
  final StepService _stepService = StepService();

  // Variables d'état
  var isLoading = false.obs;
  var stepData = Rxn<StepData>();

  // --- AJOUTS NÉCESSAIRES POUR LE QUIZ ---
  var currentQuestionIndex = 0.obs; // L'index pour savoir on est à quelle question

  /// Charge le contenu d'une étape
  Future<void> loadStepContent(String stepId, String userId) async {
    try {
      isLoading(true);
      currentQuestionIndex(0); // On remet à zéro quand on charge une nouvelle étape

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

  /// --- AJOUTÉ : Logique pour passer à la question suivante ---
  void nextQuestion() {
    if (stepData.value != null && stepData.value!.content.questions != null) {
      final totalQuestions = stepData.value!.content.questions!.length;

      if (currentQuestionIndex.value < totalQuestions - 1) {
        // Il reste des questions, on avance l'index
        currentQuestionIndex.value++;
      } else {
        // C'était la dernière question, on ferme le quiz
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

  /// Logique pour passer à l'étape suivante (si besoin)
  void nextStep() {
    print("Navigation vers l'étape suivante...");
  }
}