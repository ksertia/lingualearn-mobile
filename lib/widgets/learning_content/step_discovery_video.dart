

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  final String url;
  final String title;

  VideoScreen({required this.url, required this.title});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(widget.title,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10)
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: _controller.value.isInitialized
                    ? Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller)),
                    IconButton(
                      icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 50,
                          color: Colors.orange),
                      onPressed: () => setState(() =>
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play()),
                    ),
                  ],
                )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          )
        ],
      ),
    );
  }
}