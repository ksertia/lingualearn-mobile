import 'package:fasolingo/controller/apps/settings/change_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _orange = Color(0xFFFF7043);
const Color _orange2 = Color(0xFFFFB74D);

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final hintColor = isDark ? Colors.white38 : const Color(0xFF9E9E9E);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInfoCard(cardBg, textColor),
                      const SizedBox(height: 24),
                      _buildField(
                        label: 'Mot de passe actuel',
                        controller: controller.currentPasswordController,
                        obscure: !controller.showCurrentPassword.value,
                        toggle: () => controller.showCurrentPassword.value =
                            !controller.showCurrentPassword.value,
                        isVisible: controller.showCurrentPassword.value,
                        error: controller.currentPasswordError.value,
                        cardBg: cardBg,
                        textColor: textColor,
                        hintColor: hintColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Nouveau mot de passe',
                        controller: controller.newPasswordController,
                        obscure: !controller.showNewPassword.value,
                        toggle: () => controller.showNewPassword.value =
                            !controller.showNewPassword.value,
                        isVisible: controller.showNewPassword.value,
                        error: controller.newPasswordError.value,
                        cardBg: cardBg,
                        textColor: textColor,
                        hintColor: hintColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: 'Confirmer le nouveau mot de passe',
                        controller: controller.confirmPasswordController,
                        obscure: !controller.showConfirmPassword.value,
                        toggle: () => controller.showConfirmPassword.value =
                            !controller.showConfirmPassword.value,
                        isVisible: controller.showConfirmPassword.value,
                        error: controller.confirmPasswordError.value,
                        cardBg: cardBg,
                        textColor: textColor,
                        hintColor: hintColor,
                        borderColor: borderColor,
                      ),
                      const SizedBox(height: 32),
                      _buildSubmitButton(controller),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_orange, _orange2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        24,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Changer le mot de passe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sécurisez votre compte',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Color cardBg, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _orange.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: _orange, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Choisissez un mot de passe fort d\'au moins 6 caractères.',
              style: TextStyle(
                color: Color(0xFFB71C1C),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
    required bool isVisible,
    required String error,
    required Color cardBg,
    required Color textColor,
    required Color hintColor,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: error.isNotEmpty ? Colors.red.shade300 : borderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: TextStyle(color: textColor, fontSize: 15),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: hintColor),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: GestureDetector(
                onTap: toggle,
                child: Icon(
                  isVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: hintColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        if (error.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.red, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(ChangePasswordController controller) {
    return Obx(() => GestureDetector(
          onTap: controller.isLoading.value ? null : controller.onChangePassword,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            decoration: BoxDecoration(
              gradient: controller.isLoading.value
                  ? const LinearGradient(
                      colors: [Color(0xFFBDBDBD), Color(0xFFBDBDBD)],
                    )
                  : const LinearGradient(
                      colors: [_orange, _orange2],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: controller.isLoading.value
                  ? []
                  : [
                      BoxShadow(
                        color: _orange.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_reset_rounded,
                            color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Modifier le mot de passe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ));
  }
}
