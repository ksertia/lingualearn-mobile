import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tibi/widgets/decouvrir_page/decouverte/StepDiscoveryVideo.dart';
import 'package:tibi/widgets/lessons/qcm.dart';
import 'package:tibi/widgets/lessons/course_article_view.dart';
import 'package:tibi/widgets/lessons/resource_pdf_view.dart';
import '../../../../controller/apps/etapes/stepController.dart';
import '../../../../models/contents/content_model.dart';

const Color _kOrange = Color(0xFFF27F22);

class StepContentScreen extends StatelessWidget {
  final String subThemeId;
  final String userId;
  final int initialIndex;

  const StepContentScreen({
    super.key,
    required this.subThemeId,
    required this.userId,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final StepController controller = Get.put(StepController());

    Future.microtask(
        () => controller.loadContents(subThemeId, initialIndex: initialIndex));

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

        final contents = controller.contents;
        if (contents.isEmpty) {
          return Column(
            children: [
              _progressHeader(0),
              Expanded(
                child: _error(controller.loadErrorMsg.value ??
                    'Ce sous-thème ne contient pas encore de contenu.'),
              ),
            ],
          );
        }

        final index = controller.currentContentIndex.value;
        final content = contents[index];
        final isLastContent = index == contents.length - 1;
        final hasOwnNavigation = content.contentType == 'video' ||
            content.contentType == 'exercise';
        final progress = (index + 1) / contents.length;

        return Column(
          children: [
            _progressHeader(progress),
            Expanded(child: _buildContentBody(content, controller)),
            if (!hasOwnNavigation) _navigationBar(controller, isLastContent),
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
                      'Il n\'y a pas encore de contenu disponible pour ce sous-thème.',
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

  Widget _navigationBar(StepController controller, bool isLastContent) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Obx(() {
          final hasPrevious = controller.currentContentIndex.value > 0;
          return Row(
            mainAxisAlignment: hasPrevious
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.end,
            children: [
              if (hasPrevious)
                GestureDetector(
                  onTap: controller.previousContent,
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
              _nextButton(controller, isLastContent),
            ],
          );
        }),
      ),
    );
  }

  Widget _nextButton(StepController controller, bool isLastContent) {
    return GestureDetector(
      onTap: controller.nextContent,
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
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLastContent ? 'Terminer' : 'Suivant',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                isLastContent
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: Colors.white,
                size: isLastContent ? 18 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentBody(ContentModel content, StepController controller) {
    switch (content.contentType) {
      case 'course':
        return CourseArticleView(
          title: content.title,
          blocks: content.blocks,
        );
      case 'video':
        return StepDiscoveryVideo(
          videoTitle: content.title,
          videoUrl: content.videoUrl ?? '',
          onVideoFinished: controller.nextContent,
          showTitle: true,
        );
      case 'exercise':
        return Column(
          children: [
            if (content.statement != null && content.statement!.isNotEmpty)
              _instructionBanner(content.statement!),
            Expanded(
              child: QuizQCM(
                key: ValueKey(controller.currentContentIndex.value),
                question: content.question ?? '',
                options: content.possibleAnswers ?? [],
                correctOption: content.correctAnswer ?? '',
                questionIndex: controller.currentContentIndex.value,
                onNext: controller.nextContent,
              ),
            ),
          ],
        );
      case 'resource':
        return ResourcePdfView(
          title: content.title,
          resourceUrl: content.resourceUrl ?? '',
        );
      default:
        return const Center(child: Text('Type de contenu non supporté'));
    }
  }

  Widget _instructionBanner(String statement) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kOrange.withValues(alpha: 0.20), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: _kOrange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              statement,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
