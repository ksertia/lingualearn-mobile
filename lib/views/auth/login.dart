import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _primary = Color(0xFFFF7043);
  static const _primaryLight = Color(0xFFFFB74D);

  late LoginController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<LoginController>()) {
      Get.put(LoginController(), permanent: true);
    }
    controller = Get.find<LoginController>();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: size.height * 0.38,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primary, _primaryLight],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/logo/login.png",
                      height: 90,
                      errorBuilder: (ctx, e, st) => Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school_rounded,
                            size: 54, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Bienvenue sur TiBi",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Connectez-vous pour continuer",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Email ou Téléphone"),
                    TextFormField(
                      controller: controller.email,
                      validator: (v) => v!.isEmpty ? "Email requis" : null,
                      decoration: _inputDeco(
                        hint: "exemple@mail.com",
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Mot de passe"),
                    GetBuilder<LoginController>(
                      builder: (_) => TextFormField(
                        controller: controller.password,
                        obscureText: !controller.showPassword,
                        validator: (v) =>
                            v!.isEmpty ? "Mot de passe requis" : null,
                        decoration: _inputDeco(
                          hint: "••••••••",
                          icon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.showPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: controller.onChangeShowPassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GetBuilder<LoginController>(
                          builder: (_) => Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: controller.isChecked,
                                  activeColor: _primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  onChanged: controller.onChangeCheckBox,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Se souvenir de moi",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed('/numberphone'),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: const Text(
                            "Mot de passe oublié ?",
                            style: TextStyle(
                              color: _primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Obx(() => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.onLogin(),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    "Se connecter",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                          )),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "ou continuer avec",
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 13),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _socialButton(
                          label: "Google",
                          icon: Icons.g_mobiledata,
                          iconColor: Colors.red,
                          onTap: () => Get.toNamed(''),
                        ),
                        const SizedBox(width: 12),
                        _socialButton(
                          label: "Facebook",
                          icon: Icons.facebook,
                          iconColor: const Color(0xFF1877F2),
                          onTap: () => Get.toNamed(''),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFFF6F8FF),
        padding: const EdgeInsets.only(bottom: 28, top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Pas encore de compte ?  ",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => Get.toNamed('/register'),
              child: const Text(
                "S'inscrire",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _primary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E232C),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Widget _socialButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1E232C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
