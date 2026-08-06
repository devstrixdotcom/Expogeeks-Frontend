import 'dart:io';
import 'package:event_pro/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../utils/helper_functions.dart';

class ViewVideoScreen extends StatefulWidget {
  final String path;
  ViewVideoScreen({Key? key, required this.path}) : super(key: key);

  @override
  _ViewVideoScreenState createState() => _ViewVideoScreenState();
}

class _ViewVideoScreenState extends State<ViewVideoScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {}); // Update the UI after video initialization.
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        shadowColor: Colors.transparent,
        // backgroundColor: Colors.white,
        backgroundColor: Color.fromRGBO(204, 232, 234, 0.7),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "View Video",
          style: TextStyle(height: 1.5, fontSize: convertFigmaToUIWidth(20, width), fontWeight: FontWeight.w600, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: cyangreen,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
        ),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(10), child: SizedBox()),
      ),
      body: Container(
        color: Color.fromRGBO(204, 232, 234, 0.7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 20),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 40,
              ),
              onPressed: _togglePlayPause,
            ),
          ],
        ),
      ),
    );
  }
}
