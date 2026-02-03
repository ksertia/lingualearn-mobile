import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RevisionPage extends StatelessWidget {
  const RevisionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF004AAD),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text("Réviser : Leçon 1",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF004AAD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("Mode Révision",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 25),

            // Liste des exercices de révision (Quiz supprimé ici)
            _buildRevisionItem("01. Dialogue de présentation", "Revoir", Icons.redo, Colors.blue),
            _buildRevisionItem("02. Mots de vocabulaire", "Terminé", Icons.check_circle, Colors.green),

            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Ressources",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildResourceTile(Icons.picture_as_pdf, "Télécharger le résumé (PDF)"),
            _buildResourceTile(Icons.refresh, "Revoir la leçon"),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildRevisionItem(String title, String status, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blue.shade100),
          borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(status, style: TextStyle(color: color)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5DB01E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Commencer", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildResourceTile(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(label),
      onTap: () {},
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              child: const Text("Quitter le mode Révision"),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AAD)),
              child: const Text("Terminer la révision", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}