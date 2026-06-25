import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth/login_controller.dart';
import '../../helpers/theme/app_colors.dart';

const Color _kOrange     = Color(0xFFF27F22);


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    final bg = AppColors.bgForm(context);
    final cardColor = AppColors.card(context);
    final textSec = AppColors.textSecondary(context);
    final divCol = AppColors.divider(context);

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Branded header (same in both modes) ──────────────────────
            Container(
              width: double.infinity,
              height: size.height * 0.38,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kOrange, _kOrange],
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
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        "assets/images/logo/login.png",
                        height: 64,
                        errorBuilder: (ctx, e, st) => const Icon(
                            Icons.school_rounded,
                            size: 54,
                            color: _kOrange),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Le Burkina dans ta voix",
                      style: TextStyle(
                        fontSize: 22,
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
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.40),
                            width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              color: Colors.white, size: 13),
                          SizedBox(width: 5),
                          Text(
                            'Connexion sécurisée',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Form ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(context, "Email ou Téléphone"),
                    TextFormField(
                      controller: controller.email,
                      validator: (v) {
                        if (v!.isEmpty) return "Email requis";
                        return controller.emailError.value;
                      },
                      decoration: _inputDeco(
                        context: context,
                        hint: "exemple@mail.com",
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel(context, "Mot de passe"),
                    GetBuilder<LoginController>(
                      builder: (_) => TextFormField(
                        controller: controller.password,
                        obscureText: !controller.showPassword,
                        validator: (v) {
                          if (v!.isEmpty) return "Mot de passe requis";
                          return controller.passwordError.value;
                        },
                        decoration: _inputDeco(
                          context: context,
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.toNamed('/numberphone'),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: const Text(
                            "Mot de passe oublié ?",
                            style: TextStyle(
                              color: _kOrange,
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
                              backgroundColor: _kOrange,
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
                                        color: _kOrange, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    "Se connecter",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                          )),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(child: Divider(color: divCol)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "ou continuer avec",
                            style: TextStyle(color: textSec, fontSize: 13),
                          ),
                        ),
                        Expanded(child: Divider(color: divCol)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _socialButton(
                          context: context,
                          label: "Google",
                          icon: Icons.g_mobiledata,
                          iconColor: Colors.red,
                          onTap: () => Get.toNamed(''),
                        ),
                        const SizedBox(width: 12),
                        _socialButton(
                          context: context,
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
        color: cardColor,
        padding: const EdgeInsets.only(bottom: 28, top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Pas encore de compte ?  ",
              style: TextStyle(color: textSec, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => Get.toNamed('/register'),
              child: const Text(
                "S'inscrire",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _kOrange,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textLabel(context),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({
    required BuildContext context,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final fill = AppColors.inputFill(context);
    final bdr = AppColors.border(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textHint(context), fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.textSecondary(context), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: bdr),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: bdr),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kOrange, width: 1.5),
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
    required BuildContext context,
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
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context),
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
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
