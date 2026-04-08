import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math';

class GameScreenAudio extends StatefulWidget {
  final Map<String, String> data; // Nom : URL Image

  const GameScreenAudio({super.key, required this.data});

  @override
  State<GameScreenAudio> createState() => _GameScreenAudioState();
}

class _GameScreenAudioState extends State<GameScreenAudio> {
  final player = AudioPlayer();
  final ConfettiController _confettiController =
  ConfettiController(duration: const Duration(seconds: 1));

  late List<String> remaining;
  String? currentTarget;

  Map<String, bool> matched = {};
  String mascotText = "Écoute et trouve le bon animal !";
  String feedbackEmoji = "";
  String? wrongKey;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    matched = {for (var key in widget.data.keys) key: false};
    remaining = widget.data.keys.toList()..shuffle();
    currentTarget = remaining.isNotEmpty ? remaining.first : null;
  }

  void onMatch(String key) {
    if (key == currentTarget) {
      setState(() {
        matched[key] = true;
        remaining.remove(key);
        feedbackEmoji = "✅ Bravo !";

        if (remaining.isNotEmpty) {
          currentTarget = remaining.first;
          mascotText = "Excellent ! Cherche le suivant 👏";
        } else {
          currentTarget = null;
          mascotText = "🎉 Tu es un champion !";
        }
        wrongKey = null;
      });
      _confettiController.play();
    } else {
      setState(() {
        feedbackEmoji = "❌ Oups !";
        wrongKey = key;
        mascotText = "Essaie encore 😊";
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => wrongKey = null);
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Fond vert amande
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),

              // Grille des images (Cibles)
              Expanded(child: _buildGrid()),

              // Zone Audio en bas (Bouton déplaçable)
              _buildBottomAudioArea(),

              // Feedback visuel (Bravo/Oups)
              _buildFeedback(),

              const SizedBox(height: 30),
            ],
          ),

          // Explosion de confettis
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              colors: const [Colors.orange, Colors.blue, Colors.green, Colors.yellow],
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// 🦊 EN-TÊTE MASCOTTE
  ////////////////////////////////////////////////////////////
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          BounceInDown(
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Text("🦊", style: TextStyle(fontSize: 35)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: AnimatedTextKit(
                key: ValueKey(mascotText),
                animatedTexts: [
                  TypewriterAnimatedText(
                    mascotText,
                    textStyle: GoogleFonts.fredoka(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  )
                ],
                totalRepeatCount: 1,
              ),
            ),
          )
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// 🖼️ GRILLE DES IMAGES (CIBLES DU GLISSER)
  ////////////////////////////////////////////////////////////
  Widget _buildGrid() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: widget.data.entries.map((entry) {
        bool isMatched = matched[entry.key]!;
        bool isWrong = wrongKey == entry.key;

        return DragTarget<String>(
          onWillAccept: (data) => !isMatched,
          onAccept: (data) => onMatch(entry.key),
          builder: (context, candidate, rejected) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: isMatched
                    ? Colors.green.shade100
                    : candidate.isNotEmpty
                    ? Colors.orange.shade50
                    : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isMatched
                      ? Colors.green
                      : candidate.isNotEmpty
                      ? Colors.orange
                      : isWrong
                      ? Colors.red
                      : Colors.orange.shade100,
                  width: candidate.isNotEmpty ? 5 : 3,
                ),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Opacity(
                  opacity: isMatched ? 0.4 : 1.0,
                  child: Image.network(entry.value, fit: BoxFit.contain),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  ////////////////////////////////////////////////////////////
  /// 🔊 ZONE AUDIO (LE BOUTON QU'ON GLISSE)
  ////////////////////////////////////////////////////////////
  Widget _buildBottomAudioArea() {
    if (currentTarget == null) return const SizedBox.shrink();

    return FadeInUp(
      child: Column(
        children: [
          Draggable<String>(
            data: currentTarget, // On transporte le nom de l'animal
            feedback: _audioButton(true), // Ce qu'on voit pendant le glisser
            childWhenDragging: Opacity(opacity: 0.3, child: _audioButton(false)),
            child: _audioButton(false),
          ),
          const SizedBox(height: 10),
          Text(
            currentTarget!,
            style: GoogleFonts.fredoka(
              fontSize: 35,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Design du bouton bleu
  Widget _audioButton(bool isDragging) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 85,
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3), // Bleu fidèle à la capture
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: isDragging ? 15 : 8,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: const Icon(Icons.volume_up, color: Colors.white, size: 45),
      ),
    );
  }

  Widget _buildFeedback() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        feedbackEmoji,
        key: ValueKey(feedbackEmoji),
        style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.bold),
      ),
    );
  }
}