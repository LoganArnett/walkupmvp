import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class GameDayYouTubePlayer extends StatefulWidget {
  final String videoId;
  final int startSeconds;
  final int durationSeconds;
  final VoidCallback? onEnded;

  const GameDayYouTubePlayer({
    super.key,
    required this.videoId,
    required this.startSeconds,
    required this.durationSeconds,
    this.onEnded,
  });

  @override
  State<GameDayYouTubePlayer> createState() => _GameDayYouTubePlayerState();
}

class _GameDayYouTubePlayerState extends State<GameDayYouTubePlayer> {
  late YoutubePlayerController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: false,
        loop: false,
        enableCaption: false,
        origin: 'https://www.youtube-nocookie.com'
      ),
    );

    _controller.loadVideoById(
      videoId: widget.videoId,
      startSeconds: widget.startSeconds.toDouble(),
    );

    // Listen for player state changes
    _controller.listen((event) {
      if (event.playerState == PlayerState.playing && !_isReady) {
        setState(() => _isReady = true);
        
        // Schedule stop after duration
        Future.delayed(Duration(seconds: widget.durationSeconds), () {
          if (mounted) {
            _controller.pauseVideo();
            widget.onEnded?.call();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          ),
        ),
      ),
    );
  }
}
