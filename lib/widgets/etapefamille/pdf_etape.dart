import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class StepFamilyPdf extends StatelessWidget {
  final String title;
  final String pdfUrl;

  const StepFamilyPdf({
    super.key,
    required this.title,
    required this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        Expanded(
          child: PDF().fromUrl(
            pdfUrl,
            placeholder: (progress) =>
                Center(child: Text("$progress %")),
            errorWidget: (error) =>
            const Center(child: Text("Erreur PDF")),
          ),
        ),
      ],
    );
  }
}