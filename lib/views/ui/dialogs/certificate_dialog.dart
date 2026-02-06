
import 'package:flutter/material.dart';

class CertificateDialog extends StatelessWidget {
  const CertificateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium,
              color: Colors.blue, size: 80),
          const SizedBox(height: 12),
          const Text("Certificat obtenu !",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            "Vous avez complété toutes les leçons.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Partager le certificat"),
          ),
        ],
      ),
    );
  }
}
