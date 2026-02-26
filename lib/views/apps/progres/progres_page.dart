import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  
  // Données depuis le backend
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
  
  // Liste des MODULES depuis le backend
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
          
          // Chercher le niveau actuel
          for (var level in levels) {
            if (level['id']?.toString() == session.selectedLevelId.value) {
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Text(
                          languageName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
                        ),
                        child: Text(
                          levelName,
                          style: const TextStyle(
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
    final progressValue = targetXp > 0 ? currentLevelXp / targetXp : 0.0;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Progression du niveau", style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text("$currentLevelXp / $targetXp XP", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progressValue.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
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
        _statCard("XP Total", _formatXp(totalXp), Icons.stars, Colors.blue),
        _statCard("Quiz", "$quizScore%", Icons.quiz, Colors.purple),
        _statCard("Temps", timeDisplay, Icons.timer, Colors.green),
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
    double lecturePercent = totalModules > 0 ? completedModules / totalModules : 0.0;
    double ecoutePercent = totalModules > 0 ? (completedModules + inProgressModules) / totalModules : 0.0;
    double parlerPercent = totalModules > 0 ? completedModules / totalModules : 0.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _skillCircle("Lecture", lecturePercent, Colors.blue),
        _skillCircle("Écoute", ecoutePercent, Colors.red),
        _skillCircle("Parler", parlerPercent, Colors.green),
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
        children: modules.asMap().entries.map((entry) {
          final index = entry.key;
          final module = entry.value;
          final isLast = index == modules.length - 1;
          
          return _moduleItem(
            module['title'] ?? 'Module',
            _getStatusText(module['status'] ?? 'locked'),
            module['status'] ?? 'locked',
            isLast: isLast,
          );
        }).toList(),
      ),
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

  Widget _moduleItem(String title, String status, String type, {bool isLast = false}) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case "completed":
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case "unlocked":
      case "started":
        icon = Icons.play_circle_filled;
        color = const Color(0xFF4444FF);
        break;
      default:
        icon = Icons.lock_outline;
        color = Colors.grey;
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
