import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset("assets/images/logo/login.png",
                    height: 150,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.login, size: 100, color: Colors.blue)),
                const Text(
                  "Bienvenue sur Lingualearn",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Connectez-vous pour continuer",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: controller.email,
                  validator: (value) => value!.isEmpty ? "Email requis" : null,
                  decoration: InputDecoration(
                    labelText: "Email ou Numéro de téléphone",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 20),

                GetBuilder<LoginController>(
                  builder: (_) => TextFormField(
                    controller: controller.password,
                    obscureText: !controller.showPassword,
                    validator: (value) => value!.isEmpty ? "Mot de passe requis" : null,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.showPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: controller.onChangeShowPassword,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed('/numberphone'),
                    child: const Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 153)),
                    ),
                  ),
                ),

                // Se souvenir de moi
                GetBuilder<LoginController>(
                  builder: (_) => Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: controller.isChecked,
                        activeColor: const Color.fromARGB(255, 0, 0, 153),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        onChanged: (value) => controller.onChangeCheckBox(value),
                      ),
                      const Text(
                        "Se souvenir de moi",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 0, 153),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.onLogin(), 
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Se connecter",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )),
                ),

                const SizedBox(height: 15),
                const Text("ou continuer avec",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(
                        label: "Google",
                        icon: Icons.g_mobiledata,
                        iconColor: Colors.red,
                        onTap: () => Get.toNamed(''),),
                    const SizedBox(width: 15),
                    _socialButton(
                        label: "Facebook",
                        icon: Icons.facebook,
                        iconColor: Colors.blue,
                        onTap: ()  => Get.toNamed(''),),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Vous n'avez pas de compte ? "),
            GestureDetector(
              onTap: () => Get.toNamed('/register'),
              child: const Text(
                "S'inscrire",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 153),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(
      {required String label,
        required IconData icon,
        required Color iconColor,
        required VoidCallback onTap}) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: iconColor, size: 28),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          minimumSize: const Size(20, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(color: Colors.grey.shade300, width: 2),
          elevation: 2,
        ),
      ),
    );
  }
}