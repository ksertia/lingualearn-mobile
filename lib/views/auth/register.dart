import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  int currentStep = 0;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  
void nextStep() {
  if (_formKey.currentState!.validate()) {
    if (currentStep < 1) {
      setState(() => currentStep++);
    } else {
      print("Inscription lancée pour: ${email.text}");

      Get.snackbar(
        "Succès", 
        "Votre compte a été créé avec succès !",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Future.delayed(const Duration(seconds: 1), () {
        Get.toNamed('/login'); 
      });
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
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              
              Text(
                "Étape ${currentStep + 1}/2",
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 153), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 14
                ),
              ),
              Text(
                stepTitle,
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: const Color(0xFF1E232C)
                ),
              ),
              
              SizedBox(height: 30),

              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: currentStep == 0 ? buildStep1() : buildStep2(),
                  ),
                ),
              ),


              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    if (currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: previousStep,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Color.fromARGB(255, 0, 0, 153),),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Précédent", style: TextStyle(color: Color(0xFF1E232C))),
                        ),
                      ),
                    if (currentStep > 0) SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 0, 0, 153),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          currentStep == 1 ? "S'inscrire" : "Suivant",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
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
          controller: firstName,
          keyboardType: TextInputType.text,
          decoration: _buildInputDecoration("Entrez votre prénom"),
          validator: (value) => value!.isEmpty ? "Veuillez entrer votre prénom" : null,
        ),
        SizedBox(height: 15),

        _buildLabel("Nom"),
        TextFormField(
          controller: lastName,
          keyboardType: TextInputType.text,
          decoration: _buildInputDecoration("Entrez votre nom"),
          validator: (value) => value!.isEmpty ? "Veuillez entrer votre nom" : null,
        ),
        SizedBox(height: 15),

        _buildLabel("Email"),
        TextFormField(
          controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: _buildInputDecoration("Entrez votre adresse email"),
          validator: (value) => value!.isEmpty ? "Veuillez entrer votre email" : null,
        ),
        SizedBox(height: 15),

        _buildLabel("Téléphone"),
        TextFormField(
          controller: phone,
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
        TextFormField(
          controller: password,
          obscureText: !_showPassword,
          decoration: _buildInputDecoration("Entrez votre mot de passe").copyWith(
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "Obligatoire";
            if (value.length < 6) return "Minimum 6 caractères";
            return null;
          },
        ),
        SizedBox(height: 15),

        _buildLabel("Confirmer le mot de passe"),
        TextFormField(
          controller: confirmPassword,
          obscureText: !_showConfirmPassword,
          decoration: _buildInputDecoration("Répétez votre mot de passe").copyWith(
            prefixIcon: const Icon(Icons.lock_reset),
            suffixIcon: IconButton(
              icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "Obligatoire";
            if (value != password.text) return "Mots de passe différents";
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
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
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Déjà un compte ?"),
          TextButton(
            onPressed: () => Get.toNamed('/login'),
            child: const Text("Se connecter", style: TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(255, 0, 0, 153),)),
          ),
        ],
      ),
    );
  }
}