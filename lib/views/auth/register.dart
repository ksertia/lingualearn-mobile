import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
final controller = Get.put(RegisterController());
  int currentStep = 0;

  void nextStep() {
    if (controller.formKey.currentState!.validate()) {
      if (currentStep < 1) {
        setState(() => currentStep++);
      } else {
        controller.onRegister();
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) setState(() => currentStep--);
  }

  String get stepTitle {
    return currentStep == 0 ? "Informations personnelles" : "Sécurité du compte";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                "Étape ${currentStep + 1}/2",
                style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 153),
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              Text(
                stepTitle,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E232C)),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: controller.formKey, 
                    child: currentStep == 0 ? buildStep1() : buildStep2(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    if (currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: previousStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Color.fromARGB(255, 0, 0, 153)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Précédent", style: TextStyle(color: Color(0xFF1E232C))),
                        ),
                      ),
                    if (currentStep > 0) const SizedBox(width: 15),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 0, 153),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: controller.isLoading.value 
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              currentStep == 1 ? "S'inscrire" : "Suivant",
                              style: const TextStyle(color: Colors.white),
                            ),
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: currentStep == 0 ? _buildLoginLink() : null,
    );
  }

  Widget buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Prénom"),
        TextFormField(
          controller: controller.firstName,
          keyboardType: TextInputType.text,
          decoration: _buildInputDecoration("Entrez votre prénom"),
          validator: (value) => value!.isEmpty ? "Veuillez entrer votre prénom" : null,
        ),
        const SizedBox(height: 15),
        _buildLabel("Nom"),
        TextFormField(
          controller: controller.lastName,
          keyboardType: TextInputType.text,
          decoration: _buildInputDecoration("Entrez votre nom"),
          validator: (value) => value!.isEmpty ? "Veuillez entrer votre nom" : null,
        ),
        const SizedBox(height: 15),
        _buildLabel("Email"),
        TextFormField(
          controller: controller.email,
          keyboardType: TextInputType.emailAddress,
          decoration: _buildInputDecoration("Entrez votre adresse email"),
          validator: (value) => value!.isEmpty ? "Veuillez entrer votre email" : null,
        ),
        const SizedBox(height: 15),
        _buildLabel("Téléphone"),
        TextFormField(
          controller: controller.phone,
          keyboardType: TextInputType.phone,
          decoration: _buildInputDecoration("Entrez votre numéro de téléphone"),
          validator: (value) => value!.isEmpty ? "Veuillez entrer votre numéro" : null,
        ),
      ],
    );
  }

  Widget buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Mot de passe"),
        GetBuilder<RegisterController>(builder: (_) => TextFormField(
          controller: controller.password,
          obscureText: !controller.showPassword,
          decoration: _buildInputDecoration("Entrez votre mot de passe").copyWith(
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(controller.showPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => controller.toggleShowPassword(),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "Obligatoire";
            if (value.length < 6) return "Minimum 6 caractères";
            return null;
          },
        )),
        const SizedBox(height: 15),
        _buildLabel("Confirmer le mot de passe"),
        TextFormField(
          controller: controller.confirmPassword,
          obscureText: true,
          decoration: _buildInputDecoration("Répétez votre mot de passe").copyWith(
            prefixIcon: const Icon(Icons.lock_reset),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "Obligatoire";
            if (value != controller.password.text) return "Mots de passe différents";
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Déjà un compte ?"),
          TextButton(
            onPressed: () => Get.toNamed('/login'),
            child: const Text(
              "Se connecter", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 153))
            ),
          ),
        ],
      ),
    );
  }
}