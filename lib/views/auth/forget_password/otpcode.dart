import 'package:fasolingo/controller/auth/password/ForgotPasswordController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpcodePage extends StatefulWidget {
  const OtpcodePage({super.key});

  @override
  State<OtpcodePage> createState() => _OtpcodePageState();
}

class _OtpcodePageState extends State<OtpcodePage> {
  final int otpLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<bool> _isFilled;
  late List<bool> _isError;

  // Récupération du controller déjà injecté à la page précédente
  final ForgotPasswordController controller = Get.find<ForgotPasswordController>();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(otpLength, (index) => TextEditingController());
    _focusNodes = List.generate(otpLength, (index) => FocusNode());
    _isFilled = List.generate(otpLength, (index) => false);
    _isError = List.generate(otpLength, (index) => false);

    // Ta logique de focus intelligente
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
            int firstEmpty = _controllers.indexWhere((c) => c.text.isEmpty);
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
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
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

  // Getter pour récupérer le code final
  String get otpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Vérification OTP",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E232C)),
              ),
              const SizedBox(height: 10),
              Text(
                "Veuillez saisir le code de 6 chiffres reçu par SMS ou Email.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 50),

              // Les cases OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(otpLength, (index) {
                  final bool isFocused = _focusNodes[index].hasFocus;
                  Color borderColor = _isError[index] 
                      ? Colors.red 
                      : (isFocused ? const Color.fromARGB(255, 0, 0, 153) : (_isFilled[index] ? Colors.green : Colors.grey[300]!));

                  return SizedBox(
                    width: 45,
                    height: 55,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (value) => _onOtpChange(value, index),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 60),

              // Bouton CONFIRMER lié au Web Service
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value 
                      ? null 
                      : () {
                          if (otpCode.length == otpLength) {
                            // 1. On injecte le code dans le controller GetX
                            controller.otpController.text = otpCode;
                            // 2. On lance l'appel API
                            controller.verifyOtp();
                          } else {
                            Get.snackbar("Code incomplet", "Veuillez remplir les 6 cases.");
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 0, 153),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Confirmer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                )),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Je n'ai pas reçu de code ?"),
            TextButton(
              onPressed: controller.isLoading.value ? null : () => controller.requestOtp(),
              child: const Text(
                "Renvoyer",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 153)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}