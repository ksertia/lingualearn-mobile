
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';

class StepQuizWidget extends StatefulWidget {
  final Map<String, dynamic> quizData;

  const StepQuizWidget({super.key, required this.quizData});

  @override
  State<StepQuizWidget> createState() => _StepQuizWidgetState();
}

class _StepQuizWidgetState extends State<StepQuizWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  VideoPlayerController? _videoController;

  String? selectedAnswer;
  bool? isCorrect;

  @override
  void initState() {
    super.initState();

    // 🎥 Initialiser vidéo si besoin
    if (widget.quizData["type"] == "video") {
      _videoController =
      VideoPlayerController.asset(widget.quizData["media"])
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _playAudio() async {
    String path = widget.quizData["media"].replaceFirst("assets/", "");
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(path));
  }

  void _selectAnswer(String answer) {
    bool correct = answer == widget.quizData["correct"];

    setState(() {
      selectedAnswer = answer;
      isCorrect = correct;
    });

    Future.delayed(const Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(correct ? "Bonne réponse 🎉" : "Mauvaise réponse ❌"),
          backgroundColor: correct ? Colors.green : Colors.red,
        ),
      );
    });
  }

  Widget _buildMedia() {
    switch (widget.quizData["type"]) {
      case "image":
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(widget.quizData["media"], height: 180),
        );

      case "audio":
        return IconButton(
          icon: const Icon(Icons.volume_up, size: 60),
          onPressed: _playAudio,
        );

      case "video":
        return _videoController != null &&
            _videoController!.value.isInitialized
            ? AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        )
            : const CircularProgressIndicator();

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final answers = List<String>.from(widget.quizData["answers"]);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // QUESTION
          Text(
            widget.quizData["question"],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // MEDIA (image/audio/video)
          _buildMedia(),

          const SizedBox(height: 20),

          // REPONSES
          ...answers.map((answer) {
            bool isSelected = answer == selectedAnswer;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? (isCorrect == true ? Colors.green : Colors.red)
                      : Colors.blue,
                  padding: const EdgeInsets.all(14),
                ),
                onPressed: () => _selectAnswer(answer),
                child: Text(answer),
              ),
            );
          })
        ],
      ),
    );
  }
}