import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class CertificationScreen extends StatefulWidget {
  final String userName;
  final String moduleName;

  const CertificationScreen({
    super.key,
    required this.userName,
    required this.moduleName,
  });

  @override
  State<CertificationScreen> createState() => _CertificationScreenState();
}

class _CertificationScreenState extends State<CertificationScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  const Text(
                    "Certification obtenue 🎓",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000099),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF000099),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "a validé le module",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.moduleName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00CED1),
                    ),
                  ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000099),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Module suivant"),
                  ),
                ],
              ),
            ),
          ),

          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Color(0xFF000099),
              Color(0xFF00CED1),
              Color(0xFFFF7F00),
            ],
          ),
        ],
      ),
    );
  }
}
