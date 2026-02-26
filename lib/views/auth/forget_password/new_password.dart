import 'package:fasolingo/controller/auth/password/ResetPasswordController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final ResetPasswordController controller = Get.put(ResetPasswordController());
  
  bool _showPassword = false;
  
  final String token = Get.arguments ?? "";

  void _handleConfirm() async {
    String password = passwordController.text.trim();
    String confirm = confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      Get.snackbar("Champs vides", "Veuillez remplir tous les champs",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (password != confirm) {
      Get.snackbar("Erreur", "Les mots de passe ne correspondent pas",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (password.length < 6) {
      Get.snackbar("Sécurité", "Le mot de passe doit contenir au moins 6 caractères",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // Appel au contrôleur
    bool isSuccess = await controller.resetPassword(token, password);
    if (isSuccess) {
      _showSuccessBottomSheet();
    }
  }

  void _showSuccessBottomSheet() {
    Get.bottomSheet(
      isDismissible: false,
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            ),
            const SizedBox(height: 20),
            const Text(
              "Mot de passe changé avec succès",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Votre mot de passe a été réinitialisé. Vous pouvez maintenant vous connecter.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed("/login"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 153),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Me connecter à nouveau", 
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Réinitialisation",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            _buildLabel("Nouveau mot de passe"),
            TextFormField(
              controller: passwordController,
              obscureText: !_showPassword,
              decoration: _buildInputDecoration("Veuillez entrer votre nouveau mot de passe").copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildLabel("Confirmer le mot de passe"),
            TextFormField(
              controller: confirmController,
              obscureText: !_showPassword,
              decoration: _buildInputDecoration("Veuillez confirmer votre nouveau mot de passe"),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 153),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: controller.isLoading.value 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Confirmer", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              )),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 153), width: 1.5),
      ),
    );
  }
}