import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';

class GameScreenText extends StatefulWidget {
  final Map<String, String> data;

  const GameScreenText({super.key, required this.data});

  @override
  State<GameScreenText> createState() => _GameScreenTextState();
}

class _GameScreenTextState extends State<GameScreenText> {
  final player = AudioPlayer();

  /// ✅ CORRECTION ICI (parenthèse OK)
  final ConfettiController _confettiController =
  ConfettiController(duration: const Duration(seconds: 1));

  Map<String, bool> matched = {};
  String mascotText = "Relie le bon mot avec l'image !";
  String feedbackEmoji = "";
  String? dragging;

  @override
  void initState() {
    super.initState();
    for (var key in widget.data.keys) {
      matched[key] = false;
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    player.dispose();
    super.dispose();
  }

  ////////////////////////////////////////////////////////////
  /// LOGIQUE MATCH
  ////////////////////////////////////////////////////////////
  void checkMatch(String target) async {
    if (dragging == target) {
      setState(() {
        matched[target] = true;
        feedbackEmoji = "✅ Bravo !";
        mascotText = "Bien joué 👏";
      });

      _confettiController.play();

      try {
        await player.play(AssetSource('${target.toLowerCase()}.mp3'));
      } catch (e) {}
    } else {
      setState(() {
        feedbackEmoji = "❌ Oups !";
        mascotText = "Essaie encore 😊";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildGrid()),
            _buildWords(),
            _buildFeedback(),
            const SizedBox(height: 15),
          ],
        ),

        /// 🎉 CONFETTI
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
          ),
        ),
      ],
    );
  }

  ////////////////////////////////////////////////////////////
  /// HEADER ANIMÉ
  ////////////////////////////////////////////////////////////
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            child: Text("🐯"),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedTextKit(
                key: ValueKey(mascotText),
                animatedTexts: [
                  TypewriterAnimatedText(
                    mascotText,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// GRID IMAGES
  ////////////////////////////////////////////////////////////
  Widget _buildGrid() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(15),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: widget.data.entries.map((entry) {
        return DragTarget<String>(
          onAccept: (data) {
            dragging = data;
            checkMatch(entry.key);
          },
          builder: (context, candidate, rejected) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: matched[entry.key]!
                      ? Colors.green
                      : Colors.orange,
                  width: 3,
                ),
                color: matched[entry.key]!
                    ? Colors.green.shade300
                    : Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.network(entry.value),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  ////////////////////////////////////////////////////////////
  /// ZONE MOTS EN BAS
  ////////////////////////////////////////////////////////////
  Widget _buildWords() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: widget.data.keys.map((name) {
          if (matched[name]!) return const SizedBox();

          return Draggable<String>(
            data: name,
            feedback: _wordBox(name),
            child: _wordBox(name),
          );
        }).toList(),
      ),
    );
  }

  Widget _wordBox(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// FEEDBACK EN BAS
  ////////////////////////////////////////////////////////////
  Widget _buildFeedback() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        feedbackEmoji,
        key: ValueKey(feedbackEmoji),
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}