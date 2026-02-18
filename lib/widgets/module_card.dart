import 'package:flutter/material.dart';
import '../models/modules/modul_model.dart'; // Vérifie bien le chemin ici

// On définit l'enum ici si elle n'est plus dans le modèle
enum ModuleStatus { completed, inProgress, locked }

class ModuleCard extends StatelessWidget {
  final ModuleModel module;
  final VoidCallback onTap;

  const ModuleCard({
    super.key,
    required this.module,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Valeurs par défaut car l'API ne les fournit pas encore
    const int completedLessons = 0;
    const int totalLessons = 5;
    const double progress = completedLessons / totalLessons;
    const ModuleStatus status = ModuleStatus.inProgress; 

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITRE (Vient de l'API)
            Text(
              module.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            /// SOUS-TITRE (On utilise 'description' de l'API)
            Text(
              module.description,
              style: TextStyle(color: Colors.grey.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            /// PROGRESSION (Factice pour l'instant)
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                    color: const Color.fromARGB(255, 0, 206, 209),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '$completedLessons / $totalLessons',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// STATUT
            _buildStatus(status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(ModuleStatus status) {
    switch (status) {
      case ModuleStatus.completed:
        return _statusChip('Terminé', Icons.check, const Color.fromARGB(255, 0, 206, 209));
      case ModuleStatus.inProgress:
        return _actionButton('Continuer', Icons.arrow_forward, const Color.fromARGB(255, 255, 127, 0));
      case ModuleStatus.locked:
        return _statusChip('Verrouillé', Icons.lock, const Color.fromARGB(255, 192, 192, 192));
    }
  }

  Widget _actionButton(String label, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Icon(icon, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  Widget _statusChip(String label, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}