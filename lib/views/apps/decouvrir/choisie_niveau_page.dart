import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChoisieNiveauPage extends StatefulWidget {
  const ChoisieNiveauPage({super.key});

  @override
  State<ChoisieNiveauPage> createState() => _ChoisieNiveauPageState();
}

class _ChoisieNiveauPageState extends State<ChoisieNiveauPage> {
  String selectedLevel = "";

  final List<Map<String, dynamic>> levels = [
    {
      "id": "beginner",
      "title": "Débutant",
      "desc": "Je ne connais pas encore cette langue.",
      "icon": Icons.child_care,
    },
    {
      "id": "intermediate",
      "title": "Intermédiaire",
      "desc": "Je connais quelques bases.",
      "icon": Icons.menu_book,
    },
    {
      "id": "advanced",
      "title": "Avancé",
      "desc": "Je veux me perfectionner.",
      "icon": Icons.psychology,
    },
    {
      "id": "test",
      "title": "Passer un test",
      "desc": "Évaluez votre niveau automatiquement.",
      "icon": Icons.assignment_turned_in,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color.fromARGB(255, 0, 0, 153);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 127, 0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Sélectionne ton niveau',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Quel est votre niveau ?",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 10),
            Text(
              "Cela nous aidera à adapter les leçons pour vous.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 35),
            Expanded(
              child: ListView.separated(
                itemCount: levels.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final level = levels[index];
                  bool isSelected = selectedLevel == level['id'];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: InkWell(
                      onTap: () => setState(() => selectedLevel = level['id']!),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withOpacity(0.05)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : Colors.grey.shade200,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: primaryColor.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                level['icon'],
                                color: isSelected ? Colors.white : Colors.grey,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    level['title']!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    level['desc']!,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_off,
                              color: isSelected
                                  ? primaryColor
                                  : Colors.grey.shade300,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: selectedLevel.isNotEmpty
                      ? [
                          BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6))
                        ]
                      : [],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: selectedLevel.isEmpty
                      ? null
                      : () => Get.offAllNamed('/HomeScreen'),
                  child: const Text(
                    "C'EST PARTI !",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
