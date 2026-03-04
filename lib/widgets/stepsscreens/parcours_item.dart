import 'package:flutter/material.dart';

class ParcoursItem extends StatelessWidget {
  final String label;
  final String status;
  final Color mainColor;
  final IconData icon;
  final VoidCallback onTap;
  final bool isCompleted;
  final bool isActive;

  const ParcoursItem({
    super.key,
    required this.label,
    required this.status,
    required this.mainColor,
    required this.icon,
    required this.onTap,
    this.isCompleted = false,
    this.isActive = false,
  });

  // Couleurs basées sur le statut
  Color get _statusColor {
    if (isCompleted) {
      return const Color(0xFF81C784); // Vert clair
    } else if (isActive) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFF9E9E9E); // Gris
    }
  }

  Color get _cardBackgroundColor {
    if (isCompleted) {
      return const Color(0xFFE8F5E9); // Vert très clair
    } else if (isActive) {
      return const Color(0xFFFFF3E0); // Orange très clair
    } else {
      return const Color(0xFFF5F5F5); // Gris très clair
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // 🔵 Cercle de statut À L'EXTÉRIEUR (à gauche)
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _statusColor,
                    _statusColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _statusColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _statusColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 30)
                    : Icon(icon, color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(width: 15),

            // 📝 Carte à l'intérieur
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _statusColor.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _statusColor.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge de statut en haut
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isCompleted
                                      ? Icons.check_circle
                                      : (isActive
                                          ? Icons.play_circle
                                          : Icons.lock),
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Titre
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isActive || isCompleted
                                  ? const Color(0xFF2D3436)
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Flèche à droite
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: _statusColor,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
