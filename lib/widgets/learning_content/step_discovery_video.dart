// import 'dart:async';

// import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';

// class VideoScreen extends StatefulWidget {
//   final String url;
//   final String title;

//   const VideoScreen({super.key, required this.url, required this.title});

//   @override
//   _VideoScreenState createState() => _VideoScreenState();
// }

// class _VideoScreenState extends State<VideoScreen> {
//   late final Player _player;
//   StreamSubscription<bool>? _playingSubscription;
//   bool _isPlaying = false;
//   bool _isLoading = true;
//   bool _hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     _player = Player();
//     _initializeFfmpeg();
//     _initializeVideo();
//   }

//   Future<void> _initializeFfmpeg() async {
//     try {
//       await FFmpegKit.execute('-version');
//     } catch (_) {
//       // Ignore FFmpeg warm-up failures.
//     }
//   }

//   Future<void> _initializeVideo() async {
//     try {
//       await _player.open(Media(widget.url), play: false);
//       _playingSubscription = _player.stream.isPlaying.listen((playing) {
//         if (mounted) {
//           setState(() => _isPlaying = playing);
//         }
//       });
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _hasError = false;
//         });
//       }
//       await _player.play();
//     } catch (_) {
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _togglePlayback() {
//     if (_isPlaying) {
//       _player.pause();
//     } else {
//       _player.play();
//     }
//   }

//   @override
//   void dispose() {
//     _playingSubscription?.cancel();
//     _player.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           Text(widget.title,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 20),
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(30),
//                 child: _hasError
//                     ? const Center(child: Text('Erreur de lecture vidéo'))
//                     : Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           AspectRatio(
//                             aspectRatio: 16 / 9,
//                             child: Video(
//                               player: _player,
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                           if (_isLoading)
//                             const Center(
//                               child: CircularProgressIndicator(),
//                             )
//                           else
//                             IconButton(
//                               icon: Icon(
//                                 _isPlaying ? Icons.pause : Icons.play_arrow,
//                                 size: 50,
//                                 color: Colors.orange,
//                               ),
//                               onPressed: _togglePlayback,
//                             ),
//                         ],
//                       ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
