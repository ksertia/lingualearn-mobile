import 'package:flutter/material.dart';

class ParcoursStepItem extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final Color color;
  final String? statusText;
  final bool isCompleted;
  final bool isActive;
  final VoidCallback? onTap;
  final IconData? icon;

  const ParcoursStepItem({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
    this.statusText,
    this.isCompleted = false,
    this.isActive = false,
    this.onTap,
    this.icon,
  });


  Color get _statusBackgroundColor {
    if (isCompleted) {
      return const Color(0xFF81C784);
    } else if (isActive && !isCompleted) {
      return const Color(0xFFFF9800); 
    } else {
      return const Color(0xFF9E9E9E); 
    }
  }

  Color get _cardBackgroundColor {
    if (isCompleted) {
      return const Color(0xFFE8F5E9); // Vert clair (terminé)
    } else if (isActive && !isCompleted) {
      return const Color(0xFFFFF3E0); // Orange clair (en cours)
    } else {
      return const Color(0xFFF5F5F5); // Gris clair (verrouillé)
    }
  }

  Color get _borderColor {
    if (isCompleted) {
      return const Color(0xFF81C784); // Vert clair
    } else if (isActive && !isCompleted) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFBDBDBD); // Gris
    }
  }

  IconData get _statusIcon {
    if (!isActive) {
      return Icons.lock_rounded;
    } else if (isCompleted) {
      return Icons.check_circle_rounded;
    } else {
      return Icons.play_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            // Cercle d'état avec couleur basée sur le status
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _statusBackgroundColor,
                    _statusBackgroundColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _statusBackgroundColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _statusBackgroundColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 28)
                    : (icon != null
                        ? Icon(
                            icon,
                            color: isActive ? Colors.white : Colors.white70,
                            size: 28,
                          )
                        : Text(
                            number,
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.white70,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
              ),
            ),
            const SizedBox(width: 15),

            // Carte de contenu avec Column: Status en haut, titre, puis description
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _borderColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _borderColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status en haut
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _statusBackgroundColor,
                                _statusBackgroundColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _statusBackgroundColor.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _statusIcon,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                statusText ?? 'Verrouillé',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Titre
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.black87 : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description (subtitle)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isActive ? Colors.grey.shade600 : Colors.grey.shade500,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
