import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/storage/local_storage.dart';
import '../../../models/module_model.dart';
import '../../../widgets/module_card.dart';
import '../../../widgets/timeline_dot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String firstName = "Utilisateur";
  final SessionController session = Get.find<SessionController>();

  final List<ModuleModel> modules = [
    ModuleModel(
      id: '1',
      title: 'Étape 1',
      subtitle: 'Bases : Salutations',
      completedLessons: 5,
      totalLessons: 5,
      status: ModuleStatus.completed,
    ),
    ModuleModel(
      id: '2',
      title: 'Étape 2',
      subtitle: 'Présentations',
      completedLessons: 2,
      totalLessons: 5,
      status: ModuleStatus.inProgress,
    ),
    ModuleModel(
      id: '3',
      title: 'Étape 3',
      subtitle: 'Expressions courantes',
      completedLessons: 0,
      totalLessons: 5,
      status: ModuleStatus.locked,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    String fullName = LocalStorage.getUserName() ?? "Utilisateur";
    setState(() {
      firstName = fullName;
    });
  }

  @override
  Widget build(BuildContext context) {

    String greeting = "Bonjour";
    if (session.langueChoisie.toLowerCase().contains("mooré")) {
      greeting = "Ne y windiga";
    } else if (session.langueChoisie.toLowerCase().contains("dioula")) {
      greeting = "I ni sogoma";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'LinguaLearn',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Text(firstName[0], style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$greeting, $firstName ! 🇧🇫",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "Prêt pour ta leçon de ${session.langueChoisie.isEmpty ? 'langue locale' : session.langueChoisie} ?",
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(Icons.local_fire_department, "3", "Jours", Colors.orange),
                    _buildStatItem(Icons.star, "1250", "XP", Colors.blue),
                    _buildStatItem(Icons.emoji_events, "Bronze", "Ligue", Colors.amber),
                  ],
                ),
              ],
            ),
          ),

          // --- LISTE DES MODULES (TIMELINE) ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 40),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                bool isLast = index == modules.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // La ligne verticale (Timeline)
                      Column(
                        children: [
                          TimelineDot(status: module.status),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 3,
                                color: module.status == ModuleStatus.completed 
                                    ? Colors.green 
                                    : Colors.grey.shade300,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      
                      // La carte du module
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: ModuleCard(
                            module: module,
                            onTap: () {
                              if (module.status != ModuleStatus.locked) {
                                // Action vers les leçons du module
                                print("Ouverture du module: ${module.title}");
                              } else {
                                Get.snackbar(
                                  "Module Verrouillé", 
                                  "Termine l'étape précédente pour débloquer celle-ci !",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.black87,
                                  colorText: Colors.white,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}