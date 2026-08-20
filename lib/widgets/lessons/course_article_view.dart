import 'package:flutter/material.dart';
import 'package:tibi/models/contents/content_model.dart';
import 'package:tibi/widgets/mascots/audio_mascots.dart';

const Color _cOrange = Color(0xFFFF7043);

class CourseArticleView extends StatelessWidget {
  final String title;
  final List<ContentBlockModel> blocks;

  const CourseArticleView({
    super.key,
    required this.title,
    required this.blocks,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: AudioMascotPair(
              stepIndex: 0,
              mood: AudioMascotMood.thinking,
              size: AudioMascotSize.md,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 20),
          if (blocks.isEmpty)
            Text(
              'Aucun contenu pour cette leçon.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            )
          else
            for (final block in blocks) ...[
              _buildSectionCard(block),
              const SizedBox(height: 14),
            ],
        ],
      ),
    );
  }

  Widget _buildSectionCard(ContentBlockModel block) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _cOrange,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (block.caption != null && block.caption!.isNotEmpty) ...[
                    Text(
                      block.caption!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: _cOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    block.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
