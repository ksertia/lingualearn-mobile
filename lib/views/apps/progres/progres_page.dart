import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgresPage extends StatelessWidget {
  const ProgresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Statistiques clés"),
                  const SizedBox(height: 15),
                  _buildQuickStats(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Maîtrise des compétences"),
                  const SizedBox(height: 15),
                  _buildSkillsGrid(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Parcours d'apprentissage"),
                  const SizedBox(height: 15),
                  _buildTimeline(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header avec dégradé et profil
Widget _buildHeader() {
  return Container(
    padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF000099), Color(0xFF4444FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ma Progression",
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Badge Langue
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        "Dioula",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Badge Niveau
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
                      ),
                      child: const Text(
                        "Niveau : Basique",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Icône Notification stylisée
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 35),
        _buildLevelProgressBar(),
      ],
    ),
  );
}

  Widget _buildLevelProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Progression du niveau", style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text("750 / 1000 XP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: 0.75,
            minHeight: 10,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
        ),
      ],
    );
  }

  // Statistiques en cartes
  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statCard("Série", "7 jrs", Icons.local_fire_department, Colors.orange),
        _statCard("XP Total", "12.5k", Icons.stars, Colors.blue),
        _statCard("Classement", "12", Icons.emoji_events, Colors.purple),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: Get.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSkillsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _skillCircle("Lecture", 0.8, Colors.blue),
        _skillCircle("Écoute", 0.45, Colors.red),
        _skillCircle("Parler", 0.6, Colors.green),
      ],
    );
  }

  Widget _skillCircle(String label, double percent, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 70,
              width: 70,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 8,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text("${(percent * 100).toInt()}%",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _timelineItem("Module 1", "Complété", "done"),
          _timelineItem("Module 2", "En cours", "loading"),
          _timelineItem("Module 3", "Verrouillé", "locked", isLast: true),
        ],
      ),
    );
  }

  Widget _timelineItem(String title, String status, String type, {bool isLast = false}) {
    IconData icon;
    Color color;

    switch (type) {
      case "done":
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case "loading":
        icon = Icons.play_circle_filled;
        color = const Color(0xFF4444FF);
        break;
      case "locked":
      default:
        icon = Icons.lock_outline;
        color = Colors.grey;
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2), width: 2),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color, Colors.grey.withOpacity(0.2)],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: type == "locked" ? Colors.grey : Colors.black87,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: type == "loading" ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
    );
  }
}