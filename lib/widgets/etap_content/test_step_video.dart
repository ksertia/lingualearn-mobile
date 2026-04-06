import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TestStepVideo extends StatefulWidget {
  final String videoTitle;
  final String videoUrl;
  final VoidCallback onVideoFinished;

  const TestStepVideo({
    super.key,
    required this.videoTitle,
    required this.videoUrl,
    required this.onVideoFinished
  });

  @override
  State<TestStepVideo> createState() => _TestStepVideo();
}

class _TestStepVideo extends State<TestStepVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) => setState(() {}));

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        widget.onVideoFinished();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 15.h),
        Text(widget.videoTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.orange)),
        SizedBox(height: 20.h),
        Expanded(
          child: Center(
            child: Container(
              margin: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: Colors.black,
              ),
              child: _controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: GestureDetector(
                  onTap: () => _controller.value.isPlaying ? _controller.pause() : _controller.play(),
                  child: VideoPlayer(_controller),
                ),
              )
                  : const CircularProgressIndicator(),
            ),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}