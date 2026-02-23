import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class GameDayYouTubePlayer extends StatefulWidget {
  final String videoId;
  final int startSeconds;
  final int durationSeconds;
  final VoidCallback? onEnded;

  /// When false, the video is cued (preloaded) but not played.
  /// Call [GameDayYouTubePlayerState.startPlayback] to begin playback.
  final bool autoPlay;

  const GameDayYouTubePlayer({
    super.key,
    required this.videoId,
    required this.startSeconds,
    required this.durationSeconds,
    this.onEnded,
    this.autoPlay = true,
  });

  @override
  State<GameDayYouTubePlayer> createState() => GameDayYouTubePlayerState();
}

class GameDayYouTubePlayerState extends State<GameDayYouTubePlayer> {
  late YoutubePlayerController _controller;
  bool _isReady = false;
  bool _playbackStarted = false;
  Timer? _durationTimer;

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

    if (widget.autoPlay) {
      _playbackStarted = true;
      _controller.loadVideoById(
        videoId: widget.videoId,
        startSeconds: widget.startSeconds.toDouble(),
      );
    } else {
      // Preload mode: cue the video so the WebView + YouTube API initializes
      // during TTS. Actual playback starts via startPlayback().
      _controller.cueVideoById(
        videoId: widget.videoId,
        startSeconds: widget.startSeconds.toDouble(),
      );
    }

    // Listen for player state changes
    _controller.listen((event) {
      if (event.playerState == PlayerState.playing && !_isReady) {
        setState(() => _isReady = true);
      }

      // Start the duration timer only once playback has actually started
      if (event.playerState == PlayerState.playing && _playbackStarted) {
        _startDurationTimer();
      }
    });
  }

  void _startDurationTimer() {
    if (_durationTimer != null) return; // Already scheduled
    _durationTimer = Timer(Duration(seconds: widget.durationSeconds), () {
      if (mounted) {
        _controller.pauseVideo();
        widget.onEnded?.call();
      }
    });
  }

  /// Begin playback (used when [autoPlay] is false).
  /// Calls loadVideoById which triggers buffering + play.
  void startPlayback() {
    _playbackStarted = true;
    _controller.loadVideoById(
      videoId: widget.videoId,
      startSeconds: widget.startSeconds.toDouble(),
    );
  }

  /// Stop playback and cancel the duration timer.
  void stopPlayback() {
    _durationTimer?.cancel();
    _durationTimer = null;
    _controller.stopVideo();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
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
