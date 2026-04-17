import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:fasolingo/controller/apps/langue/langue_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';

class ProgresPage extends StatefulWidget {
  const ProgresPage({super.key});

  @override
  State<ProgresPage> createState() => _ProgresPageState();
}

class _ProgresPageState extends State<ProgresPage> {

  String languageName = 'Langue';
  String levelName = 'Niveau';
  bool isLoadingProgression = true;

  int totalXp = 0;
  int totalTimeSpent = 0;
  int quizScore = 0;
  int currentLevelXp = 0;
  int targetXp = 1000;

  int completedModules = 0;
  int inProgressModules = 0;
  int lockedModules = 0;
  int totalModules = 0;

  @override
  void initState() {
    super.initState();
    _loadProgressionData();
  }

  Future<void> _loadProgressionData() async {
    try {
      final langController = Get.find<LanguagesController>();
      final session = Get.find<SessionController>();

      final progression = await langController.loadProgression();

      if (progression != null && mounted) {

        if (progression['language'] != null) {
          languageName = progression['language']['name'] ?? 'Langue';
        }

        if (progression['overallProgress'] != null) {
          final overall = progression['overallProgress'];
          totalXp = overall['totalXp'] ?? 0;
          totalTimeSpent = overall['totalTimeMinutes'] ?? 0;
        }

        if (progression['levels'] != null) {
          final levels = progression['levels'] as List;
          String selectedId = session.selectedLevelId.value;

          for (var level in levels) {
            if (level['id']?.toString() == selectedId) {

              levelName = level['name'] ?? 'Niveau';

              if (level['userProgress'] != null) {
                currentLevelXp = level['userProgress']['totalXp'] ?? 0;
              }

              if (level['modules'] != null) {
                for (var module in level['modules']) {
                  totalModules++;

                  String status = 'locked';

                  if (module['userProgress'] != null) {
                    status = module['userProgress']['status'] ?? 'locked';

                    if (status == 'completed') {
                      completedModules++;
                    } else if (status == 'started' || status == 'unlocked') {
                      inProgressModules++;
                    } else {
                      lockedModules++;
                    }

                    if (module['userProgress']['quizScore'] != null) {
                      quizScore = module['userProgress']['quizScore'];
                    }
                  } else {
                    lockedModules++;
                  }
                }
              }
              break;
            }
          }
        }

        setState(() => isLoadingProgression = false);
      }
    } catch (e) {
      setState(() => isLoadingProgression = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF9C4), // jaune pastel
              Color(0xFFE1F5FE), // bleu clair
              Color(0xFFE8F5E9), // vert pastel
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoadingProgression
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
          bottom: false,
          child: Column(
            children: [

              _buildHeader(),

              const SizedBox(height: 25),

              _buildStats(),

              const SizedBox(height: 30),

              Padding(
                padding: EdgeInsets.only(
                  bottom: bottomInset + 10,
                ),
                child: _buildAdventure(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= HEADER =================
  Widget _buildHeader() {
    double progress = currentLevelXp / targetXp;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD54F), // jaune fun
            Color(0xFF4FC3F7), // bleu ciel
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
          )
        ],
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _chip(languageName),
                      const SizedBox(width: 10),
                      _chip(levelName),
                    ],
                  ),
                ],
              ),

              SizedBox(
                width: 70,
                height: 70,
                child: Lottie.asset('assets/lottie/mascot.json'),
              )
            ],
          ),

          const SizedBox(height: 20),

          Stack(
            children: [
              Container(
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Colors.yellow, Colors.green],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    "$currentLevelXp / $targetXp XP",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          Text("Encore ${targetXp - currentLevelXp} XP 🔥"),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7043),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Continuer",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }

  /// ================= STATS =================
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "🏆 Tes exploits",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              _statCard("⭐", "$totalXp XP", const Color(0xFFFFEB3B)),
              const SizedBox(width: 12),
              _statCard("🔥", "$totalTimeSpent min", const Color(0xFFFF9800)),
              const SizedBox(width: 12),
              _statCard("🎯", "$quizScore%", const Color(0xFF42A5F5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String icon, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.3),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 10),
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  /// ================= 🎮 AVENTURE =================
  Widget _buildAdventure() {
    double completed = totalModules > 0 ? completedModules / totalModules : 0;
    double progress = totalModules > 0 ? inProgressModules / totalModules : 0;
    double locked = totalModules > 0 ? lockedModules / totalModules : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "🎮 Ton aventure magique",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circle("🧭", "Progression", completed, const Color(0xFF42A5F5)),
              _circle("🔥", "En cours", progress, const Color(0xFFFF7043)),
              _circle("🔒", "Restant", locked, const Color(0xFFBDBDBD)),
            ],
          )
        ],
      ),
    );
  }

  Widget _circle(String icon, String label, double value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 9,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(icon, style: const TextStyle(fontSize: 20)),
          ],
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}