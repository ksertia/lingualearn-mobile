import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:fasolingo/controller/apps/langue/langue_controller.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';

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
  double globalProgress = 0;
  int completedModules = 0;
  int inProgressModules = 0;
  int lockedModules = 0;
  int totalModules = 0;
  int currentLevelXp = 0;
  int targetXp = 1000;
  
  List<Map<String, dynamic>> modules = [];

  @override
  void initState() {
    super.initState();
    _loadProgressionData();
  }

  Future<void> _loadProgressionData() async {
    try {
      final langController = Get.find<LanguagesController>();
      final session = Get.find<SessionController>();
      
      // Charger la progression via l'API
      final progression = await langController.loadProgression();
      
      if (progression != null && mounted) {
        // Extraire les infos de la progression depuis le backend
        if (progression['language'] != null) {
          languageName = progression['language']['name']?.toString() ?? 'Langue';
        }
        
        // overallProgress - statistiques globales
        if (progression['overallProgress'] != null) {
          final overall = progression['overallProgress'];
          totalXp = overall['totalXp'] ?? 0;
          totalTimeSpent = overall['totalTimeMinutes'] ?? 0;
          globalProgress = double.tryParse(overall['overallProgress']?.toString() ?? '0') ?? 0;
          currentLevelXp = totalXp % targetXp;
        }
        
        // Vider les listes
        modules.clear();
        
        // levels - compter les modules par statut et récupérer les modules
        if (progression['levels'] != null) {
          final levels = progression['levels'] as List;

          // Determine selected level id: prefer session, else fallback to 'isCurrent' or highest progress
          String selectedId = session.selectedLevelId.value;
          bool foundMatch = false;
          if (selectedId.isNotEmpty) {
            for (var lvl in levels) {
              if (lvl['id']?.toString() == selectedId) {
                foundMatch = true;
                break;
              }
            }
          }

          if (!foundMatch) {
            String? fallbackId;
            double bestProgress = -1;
            for (var lvl in levels) {
              final lp = lvl['userProgress'];
              if (lp != null) {
                if (lp['isCurrent'] == true) {
                  fallbackId = lvl['id']?.toString();
                  break;
                }
                final p = double.tryParse(lp['progressPercentage']?.toString() ?? '0') ?? 0;
                if (p > bestProgress) {
                  bestProgress = p;
                  fallbackId = lvl['id']?.toString();
                }
              }
            }
            selectedId = fallbackId ?? (levels.isNotEmpty ? levels.first['id']?.toString() ?? "" : "");
            if (selectedId.isNotEmpty) {
              // update session and persist so other pages and future launches use the correct level
              try {
                final sessionCtrl = Get.find<SessionController>();
                sessionCtrl.selectedLevelId.value = selectedId;
                LocalStorage.setSelectedLevelId(selectedId);
              } catch (_) {}
            }
          }

          // Chercher le niveau correspondant au selectedId
          for (var level in levels) {
            if (level['id']?.toString() == selectedId) {
              levelName = level['name']?.toString() ?? 'Niveau';

              // Utiliser les données de progression du niveau
              if (level['userProgress'] != null) {
                final levelProgress = level['userProgress'];
                globalProgress = double.tryParse(levelProgress['progressPercentage']?.toString() ?? '0') ?? 0;
                currentLevelXp = levelProgress['totalXp'] ?? 0;
              }

              // Récupérer les MODULES
              if (level['modules'] != null) {
                final levelModules = level['modules'] as List;
                for (var module in levelModules) {
                  totalModules++;

                  String moduleStatus = 'locked';
                  double moduleProgressPercent = 0;

                  if (module['userProgress'] != null) {
                    final moduleProgress = module['userProgress'];
                    moduleStatus = moduleProgress['status']?.toString() ?? 'locked';
                    moduleProgressPercent = double.tryParse(moduleProgress['progressPercentage']?.toString() ?? '0') ?? 0;

                    if (moduleStatus == 'completed') {
                      completedModules++;
                    } else if (moduleStatus == 'unlocked' || moduleStatus == 'started') {
                      inProgressModules++;
                    } else {
                      lockedModules++;
                    }

                    // Quiz score
                    if (moduleProgress['quizScore'] != null) {
                      quizScore = moduleProgress['quizScore'] is int
                          ? moduleProgress['quizScore']
                          : (moduleProgress['quizScore'] as double).toInt();
                    }
                  } else {
                    lockedModules++;
                  }

                  modules.add({
                    'title': module['title'] ?? 'Module',
                    'description': module['description'] ?? '',
                    'status': moduleStatus,
                    'progressPercentage': moduleProgressPercent,
                  });
                }
              }
              break;
            }
          }
        }
        
        setState(() {
          isLoadingProgression = false;
        });
      } else {
        setState(() {
          isLoadingProgression = false;
        });
      }
    } catch (e) {
      print("❌ Erreur chargement progression: $e");
      if (mounted) {
        setState(() {
          isLoadingProgression = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: isLoadingProgression
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProgressionData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                          _buildModulesList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 56, left: 20, right: 20, bottom: 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFC107), Color(0xFF4DD0E1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
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
                      color: Color(0xFF2D2D2D), 
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          languageName,
                          style: const TextStyle(
                            color: Color(0xFF2D2D2D),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          levelName,
                          style: const TextStyle(
                            color: Color(0xFF4DD0E1),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 84,
                height: 84,
                child: Lottie.asset(
                  'assets/lottie/mascot.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _buildLevelProgressBar(),
        ],
      ),
    );
  }

  Widget _buildLevelProgressBar() {
    final progressValue = targetXp > 0 ? currentLevelXp / targetXp : 0.0;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Progression du niveau", style: TextStyle(color: Color(0xFF2D2D2D), fontSize: 12)),
            Text("$currentLevelXp / $targetXp XP", style: const TextStyle(color: Color(0xFF2D2D2D), fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progressValue.clamp(0.0, 1.0),
            minHeight: 12,
            backgroundColor: Colors.white.withOpacity(0.6),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFA726)),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    String timeDisplay;
    if (totalTimeSpent >= 60) {
      final hours = totalTimeSpent ~/ 60;
      final mins = totalTimeSpent % 60;
      timeDisplay = mins > 0 ? "${hours}h ${mins}m" : "${hours}h";
    } else {
      timeDisplay = "${totalTimeSpent}m";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statCard("XP Total", _formatXp(totalXp), Icons.stars, const Color(0xFF4DD0E1)),
        _statCard("Quiz", "$quizScore%", Icons.quiz, const Color(0xFFFFB74D)),
        _statCard("Temps", timeDisplay, Icons.timer, const Color(0xFF81C784)),
      ],
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) {
      return "${(xp / 1000).toStringAsFixed(1)}k";
    }
    return xp.toString();
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: Get.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.18), Colors.white]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSkillsGrid() {
    double lecturePercent = totalModules > 0 ? completedModules / totalModules : 0.0;
    double ecoutePercent = totalModules > 0 ? (completedModules + inProgressModules) / totalModules : 0.0;
    double parlerPercent = totalModules > 0 ? completedModules / totalModules : 0.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _skillCircle("Lecture", lecturePercent, const Color(0xFF4DD0E1)),
        _skillCircle("Écoute", ecoutePercent, const Color(0xFFFFB74D)),
        _skillCircle("Parler", parlerPercent, const Color(0xFF81C784)),
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
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 10,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text("${(percent * 100).toInt()}%",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildModulesList() {
    if (modules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "Aucun module disponible",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: modules.asMap().entries.map((entry) {
        final index = entry.key;
        final module = entry.value;
        final isLast = index == modules.length - 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _moduleCard(
            module['title'] ?? 'Module',
            _getStatusText(module['status'] ?? 'locked'),
            module['status'] ?? 'locked',
            isCompleted: module['status'] == 'completed',
          ),
        );
      }).toList(),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Complété';
      case 'unlocked':
      case 'started':
        return 'En cours';
      default:
        return 'Verrouillé';
    }
  }

  Widget _moduleCard(String title, String status, String type, {bool isCompleted = false}) {
    // playful card with external circle
    final bool isActive = type == 'unlocked' || type == 'started';
    
    // Couleurs: Terminé=vert clair, En cours=orange, Verrouillé=gris
    final Color main = isCompleted
        ? const Color(0xFF81C784)  // Vert clair
        : isActive
            ? const Color(0xFFFF9800)  // Orange
            : const Color(0xFF9E9E9E);  // Gris

    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 36,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isCompleted
                    ? const LinearGradient(colors: [Color(0xFFE8F5E9), Color(0xFFB9F6CA)])
                    : (isActive
                        ? const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFECB3)])
                        : const LinearGradient(colors: [Color(0xFFF5F5F5), Color(0xFFFFFFFF)])),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 6))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isActive || isCompleted ? Colors.black87 : Colors.grey.shade700)),
                        const SizedBox(height: 6),
                        Text(status, style: TextStyle(fontSize: 13, color: isActive || isCompleted ? main.withOpacity(0.95) : Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Icon(isCompleted ? Icons.check_circle : (isActive ? Icons.play_circle_fill : Icons.lock_outline), color: main, size: 30),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            top: 18,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 6))],
              ),
              child: Center(
                child: Icon(isCompleted ? Icons.star : (isActive ? Icons.play_arrow : Icons.lock), color: main, size: 34),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
    );
  }
}
