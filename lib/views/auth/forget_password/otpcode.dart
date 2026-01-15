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

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(otpLength, (index) => TextEditingController());
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
            int firstEmpty = _controllers.indexWhere((c) => c.text.isEmpty);
            if (firstEmpty != -1) {
              _focusNodes[firstEmpty].requestFocus();
            }
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

  String get otpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.toNamed('/numberphone'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                "Vérification OTP",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E232C),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Veuillez saisir le code de 6 chiffres reçu par SMS.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              
              SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(otpLength, (index) {
                  final bool isFocused = _focusNodes[index].hasFocus;
                  final bool isFilled = _isFilled[index];
                  final bool isError = _isError[index];

                  Color borderColor = isError 
                      ? Colors.red 
                      : (isFocused ? Colors.blueAccent : (isFilled ? Colors.green : Colors.grey[300]!));

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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (otpCode.length == otpLength) {
                      Get.offNamed("/newPassword");
                    } else {
                      Get.snackbar(
                        "Code incomplet", 
                        "Veuillez remplir toutes les cases",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E232C),
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Confirmer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Je n'ai pas reçu de code ?"),
            TextButton(
              onPressed: () {
              },
              child: const Text(
                "Renvoyer",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}