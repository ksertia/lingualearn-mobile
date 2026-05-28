// import 'dart:async';

// import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';

// class TestStepVideo extends StatefulWidget {
//   final String videoTitle;
//   final String videoUrl;
//   final VoidCallback onVideoFinished;

//   const TestStepVideo({
//     super.key,
//     required this.videoTitle,
//     required this.videoUrl,
//     required this.onVideoFinished
//   });

//   @override
//   State<TestStepVideo> createState() => _TestStepVideo();
// }

// class _TestStepVideo extends State<TestStepVideo> {
//   late final Player _player;
//   StreamSubscription<bool>? _playingSubscription;
//   StreamSubscription<Duration?>? _durationSubscription;
//   StreamSubscription<Duration>? _positionSubscription;
//   bool _isReady = false;
//   bool _hasError = false;
//   bool _isPlaying = false;
//   Duration _duration = Duration.zero;

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

//   String _normalizeAssetPath(String path) {
//     if (path.startsWith('asset://')) {
//       return path;
//     }
//     final normalized = path.replaceFirst(RegExp(r'^/+'), '');
//     return 'asset:///$normalized';
//   }

//   Future<void> _initializeVideo() async {
//     try {
//       final mediaPath = _normalizeAssetPath(widget.videoUrl);
//       await _player.open(Media(mediaPath), play: false);
//       _playingSubscription = _player.stream.isPlaying.listen((playing) {
//         if (mounted) {
//           setState(() => _isPlaying = playing);
//         }
//       });
//       _durationSubscription = _player.stream.duration.listen((duration) {
//         if (mounted && duration != null) {
//           setState(() {
//             _duration = duration;
//           });
//         }
//       });
//       _positionSubscription = _player.stream.position.listen((position) {
//         if (mounted && _duration > Duration.zero && position >= _duration) {
//           widget.onVideoFinished();
//         }
//       });
//       if (mounted) {
//         setState(() {
//           _isReady = true;
//           _hasError = false;
//         });
//       }
//       await _player.play();
//     } catch (_) {
//       if (mounted) {
//         setState(() {
//           _hasError = true;
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
//     _durationSubscription?.cancel();
//     _positionSubscription?.cancel();
//     _player.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(height: 15.h),
//         Text(widget.videoTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.orange)),
//         SizedBox(height: 20.h),
//         Expanded(
//           child: Center(
//             child: Container(
//               margin: EdgeInsets.all(10.w),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20.r),
//                 color: Colors.black,
//               ),
//               child: _hasError
//                   ? const Center(
//                       child: Text('Erreur de lecture vidéo',
//                           style: TextStyle(color: Colors.white)))
//                   : _isReady
//                       ? AspectRatio(
//                           aspectRatio: 16 / 9,
//                           child: GestureDetector(
//                             onTap: _togglePlayback,
//                             child: Video(
//                               player: _player,
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         )
//                       : const Center(child: CircularProgressIndicator()),
//             ),
//           ),
//         ),
//         SizedBox(height: 20.h),
//       ],
//     );
//   }
// }