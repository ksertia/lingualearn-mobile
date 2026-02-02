import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/module_model.dart';
import '../../../widgets/module_card.dart';
import '../../../widgets/timeline_dot.dart';
import '../../../helpers/storage/local_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String lastName = "Utilisateur";

  final List<ModuleModel> modules = [
    ModuleModel(
      id: '1',
      title: 'Etape 1',
      subtitle: 'Bases : Salutations',
      completedLessons: 5,
      totalLessons: 5,
      status: ModuleStatus.completed,
    ),
    ModuleModel(
      id: '2',
      title: 'Etape 2',
      subtitle: 'Présentations',
      completedLessons: 2,
      totalLessons: 5,
      status: ModuleStatus.inProgress,
    ),
    ModuleModel(
      id: '3',
      title: 'Etape 3',
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

  void _loadUserData() async {
    String? storedName = await LocalStorage.getUserName();
    if (storedName != null) {
      setState(() {
        lastName = storedName.split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'LinguaLearn',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.notifications_none, color: Colors.black),
        //     onPressed: () {},
        //   ),
        // ],
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
                  "Ne y windiga, $lastName ! 🇧🇫",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text("Prêt pour ta leçon de Mooré ?", style: TextStyle(color: Colors.grey)),
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
                      Column(
                        children: [
                          TimelineDot(status: module.status),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: module.status == ModuleStatus.completed 
                                    ? Colors.green 
                                    : Colors.grey.shade300,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: ModuleCard(
                            module: module,
                            onTap: () {
                              if (module.status != ModuleStatus.locked) {
                                // Get.toNamed('/module-detail', arguments: module);
                              } else {
                                Get.snackbar("Verrouillé", "Termine le module précédent !");
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
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}