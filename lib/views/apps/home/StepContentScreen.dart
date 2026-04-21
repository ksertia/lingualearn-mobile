import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryImage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryAudio.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryVideo.dart';
import 'package:fasolingo/widgets/etapefamille/pdf_etape.dart';
import 'package:fasolingo/widgets/lessons/qcm.dart';
import 'package:fasolingo/widgets/lessons/qcmdrag.dart';
import '../../../controller/apps/etapes/stepController.dart';
import '../../../models/etapes/steps_model.dart';

class StepContentScreen extends StatelessWidget {
  final String stepId;
  final String userId;

  const StepContentScreen(
      {super.key, required this.stepId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final StepController controller = Get.put(StepController());

    Future.microtask(() => controller.loadStepContent(stepId, userId));

    return Scaffold(
      appBar: AppBar(
        title: Obx(
            () => Text(controller.stepData.value?.title ?? "Chargement...")),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.stepData.value;

        if (data == null) {
          return const Center(
              child: Text("Erreur de récupération des données"));
        }

        return Column(
          children: [
            Expanded(
              child: _buildBody(context, data, controller),
            ),
            if (data.type != 'quiz')
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isCompleting.value
                            ? null
                            : () => controller.completeCurrentStep(
                                  stepId: stepId,
                                  userId: userId,
                                ),
                        child: controller.isCompleting.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text("Terminer l’étape"),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildBody(
      BuildContext context, StepData data, StepController controller) {
    final String type = data.type;
    final String format = data.format;
    final content = data.content;

    if (type == 'lesson') {
      switch (format) {
        case 'video':
          return StepDiscoveryVideo(
            videoTitle: data.title,
            videoUrl: content.mediaUrl ?? "",
            onVideoFinished: () => Get.back(),
          );
        case 'image':
          return StepDiscoveryImage(
            title: data.title,
            imageUrl: content.mediaUrl ?? "",
            answerText: content.text ?? "",
          );
        case 'audio':
          return StepDiscoveryAudio(
            title: data.title,
            texteOriginal: content.text ?? "",
            traduction: "Répète après moi",
            lottie: 'assets/lottie/mascot.json',
          );
        default:
          return Center(child: Text(content.text ?? "Leçon textuelle"));
      }
    } else if (type == 'quiz') {
      final questionsList = content.questions;

      if (questionsList == null || questionsList.isEmpty) {
        return const Center(
            child: Text("Ce quiz ne contient aucune question."));
      }

      final currentQuestion =
          questionsList[controller.currentQuestionIndex.value];

      if (currentQuestion.type == 'multiple_choice') {
        return QuizQCM(
          key: ValueKey(controller.currentQuestionIndex.value),
          question: currentQuestion.text,
          options: currentQuestion.options,
          correctOption: currentQuestion.answer,
          lottieQuestion: 'assets/lottie/mascot.json',
          lottieCorrect: 'assets/lottie/Happy mascot.json',
          lottieIncorrect: 'assets/lottie/Sad mascot.json',
          onNext: () => _handleQuizNext(context, controller, questionsList),
        );
      }

      return const Center(child: Text("Type de question non supporté"));
    }

    return const Center(child: Text("Type de contenu inconnu"));
  }

  void _handleQuizNext(BuildContext context, StepController controller,
      List<dynamic> questionsList) {
    final bool isLastQuestion =
        controller.currentQuestionIndex.value == questionsList.length - 1;
    if (isLastQuestion) {
      _showQuizCompletedBottomSheet(context, controller);
    } else {
      controller.nextQuestion();
    }
  }

  void _showQuizCompletedBottomSheet(
      BuildContext context, StepController controller) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B61FF), Color(0xFF8456FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events,
                            color: Colors.white, size: 54),
                        const SizedBox(height: 16),
                        const Text(
                          "Nous avons une surprise pour vous",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Tu as terminé le quiz \nBravo pour ta persévérance !",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15, color: Colors.white70, height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            "Tu gagnes une récompense spéciale pour ta réussite !",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isCompleting.value
                          ? null
                          : () async {
                              Navigator.of(context).pop();
                              await controller.completeCurrentStep(
                                stepId: stepId,
                                userId: userId,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: Obx(
                        () => controller.isCompleting.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                "Terminer",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7B61FF),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
