import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _kOrange = Color(0xFFF27F22);

class ResourcePdfView extends StatelessWidget {
  final String title;
  final String resourceUrl;

  const ResourcePdfView({
    super.key,
    required this.title,
    required this.resourceUrl,
  });

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(resourceUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            clipBehavior: Clip.antiAlias,
            child: PDF(
              swipeHorizontal: false,
              autoSpacing: true,
              fitEachPage: true,
            ).cachedFromUrl(
              resourceUrl,
              placeholder: (progress) => Center(
                child: CircularProgressIndicator(
                  value: progress > 0 ? progress / 100 : null,
                  color: _kOrange,
                ),
              ),
              errorWidget: (_) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.picture_as_pdf_outlined,
                          color: Colors.grey, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'Impossible d\'afficher le PDF ici.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: TextButton.icon(
            onPressed: _openExternally,
            icon: const Icon(Icons.open_in_new_rounded, color: _kOrange, size: 18),
            label: const Text(
              'Ouvrir dans le navigateur',
              style: TextStyle(color: _kOrange, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
