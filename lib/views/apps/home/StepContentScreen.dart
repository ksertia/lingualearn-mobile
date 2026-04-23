import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryImage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryAudio.dart';
import 'package:fasolingo/widgets/decouvrir_page/decouverte/StepDiscoveryVideo.dart';
import 'package:fasolingo/widgets/lessons/qcm.dart';
import '../../../controller/apps/etapes/stepController.dart';
import '../../../models/etapes/steps_model.dart';

const Color _cOrange  = Color(0xFFFF7043);
const Color _cOrange2 = Color(0xFFFFB74D);

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
      extendBodyBehindAppBar: true,
      appBar: _appBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) return _loading();

        final data = controller.stepData.value;

        if (data == null) return _error();

        return Column(
          children: [
            Expanded(
              child: _buildBody(context, data, controller),
            ),
            if (data.type != 'quiz') _completeButton(controller),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _appBar(StepController controller) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_cOrange, _cOrange2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 17),
          ),
        ),
      ),
      title: Obx(() => Text(
            controller.stepData.value?.title ?? 'Chargement...',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          )),
    );
  }

  Widget _loading() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cOrange.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: _cOrange,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chargement du contenu...',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _error() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: _cOrange.withValues(alpha: 0.15), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _cOrange.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.article_outlined,
                      color: _cOrange, size: 42),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Aucun contenu disponible',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Il n\'y a pas encore de contenu disponible pour cette etape.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.5),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: Get.back,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_cOrange, _cOrange2],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _cOrange.withValues(alpha: 0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Retour',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _completeButton(StepController controller) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Obx(
          () => GestureDetector(
            onTap: controller.isCompleting.value
                ? null
                : () => controller.completeCurrentStep(
                      stepId: stepId,
                      userId: userId,
                    ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 54,
              decoration: BoxDecoration(
                gradient: controller.isCompleting.value
                    ? null
                    : const LinearGradient(
                        colors: [_cOrange, _cOrange2],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                color: controller.isCompleting.value
                    ? Colors.grey.shade300
                    : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: controller.isCompleting.value
                    ? []
                    : [
                        BoxShadow(
                          color: _cOrange.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Center(
                child: controller.isCompleting.value
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Terminer l'etape",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
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
            videoUrl: content.mediaUrl ?? '',
            onVideoFinished: () => Get.back(),
          );
        case 'image':
          return StepDiscoveryImage(
            title: data.title,
            imageUrl: content.mediaUrl ?? '',
            answerText: content.text ?? '',
          );
        case 'audio':
          return StepDiscoveryAudio(
            title: data.title,
            texteOriginal: content.text ?? '',
            traduction: 'Repete apres moi',
            lottie: 'assets/lottie/mascot.json',
          );
        default:
          return Center(child: Text(content.text ?? 'Lecon textuelle'));
      }
    } else if (type == 'quiz') {
      final questionsList = content.questions;

      if (questionsList == null || questionsList.isEmpty) {
        return Container(
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                      color: _cOrange.withValues(alpha: 0.15), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _cOrange.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.quiz_outlined,
                          color: _cOrange, size: 42),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Aucune question disponible',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ce quiz ne contient pas encore de questions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          height: 1.5),
                    ),
                    const SizedBox(height: 22),
                    GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 13),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_cOrange, _cOrange2],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _cOrange.withValues(alpha: 0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Retour',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
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

      return const Center(child: Text('Type de question non supporte'));
    }

    return const Center(child: Text('Type de contenu inconnu'));
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
                  color: Colors.black.withValues(alpha: 0.2),
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
                          'Nous avons une surprise pour vous',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tu as termine le quiz\nBravo pour ta perseverance !',
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
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            'Tu gagnes une recompense speciale pour ta reussite !',
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
                                'Terminer',
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
