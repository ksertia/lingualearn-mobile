import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(RegisterController());
  int currentStep = 0;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static const _primary      = Color(0xFF188329);
  static const _primaryLight = Color(0xFF1EB83A);
  static const _green        = Color(0xFF188329);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void nextStep() {
    if (controller.formKey.currentState!.validate()) {
      if (currentStep < 1) {
        _animCtrl.reverse().then((_) {
          setState(() => currentStep++);
          _animCtrl.forward();
        });
      } else {
        controller.onRegister();
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      _animCtrl.reverse().then((_) {
        setState(() => currentStep--);
        _animCtrl.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF6),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primary, _primaryLight],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentStep == 0)
                      InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white, size: 18),
                        ),
                      )
                    else
                      const SizedBox(height: 36),
                    const SizedBox(height: 16),
                    Text(
                      currentStep == 0
                          ? "Informations\npersonnelles"
                          : "Sécurité\ndu compte",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: List.generate(2, (i) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i == 0 ? 6 : 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 5,
                              decoration: BoxDecoration(
                                color: i < currentStep
                                    ? const Color(0xFF4ADE80)
                                    : i == currentStep
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "Étape ${currentStep + 1} sur 2",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (currentStep == 1) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFF4ADE80).withValues(alpha: 0.50),
                                  width: 1),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: Color(0xFF86EFAC), size: 11),
                                SizedBox(width: 4),
                                Text(
                                  'Étape 1 complète',
                                  style: TextStyle(
                                    color: Color(0xFF86EFAC),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: controller.formKey,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: currentStep == 0 ? _buildStep1() : _buildStep2(),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                if (currentStep > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: _primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        "Précédent",
                        style: TextStyle(
                            color: _primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Obx(() => ElevatedButton(
                        onPressed:
                            controller.isLoading.value ? null : nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                currentStep == 1 ? "S'inscrire" : "Suivant",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: currentStep == 0
          ? Container(
              color: const Color(0xFFF4FBF6),
              padding: const EdgeInsets.only(bottom: 24, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Déjà un compte ?  ",
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed('/login'),
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _green,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        _buildField(
          label: "Prénom",
          textController: controller.firstName,
          hint: "Entrez votre prénom",
          icon: Icons.person_outline_rounded,
          validator: (v) => v!.isEmpty ? "Prénom requis" : null,
        ),
        const SizedBox(height: 16),
        _buildField(
          label: "Nom",
          textController: controller.lastName,
          hint: "Entrez votre nom",
          icon: Icons.badge_outlined,
          validator: (v) => v!.isEmpty ? "Nom requis" : null,
        ),
        const SizedBox(height: 16),
        _buildField(
          label: "Email",
          textController: controller.email,
          hint: "exemple@mail.com",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) => v!.isEmpty ? "Email requis" : null,
        ),
        const SizedBox(height: 16),
        _buildField(
          label: "Téléphone",
          textController: controller.phone,
          hint: "+XXX XXX XXXXX",
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (v) => v!.isEmpty ? "Téléphone requis" : null,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Mot de passe"),
        GetBuilder<RegisterController>(
          builder: (_) => TextFormField(
            controller: controller.password,
            obscureText: !controller.showPassword,
            decoration: _inputDeco(
              hint: "Minimum 6 caractères",
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.showPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: controller.toggleShowPassword,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return "Obligatoire";
              if (v.length < 6) return "Minimum 6 caractères";
              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildLabel("Confirmer le mot de passe"),
        TextFormField(
          controller: controller.confirmPassword,
          obscureText: true,
          decoration: _inputDeco(
            hint: "Répétez le mot de passe",
            icon: Icons.lock_reset_rounded,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return "Obligatoire";
            if (v != controller.password.text) return "Mots de passe différents";
            return null;
          },
        ),
        const SizedBox(height: 24),
        // ── Code promo partenaire (optionnel) ───────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBBF7D0), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.card_giftcard_rounded,
                        color: Color(0xFF16A34A), size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Code partenaire',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15803D),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Optionnel',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.promoCode,
                textCapitalization: TextCapitalization.characters,
                decoration: _inputDeco(
                  hint: "Ex : TIBI-XXXX",
                  icon: Icons.confirmation_number_outlined,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Si quelqu\'un vous a partagé son code, entrez-le ici.',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF4ADE80),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController textController,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: textController,
          keyboardType: keyboardType,
          validator: validator,
          decoration: _inputDeco(hint: hint, icon: icon),
        ),
      ],
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
}
