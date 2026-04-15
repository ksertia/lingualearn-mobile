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

  const StepContentScreen({
    super.key,
    required this.stepId,
    required this.userId
  });

  @override
  Widget build(BuildContext context) {
    // On utilise Get.put mais Get.find est souvent préférable si déjà injecté
    final StepController controller = Get.put(StepController());

    Future.microtask(() => controller.loadStepContent(stepId, userId));

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.stepData.value?.title ?? "Chargement...")),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.stepData.value;

        if (data == null) {
          return const Center(child: Text("Erreur de récupération des données"));
        }

        // Passage de 'data' typé StepData
        return _buildBody(data, controller);
      }),
    );
  }

  // MODIFICATION ICI : On remplace 'dynamic data' par 'StepData data'
  Widget _buildBody(StepData data, StepController controller) {
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
        case 'pdf':
          return StepFamilyPdf(
            title: data.title,
            pdfUrl: content.mediaUrl ?? "https://www.google.com",
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
    }

    else if (type == 'quiz') {
      // Dart sait maintenant que content.questions existe grâce au typage StepData
      final questionsList = content.questions;

      if (questionsList == null || questionsList.isEmpty) {
        return const Center(child: Text("Ce quiz ne contient aucune question."));
      }

      // Utilisation sécurisée de la liste
      final currentQuestion = questionsList[controller.currentQuestionIndex.value];

      if (currentQuestion.type == 'multiple_choice') {
        return QuizQCM(
          question: currentQuestion.text,
          options: currentQuestion.options,
          correctOption: currentQuestion.answer,
          lottieQuestion: 'assets/lottie/mascot.json',
          lottieCorrect: 'assets/lottie/Happy mascot.json',
          lottieIncorrect: 'assets/lottie/Sad mascot.json',
          onNext: () => controller.nextQuestion(),
        );
      }

      return const Center(child: Text("Type de question non supporté"));
    }

    return const Center(child: Text("Type de contenu inconnu"));
  }
}