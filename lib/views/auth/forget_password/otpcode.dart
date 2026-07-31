import 'package:tibi/controller/auth/password/ForgotPasswordController.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


const Color _kOrange     = Color(0xFFF27F22);

class OtpcodePage extends StatefulWidget {
  const OtpcodePage({super.key});

  @override
  State<OtpcodePage> createState() => _OtpcodePageState();
}

class _OtpcodePageState extends State<OtpcodePage> {
  static const _successColor = Color(0xFF0F5C1C);

  final int otpLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<bool> _isFilled;
  late List<bool> _isError;
  final ForgotPasswordController controller =
      Get.find<ForgotPasswordController>();

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(otpLength, (index) => TextEditingController());
    _focusNodes = List.generate(otpLength, (index) => FocusNode());
    _isFilled = List.generate(otpLength, (index) => false);
    _isError = List.generate(otpLength, (index) => false);

    for (int i = 0; i < otpLength; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          bool canFocus = true;
          for (int j = 0; j < i; j++) {
            if (_controllers[j].text.isEmpty) {
              canFocus = false;
              break;
            }
          }
          if (!canFocus) {
            setState(() => _isError[i] = true);
            _focusNodes[i].unfocus();
            int firstEmpty =
                _controllers.indexWhere((c) => c.text.isEmpty);
            if (firstEmpty != -1) _focusNodes[firstEmpty].requestFocus();
          } else {
            setState(() => _isError[i] = false);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _onOtpChange(String value, int index) {
    setState(() {
      _isFilled[index] = value.isNotEmpty;
      _isError[index] = false;
    });
    if (value.isNotEmpty && index < otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get otpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgForm(context),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kOrange, _kOrange],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.shield_outlined,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Vérification\ndu code OTP",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Code à 6 chiffres reçu par SMS ou Email",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(otpLength, (index) {
                      final bool isFocused = _focusNodes[index].hasFocus;
                      final Color borderColor = _isError[index]
                          ? Colors.red
                          : (isFocused
                              ? _kOrange
                              : (_isFilled[index]
                                  ? _successColor
                                  : AppColors.border(context)));

                      final Color bgColor = _isFilled[index]
                          ? _successColor.withValues(alpha: 0.06)
                          : (isFocused
                              ? _kOrange.withValues(alpha: 0.04)
                              : AppColors.inputFill(context));

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 48,
                        height: 58,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 2),
                          boxShadow: isFocused
                              ? [
                                  BoxShadow(
                                    color: _kOrange.withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          onChanged: (v) => _onOtpChange(v, index),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _isFilled[index]
                                ? _successColor
                                : AppColors.textPrimary(context),
                          ),
                          decoration: const InputDecoration(
                              counterText: '', border: InputBorder.none),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  if (otpCode.length == otpLength) {
                                    controller.otpController.text = otpCode;
                                    controller.verifyOtp();
                                  } else {
                                    Get.snackbar(
                                      "Code incomplet",
                                      "Veuillez remplir les 6 cases.",
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kOrange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      color: _kOrange, strokeWidth: 2.5),
                                )
                              : const Text(
                                  "Confirmer",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppColors.bgForm(context),
        padding: const EdgeInsets.only(bottom: 28, top: 8),
        child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Code non reçu ?  ",
                  style: TextStyle(
                      color: AppColors.textSecondary(context), fontSize: 14),
                ),
                GestureDetector(
                  onTap: controller.isLoading.value
                      ? null
                      : () => controller.requestOtp(),
                  child: Text(
                    "Renvoyer",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: controller.isLoading.value
                          ? AppColors.textSecondary(context)
                          : _kOrange,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
