import 'package:flutter/material.dart';
import 'package:tibi/widgets/mascots/audio_mascots.dart';

const Color _cOrange = Color(0xFFFF7043);

class StepTextContent extends StatelessWidget {
  final String title;
  final String text;
  final int stepIndex;

  const StepTextContent({
    super.key,
    required this.title,
    required this.text,
    this.stepIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AudioMascotPair(
                stepIndex: stepIndex,
                mood: AudioMascotMood.thinking,
                size: AudioMascotSize.sm,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _cOrange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          color: _cOrange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: text.isEmpty
                ? Text(
                    'Aucun contenu pour cette leçon.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15.5,
                      height: 1.6,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
