import 'package:tibi/controller/apps/settings/change_password_controller.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _kRed        = Color(0xFFEF4444);
const Color _kOrange     = Color(0xFFF27F22);


class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl   = Get.put(ChangePasswordController());
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bgAlt(context),
      body: Column(
        children: [
          _buildHeader(topPad),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHintBanner(),
                  const SizedBox(height: 22),
                  _sectionHeader('MOT DE PASSE ACTUEL', _kOrange,
                      Icons.lock_outline_rounded),
                  const SizedBox(height: 10),
                  _buildFieldCard(
                    context: context,
                    icon: Icons.lock_outline_rounded,
                    iconColor: _kOrange,
                    label: 'Mot de passe actuel',
                    hint: 'Votre mot de passe actuel',
                    fieldController: ctrl.currentPasswordController,
                    obscure: !ctrl.showCurrentPassword.value,
                    toggle: () => ctrl.showCurrentPassword.value =
                        !ctrl.showCurrentPassword.value,
                    isVisible: ctrl.showCurrentPassword.value,
                    error: ctrl.currentPasswordError.value,
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader('NOUVEAU MOT DE PASSE', _kOrange,
                      Icons.vpn_key_rounded),
                  const SizedBox(height: 10),
                  _buildFieldCard(
                    context: context,
                    icon: Icons.vpn_key_rounded,
                    iconColor: _kOrange,
                    label: 'Nouveau mot de passe',
                    hint: 'Min. 6 caractères',
                    fieldController: ctrl.newPasswordController,
                    obscure: !ctrl.showNewPassword.value,
                    toggle: () => ctrl.showNewPassword.value =
                        !ctrl.showNewPassword.value,
                    isVisible: ctrl.showNewPassword.value,
                    error: ctrl.newPasswordError.value,
                  ),
                  const SizedBox(height: 12),
                  _buildFieldCard(
                    context: context,
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: ctrl.confirmPasswordError.value.isEmpty &&
                            ctrl.confirmPasswordController.text.isNotEmpty
                        ? _kOrange
                        : const Color(0xFF9CA3AF),
                    label: 'Confirmer le mot de passe',
                    hint: 'Répétez le nouveau mot de passe',
                    fieldController: ctrl.confirmPasswordController,
                    obscure: !ctrl.showConfirmPassword.value,
                    toggle: () => ctrl.showConfirmPassword.value =
                        !ctrl.showConfirmPassword.value,
                    isVisible: ctrl.showConfirmPassword.value,
                    error: ctrl.confirmPasswordError.value,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordTips(context),
                  const SizedBox(height: 28),
                  _buildSubmitButton(ctrl),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(double topPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kOrange, _kOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 15),
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
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Sécurisez votre compte',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Icon(Icons.lock_rounded,
                color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 3, height: 15,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.8),
        ),
      ],
    );
  }

  // ── Hint Banner ───────────────────────────────────────────────────────────

  Widget _buildHintBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kOrange.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kOrange.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kOrange.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield_outlined,
                color: _kOrange, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Choisissez un mot de passe fort et unique pour protéger votre compte.',
              style: TextStyle(
                  color: _kOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ── Password Tips ─────────────────────────────────────────────────────────

  Widget _buildPasswordTips(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3, height: 13,
                decoration: BoxDecoration(
                    color: _kOrange, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 7),
              Text(
                'CONSEILS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary(context),
                    letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _tip(context, Icons.tag_rounded, '6 caractères min.'),
              _tip(context, Icons.abc_rounded, 'Majuscule + minuscule'),
              _tip(context, Icons.pin_rounded, 'Au moins 1 chiffre'),
              _tip(context, Icons.star_outline_rounded, 'Symbole recommandé'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardAlt(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary(context)),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Field Card ────────────────────────────────────────────────────────────

  Widget _buildFieldCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String hint,
    required TextEditingController fieldController,
    required bool obscure,
    required VoidCallback toggle,
    required bool isVisible,
    required String error,
  }) {
    final hasError = error.isNotEmpty;
    final activeIconColor = hasError ? _kRed : iconColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label au-dessus
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: hasError ? _kRed : AppColors.textLabel(context),
          ),
        ),
        const SizedBox(height: 8),
        // Champ natif Flutter avec fill + border
        TextField(
          controller: fieldController,
          obscureText: obscure,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: AppColors.textHint(context),
                fontSize: 14,
                fontWeight: FontWeight.w400),
            filled: true,
            fillColor:
                hasError ? _kRed.withValues(alpha: 0.04) : AppColors.inputFill(context),
            // Icône gauche dans boîte colorée
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: activeIconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: activeIconColor, size: 18),
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 64, minHeight: 56),
            // Bouton œil droit
            suffixIcon: GestureDetector(
              onTap: toggle,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.cardAlt(context),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: const Color(0xFF9CA3AF),
                    size: 17,
                  ),
                ),
              ),
            ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 54, minHeight: 56),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            // Bordures
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError
                    ? _kRed.withValues(alpha: 0.50)
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: hasError ? _kRed : _kOrange,
                width: 2,
              ),
            ),
          ),
        ),
        // Message d'erreur
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: _kRed, size: 13),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(
                      color: _kRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── Submit Button ─────────────────────────────────────────────────────────

  Widget _buildSubmitButton(ChangePasswordController ctrl) {
    return Obx(() {
      final loading = ctrl.isLoading.value;
      return GestureDetector(
        onTap: loading ? null : ctrl.onChangePassword,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: loading
                ? null
                : const LinearGradient(
                    colors: [_kOrange, _kOrange],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            color: loading ? const Color(0xFFE5E7EB) : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: loading
                ? []
                : [
                    BoxShadow(
                      color: _kOrange.withValues(alpha: 0.32),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
