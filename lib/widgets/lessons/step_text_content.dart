import 'package:flutter/material.dart';
import 'package:tibi/widgets/mascots/audio_mascots.dart';

const Color _cOrange = Color(0xFFFF7043);

class StepTextContent extends StatelessWidget {
  final String text;
  final int stepIndex;

  const StepTextContent({
    super.key,
    required this.text,
    this.stepIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: AudioMascotPair(
                      stepIndex: stepIndex,
                      mood: AudioMascotMood.thinking,
                      size: AudioMascotSize.md,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
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
      child: text.isEmpty
          ? Text(
              'Aucun contenu pour cette leçon.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            )
          : IntrinsicHeight(
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
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 18.5,
                        height: 1.75,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
