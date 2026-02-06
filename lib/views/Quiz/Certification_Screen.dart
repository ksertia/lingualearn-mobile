
import 'package:flutter/material.dart';

class CertificationScreen extends StatelessWidget {
  final String userName;
  final String moduleName;

  const CertificationScreen({
    super.key,
    required this.userName,
    required this.moduleName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.workspace_premium,
                size: 120,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              const Text(
                "Certification obtenue 🎓",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 8),
              Text(
                "a validé le module",
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                moduleName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  // Télécharger ou partager
                },
                icon: const Icon(Icons.download),
                label: const Text("Télécharger le certificat"),
              ),
              TextButton(
                onPressed: () {
                  // Continuer l’apprentissage
                },
                child: const Text("Continuer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
