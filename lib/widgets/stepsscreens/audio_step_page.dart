import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

class AudioStepPage extends StatefulWidget {
  final dynamic data;
 const AudioStepPage({super.key, this.data});

  @override
  State<AudioStepPage> createState() => _AudioStepPageState();
}

class _AudioStepPageState extends State<AudioStepPage> {
  int currentPhraseIndex = 0;
  final List<Map<String, dynamic>> lessonData = [
    {
      "french": "Bonjour (le matin)",
      "dioula": "I ni sɔgɔma",
      "words": ["ni", "I", "sɔgɔma", "tile", "ba"]
    },
    {
      "french": "Bonjour (l'après-midi)",
      "dioula": "I ni tile",
      "words": ["ni", "I", "tile", "wula", "samba"]
    },
    {
      "french": "Bonsoir",
      "dioula": "I ni wula",
      "words": ["wula", "ni", "I", "su", "kunu"]
    }
  ];

  String currentStatus = 'idle';
  List<String> availableWords = [];
  List<String> selectedWords = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentPhrase();
  }

  void _loadCurrentPhrase() {
    setState(() {
      availableWords = List<String>.from(lessonData[currentPhraseIndex]['words']);
      selectedWords = [];
      currentStatus = 'idle';
    });
  }

  void _selectWord(String word) {
    if (currentStatus != 'idle') return;
    setState(() {
      availableWords.remove(word);
      selectedWords.add(word);
    });
  }

  void _deselectWord(String word) {
    if (currentStatus != 'idle') return;
    setState(() {
      selectedWords.remove(word);
      availableWords.add(word);
    });
  }

  void _checkAnswer() {
    String userAnswer = selectedWords.join(" ");
    String correctAnswer = lessonData[currentPhraseIndex]['dioula'];

    if (userAnswer == correctAnswer) {
      setState(() => currentStatus = 'success');
      _showFeedbackSheet(true, correctAnswer);
    } else {
      setState(() => currentStatus = 'fail');
      _showFeedbackSheet(false, correctAnswer);
    }
  }

  // --- NOUVEAU : DIALOGUE DE FÉLICITATIONS ---
  void _showFinalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/lottie/Happy mascot.json', height: 150),
            const Text("FÉLICITATIONS !", 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 10),
            const Text("Tu as terminé tous les exercices de cette leçon.", 
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Ferme le dialog
                Get.back(); // Retourne à l'accueil
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                minimumSize: const Size(double.infinity, 50)
              ),
              child: const Text("TERMINER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = (currentPhraseIndex + 1) / lessonData.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey, size: 30),
          onPressed: () => Get.back(),
        ),
        title: _buildProgressBar(progress),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildHeader(),
          const SizedBox(height: 30),
          _buildMascotArea(),
          const SizedBox(height: 30),
          _buildAnswerZone(),
          const Spacer(),
          _buildWordBank(),
          const SizedBox(height: 20),
          _buildVerifyButton(),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 12,
        backgroundColor: Colors.grey[200],
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TRADUIS CETTE PHRASE", 
            style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Text(lessonData[currentPhraseIndex]['french'], 
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF3C3C3C))),
        ],
      ),
    );
  }

  Widget _buildMascotArea() {
    Widget lottieWidget;
    if (currentStatus == 'success') {
      lottieWidget = Lottie.asset('assets/lottie/Happy mascot.json', errorBuilder: (c, e, s) => _buildFallbackIcon());
    } else if (currentStatus == 'fail') {
      lottieWidget = Lottie.asset('assets/lottie/Sad mascot.json', errorBuilder: (c, e, s) => _buildFallbackIcon());
    } else {
      lottieWidget = Lottie.asset('assets/lottie/mascot.json', errorBuilder: (c, e, s) => _buildFallbackIcon());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          SizedBox(width: 90, height: 90, child: lottieWidget),
          Transform.translate(
            offset: const Offset(5, 0),
            child: CustomPaint(painter: TrianglePainter()),
          ),
          Expanded(child: _audioBalloon()), 
        ],
      ),
    );
  }

  Widget _audioBalloon() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.shade100, width: 2),
        boxShadow: [BoxShadow(color: Colors.blue.shade50, offset: const Offset(0, 4))],
      ),
      child: const Row(
        children: [
          Icon(Icons.volume_up_rounded, color: Colors.blue, size: 30),
          SizedBox(width: 12),
          Text("ÉCOUTER", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFE1F5FE), shape: BoxShape.circle),
      child: const Icon(Icons.face, size: 50, color: Colors.blue),
    );
  }

  Widget _buildAnswerZone() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      height: 80,
      width: double.infinity,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 2.5))),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: selectedWords.map((w) => _wordChip(w, true)).toList(),
      ),
    );
  }

  Widget _buildWordBank() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Wrap(
        spacing: 12, runSpacing: 12,
        alignment: WrapAlignment.center,
        children: availableWords.map((w) => _wordChip(w, false)).toList(),
      ),
    );
  }

  Widget _wordChip(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => isSelected ? _deselectWord(text) : _selectWord(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? Colors.grey.shade100 : Colors.grey.shade300, width: 2),
          boxShadow: isSelected ? [] : [BoxShadow(color: Colors.grey.shade200, offset: const Offset(0, 4))],
        ),
        child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.grey[200] : Colors.black87)),
      ),
    );
  }

  Widget _buildVerifyButton() {
    bool canVerify = selectedWords.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canVerify ? _checkAnswer : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF58CC02),
          disabledBackgroundColor: Colors.grey[200],
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text("VÉRIFIER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  void _showFeedbackSheet(bool isSuccess, String correctAnswer) {
    showModalBottomSheet(
      context: context, isDismissible: false, enableDrag: false, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: isSuccess ? const Color(0xFFD7FFB8) : const Color(0xFFFFDFE0),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isSuccess ? Icons.check_circle : Icons.cancel, color: isSuccess ? Colors.green[700] : Colors.red[700], size: 40),
                const SizedBox(width: 15),
                Text(isSuccess ? "Excellent !" : "Solution :", 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isSuccess ? Colors.green[800] : Colors.red[800])),
              ],
            ),
            if (!isSuccess) ...[
              const SizedBox(height: 10),
              Text(correctAnswer, style: TextStyle(fontSize: 22, color: Colors.red[800], fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Ferme le sheet
                if (isSuccess) {
                  if (currentPhraseIndex < lessonData.length - 1) {
                    setState(() {
                      currentPhraseIndex++;
                      _loadCurrentPhrase(); 
                    });
                  } else {
                    // --- APPEL DU DIALOGUE FINAL ---
                    _showFinalDialog();
                  }
                } else {
                  setState(() => currentStatus = 'idle');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? const Color(0xFF58CC02) : const Color(0xFFFF4B4B),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("CONTINUER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- DESSINER LE PETIT TRIANGLE DE LA BULLE ---
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.blue.shade100;
    var path = Path();
    path.moveTo(0, 10);
    path.lineTo(10, 0);
    path.lineTo(10, 20);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}