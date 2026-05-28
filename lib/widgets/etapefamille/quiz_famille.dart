// import 'dart:async';

// import 'package:audioplayers/audioplayers.dart';
// import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';

// class StepQuizWidget extends StatefulWidget {
//   final Map<String, dynamic> quizData;

//   const StepQuizWidget({super.key, required this.quizData});

//   @override
//   State<StepQuizWidget> createState() => _StepQuizWidgetState();
// }

// class _StepQuizWidgetState extends State<StepQuizWidget> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   Player? _videoPlayer;
//   StreamSubscription<Duration?>? _durationSubscription;
//   StreamSubscription<Duration>? _positionSubscription;
//   bool _isVideoReady = false;
//   bool _hasVideoError = false;
//   Duration _videoDuration = Duration.zero;
//   String? selectedAnswer;
//   bool? isCorrect;

//   @override
//   void initState() {
//     super.initState();
//     _initializeFfmpeg();
//     if (widget.quizData['type'] == 'video') {
//       _initializeVideo();
//     }
//   }

//   Future<void> _initializeFfmpeg() async {
//     try {
//       await FFmpegKit.execute('-version');
//     } catch (_) {
//       // Ignore FFmpeg warm-up failures.
//     }
//   }

//   String _normalizeAssetPath(String path) {
//     if (path.startsWith('asset://')) {
//       return path;
//     }
//     final normalized = path.replaceFirst(RegExp(r'^/+'), '');
//     return 'asset:///$normalized';
//   }

//   Future<void> _initializeVideo() async {
//     try {
//       _videoPlayer = Player();
//       final mediaPath = _normalizeAssetPath(widget.quizData['media']);
//       await _videoPlayer!.open(Media(mediaPath), play: false);
//       _durationSubscription = _videoPlayer!.stream.duration.listen((duration) {
//         if (mounted && duration != null) {
//           setState(() => _videoDuration = duration);
//         }
//       });
//       _positionSubscription = _videoPlayer!.stream.position.listen((position) {
//         if (mounted && _videoDuration > Duration.zero && position >= _videoDuration) {
//           // Video complete.
//         }
//       });
//       if (mounted) {
//         setState(() {
//           _isVideoReady = true;
//           _hasVideoError = false;
//         });
//       }
//       await _videoPlayer!.play();
//     } catch (_) {
//       if (mounted) {
//         setState(() {
//           _hasVideoError = true;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     _durationSubscription?.cancel();
//     _positionSubscription?.cancel();
//     _videoPlayer?.dispose();
//     super.dispose();
//   }

//   void _playAudio() async {
//     final path = widget.quizData['media'].replaceFirst('assets/', '');
//     await _audioPlayer.stop();
//     await _audioPlayer.play(AssetSource(path));
//   }

//   void _selectAnswer(String answer) {
//     final bool correct = answer == widget.quizData['correct'];

//     setState(() {
//       selectedAnswer = answer;
//       isCorrect = correct;
//     });

//     Future.delayed(const Duration(seconds: 1), () {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(correct ? 'Bonne réponse 🎉' : 'Mauvaise réponse ❌'),
//           backgroundColor: correct ? Colors.green : Colors.red,
//         ),
//       );
//     });
//   }

//   Widget _buildMedia() {
//     switch (widget.quizData['type']) {
//       case 'image':
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(15),
//           child: Image.asset(widget.quizData['media'], height: 180),
//         );
//       case 'audio':
//         return IconButton(
//           icon: const Icon(Icons.volume_up, size: 60),
//           onPressed: _playAudio,
//         );
//       case 'video':
//         if (_hasVideoError) {
//           return const Text('Erreur de lecture vidéo');
//         }
//         if (!_isVideoReady) {
//           return const CircularProgressIndicator();
//         }
//         return AspectRatio(
//           aspectRatio: 16 / 9,
//           child: Video(
//             player: _videoPlayer!,
//             fit: BoxFit.contain,
//           ),
//         );
//       default:
//         return const SizedBox();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final answers = List<String>.from(widget.quizData['answers']);

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Text(
//             widget.quizData['question'],
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildMedia(),
//           const SizedBox(height: 20),
//           ...answers.map((answer) {
//             final bool isSelected = answer == selectedAnswer;
//             return Container(
//               margin: const EdgeInsets.symmetric(vertical: 6),
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isSelected
//                       ? (isCorrect == true ? Colors.green : Colors.red)
//                       : Colors.blue,
//                   padding: const EdgeInsets.all(14),
//                 ),
//                 onPressed: () => _selectAnswer(answer),
//                 child: Text(answer),
//               ),
//             );
//           })
//         ],
//       ),
//     );
//   }
// }
