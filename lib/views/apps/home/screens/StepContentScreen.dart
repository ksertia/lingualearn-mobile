import 'package:tibi/widgets/decouvrir_page/decouverte/StepDiscoveryImage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tibi/widgets/lessons/step_audio_player.dart';
import 'package:tibi/widgets/lessons/step_text_content.dart';
import 'package:tibi/widgets/decouvrir_page/decouverte/StepDiscoveryVideo.dart';
import 'package:tibi/widgets/lessons/qcm.dart';
import 'package:tibi/widgets/lessons/animated_stat_chip.dart';
import 'package:tibi/widgets/mascots/zaki_mascot.dart';
import 'package:tibi/helpers/services/sound_service.dart';
import 'XpRewardScreen.dart';
import '../../../../controller/apps/etapes/stepController.dart';
import '../../../../models/etapes/steps_model.dart';

const Color _kOrange = Color(0xFFF27F22);

class StepContentScreen extends StatelessWidget {
  final String stepId;
  final String userId;
  final String stepType;

  const StepContentScreen({
    super.key,
    required this.stepId,
    required this.userId,
    this.stepType = 'lesson',
  });

  @override
  Widget build(BuildContext context) {
    final StepController controller = Get.put(StepController());

    Future.microtask(
        () => controller.loadStepContent(stepId, userId, stepType: stepType));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Column(
            children: [
              _progressHeader(0),
              Expanded(child: _loading()),
            ],
          );
        }

        if (stepType == 'quiz') {
          final data = controller.stepData.value;
          if (data == null) {
            return Column(
              children: [
                _progressHeader(0),
                Expanded(child: _error(controller.loadErrorMsg.value)),
              ],
            );
          }

          final questionsList = data.content.questions ?? [];
          final progress = questionsList.isEmpty
              ? 0.0
              : (controller.currentQuestionIndex.value + 1) /
                  questionsList.length;

          return Column(
            children: [
              _progressHeader(progress),
              Expanded(child: _buildQuizBody(context, data, controller)),
            ],
          );
        }

        final lesson = controller.lessonData.value;
        if (lesson == null) {
          return Column(
            children: [
              _progressHeader(0),
              Expanded(child: _error(controller.loadErrorMsg.value)),
            ],
          );
        }

        final blocks = controller.lessonBlocks;
        if (blocks.isEmpty) {
          return Column(
            children: [
              _progressHeader(0),
              Expanded(
                child:
                    _error('Cette leçon ne contient pas encore de contenu.'),
              ),
            ],
          );
        }

        final blockIndex = controller.currentBlockIndex.value;
        final currentBlock = blocks[blockIndex];
        final isLastBlock = blockIndex == blocks.length - 1;
        final isVideoBlock = currentBlock.contentType == 'video';
        final progress = (blockIndex + 1) / blocks.length;

        void handleVideoFinished() {
          if (isLastBlock) {
            controller.completeCurrentStep(stepId: stepId, userId: userId);
          } else {
            controller.nextBlock();
          }
        }

