import 'package:fasolingo/widgets/stepsscreens/audio_step_page.dart';
import 'package:fasolingo/widgets/stepsscreens/pdf_step_page.dart';
import 'package:fasolingo/widgets/stepsscreens/quiz_step_page.dart';
import 'package:fasolingo/widgets/stepsscreens/text_step_page.dart';
import 'package:fasolingo/widgets/stepsscreens/video_step_page.dart';
import 'package:flutter/material.dart';

class StepContentScreen extends StatelessWidget {
  final dynamic stepData;
  final int index;

  const StepContentScreen({super.key, required this.stepData, required this.index});

  @override
  Widget build(BuildContext context) {
    
    switch (index) {
      case 0:
        return AudioStepPage(data: stepData); 
      case 1:
        return VideoStepPage(data: stepData);
      case 2:
        return TextStepPage(data: stepData);
      case 3:
        return PdfStepPage(data: stepData);
      case 4:
        return QuizStepPage(data: stepData);
      default:
        return Scaffold(
          appBar: AppBar(title: const Text("Erreur")),
          body: const Center(child: Text("Étape non configurée")),
        );
    }
  }
}