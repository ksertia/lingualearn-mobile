import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../helpers/services/etapes/etape_service.dart';
import '../../../helpers/services/etapes/step_content_service.dart';
import '../../../models/etapes/steps_model.dart';

class StepController extends GetxController {
  final StepService _stepService = StepService();

  var isLoading = false.obs;
  var isCompleting = false.obs;
  var stepData = Rxn<StepData>();
  var loadErrorMsg = Rxn<String>();

  var currentQuestionIndex = 0.obs;

  Future<void> loadStepContent(String stepId, String userId) async {
    try {
      isLoading(true);
      loadErrorMsg.value = null;
      currentQuestionIndex(0);

      stepData.value =
          await _stepService.getStepContent(stepId, userId: userId);
    } on DioException catch (e) {
      loadErrorMsg.value = _dioErrorMsg(e);
    } catch (e) {
      loadErrorMsg.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  String _dioErrorMsg(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connexion trop lente. Vérifie ta connexion internet.';
    }
    if (e.type == DioExceptionType.connectionError || e.response == null) {
      return 'Pas de connexion internet. Vérifie ton réseau.';
    }
    final status = e.response?.statusCode ?? 0;
    if (status == 401 || status == 403) return 'Session expirée (code $status).';
    if (status == 404) return 'Étape introuvable (404).';
    if (status >= 500) return 'Erreur serveur (code $status).';
    return 'Impossible de charger le contenu (code $status) : ${e.response?.data}';
  }

  Future<void> completeCurrentStep({
    required String stepId,
    required String userId,
  }) async {
    try {
      if (isCompleting.value) return;
      isCompleting.value = true;
      final ok =
          await StepsService.completeStep(userId: userId, stepId: stepId);
      if (ok) {
        Get.back(result: true);
        return;
      }
      Get.snackbar('Erreur', "Impossible de valider l'étape");
    } catch (e) {
      Get.snackbar('Erreur', "Une erreur est survenue : $e");
    } finally {
      isCompleting.value = false;
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

  void nextStep() {}
}