        return Column(
          children: [
            _progressHeader(progress),
            Expanded(
              child: _buildLessonBlock(
                currentBlock,
                lesson.title,
                onVideoFinished: handleVideoFinished,
              ),
            ),
            if (!isVideoBlock) _navigationBar(controller, isLastBlock),
          ],
        );
      }),
    );
  }

  Widget _progressHeader(double progress) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: Get.back,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _kOrange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close_rounded,
                    color: _kOrange, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: 16,
                  backgroundColor: _kOrange.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation(_kOrange),
                ),
              ),
            ),
          ],
        ),
      ),
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
                color: _kOrange.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: _kOrange,
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

  Widget _error([String? debugMessage]) {
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
                  color: _kOrange.withValues(alpha: 0.15), width: 1.5),
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
                    color: _kOrange.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.article_outlined,
                      color: _kOrange, size: 42),
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
                  debugMessage ??
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
                        colors: [_kOrange, _kOrange],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _kOrange.withValues(alpha: 0.30),
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

  Widget _navigationBar(StepController controller, bool isLastBlock) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Obx(() {
          final hasPrevious = controller.currentBlockIndex.value > 0;
          return Row(
            mainAxisAlignment: hasPrevious
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              if (hasPrevious)
                GestureDetector(
                  onTap: controller.previousBlock,
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kOrange, width: 1.5),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chevron_left_rounded,
                              color: _kOrange, size: 20),
                          Text(
                            'Précédent',
                            style: TextStyle(
                              color: _kOrange,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              isLastBlock
                  ? _completeButton(controller)
                  : _nextBlockButton(controller),
            ],
          );
        }),
      ),
    );
  }

  Widget _completeButton(StepController controller) {
    return Obx(
      () => GestureDetector(
        onTap: controller.isCompleting.value
            ? null
            : () => controller.completeCurrentStep(
                  stepId: stepId,
                  userId: userId,
                ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: controller.isCompleting.value
                ? null
                : const LinearGradient(
                    colors: [_kOrange, _kOrange],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            color: controller.isCompleting.value
                ? Colors.grey.shade300
                : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: controller.isCompleting.value
                ? []
                : [
                    BoxShadow(
                      color: _kOrange.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: controller.isCompleting.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Terminer",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _nextBlockButton(StepController controller) {
    return GestureDetector(
      onTap: controller.nextBlock,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kOrange, _kOrange],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _kOrange.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Suivant',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonBlock(
    LessonBlock block,
    String lessonTitle, {
    required VoidCallback onVideoFinished,
  }) {
    switch (block.contentType) {
      case 'video':
        return StepDiscoveryVideo(
          videoTitle: lessonTitle,
          videoUrl: block.content,
          onVideoFinished: onVideoFinished,
          showTitle: false,
        );
      case 'image':
        return StepDiscoveryImage(
          title: lessonTitle,
          imageUrl: block.content,
          answerValue: block.caption,
          showTitle: false,
        );
      case 'audio':
        return StepAudioPlayer(
          audioUrl: block.content,
          instruction: 'Écoutez attentivement',
          answerValue: block.caption,
        );
      case 'text':
      default:
        return StepTextContent(
          text: block.content,
        );
    }
  }

  Widget _buildQuizBody(
      BuildContext context, StepData data, StepController controller) {
    final content = data.content;
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
                      color: _kOrange.withValues(alpha: 0.15), width: 1.5),
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
                        color: _kOrange.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.quiz_outlined,
                          color: _kOrange, size: 42),
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
                            colors: [_kOrange, _kOrange],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _kOrange.withValues(alpha: 0.30),
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
          questionIndex: controller.currentQuestionIndex.value,
          onAnswered: controller.recordAnswer,
          onNext: () => _handleQuizNext(context, controller, questionsList),
        );
      }

    return const Center(child: Text('Type de question non supporte'));
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
    SoundService.playBackgroundLoop();
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
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
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const ZakiMascot(
                          mood: ZakiMood.celebrating,
                          size: ZakiSize.lg,
                          animated: true,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Quiz terminé !',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedStatChip(
                                label: 'XP GAGNÉS',
                                countTo: controller.earnedXp,
                                icon: Icons.bolt_rounded,
                                color: const Color(0xFFFFC800),
                                delay: const Duration(milliseconds: 200),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AnimatedStatChip(
                                label: 'SCORE',
                                countTo: controller.scorePercentage,
                                suffix: '%',
                                icon: Icons.track_changes_rounded,
                                color: const Color(0xFF58CC02),
                                delay: const Duration(milliseconds: 500),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AnimatedStatChip(
                                label: 'TEMPS',
                                staticValue:
                                    _formatDuration(controller.quizElapsed),
                                icon: Icons.timer_outlined,
                                color: const Color(0xFF1CB0F6),
                                delay: const Duration(milliseconds: 800),
                              ),
                            ),
                          ],
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
                          : () {
                              Navigator.of(context).pop();
                              Get.off(
                                () => XpRewardScreen(
                                  xp: controller.earnedXp,
                                  scorePercent: controller.scorePercentage,
                                  elapsed: controller.quizElapsed,
                                  stepId: stepId,
                                  userId: userId,
                                  controller: controller,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF27F22),
                        disabledBackgroundColor: Colors.grey.shade300,
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
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'RÉCUPÉRER MES XP',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
    ).then((_) => SoundService.stopBackgroundLoop());
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
