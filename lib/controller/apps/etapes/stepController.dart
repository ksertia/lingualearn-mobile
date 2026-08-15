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
  var lessonData = Rxn<LessonContent>();
  var loadErrorMsg = Rxn<String>();

  var currentQuestionIndex = 0.obs;
  var currentBlockIndex = 0.obs;
  var correctAnswersCount = 0.obs;
  DateTime? quizStartedAt;

  List<LessonBlock> get lessonBlocks => lessonData.value?.blocks ?? [];

  void nextBlock() {
    if (currentBlockIndex.value < lessonBlocks.length - 1) {
      currentBlockIndex.value++;
    }
  }

  void previousBlock() {
    if (currentBlockIndex.value > 0) {
      currentBlockIndex.value--;
    }
  }

  Future<void> loadStepContent(String stepId, String userId,
      {String stepType = 'lesson'}) async {
    try {
      isLoading(true);
      loadErrorMsg.value = null;
      currentQuestionIndex(0);
      currentBlockIndex(0);
      correctAnswersCount(0);
      quizStartedAt = DateTime.now();

      if (stepType == 'quiz') {
        stepData.value =
            await _stepService.getStepContent(stepId, userId: userId);
      } else {
        lessonData.value =
            await _stepService.getStepLessons(stepId, userId: userId);
      }
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

  void recordAnswer(bool isCorrect) {
    if (isCorrect) correctAnswersCount.value++;
  }

  int get totalQuestions => stepData.value?.content.questions?.length ?? 0;

  int get scorePercentage =>
      totalQuestions == 0 ? 0 : ((correctAnswersCount.value / totalQuestions) * 100).round();

  int get earnedXp => correctAnswersCount.value * 5;

  Duration get quizElapsed =>
      quizStartedAt == null ? Duration.zero : DateTime.now().difference(quizStartedAt!);

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
