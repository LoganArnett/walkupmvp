import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

/// Audio controller for managing all audio playback
/// Handles local audio files, TTS, and YouTube streaming
class AudioController {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  Timer? _stopTimer;

  /// Initialize audio session
  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    
    // Configure TTS
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  /// Stop all audio playback (both player and TTS)
  Future<void> stopAll() async {
    _stopTimer?.cancel();
    await _tts.stop();
    await _player.stop();
  }

  /// Speak text using TTS
  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Play local audio file with start position and duration
  Future<void> playLocalClip({
    required Uri uri,
    Duration start = Duration.zero,
    Duration? duration,
  }) async {
    _stopTimer?.cancel();
    
    await _player.setAudioSource(AudioSource.uri(uri));
    await _player.seek(start);
    await _player.play();

    // If duration specified, stop after that duration
    if (duration != null) {
      _stopTimer = Timer(duration, () async {
        await _player.stop();
      });
    }
  }

  /// Get current player state
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Get current position
  Stream<Duration> get positionStream => _player.positionStream;

  /// Check if currently playing
  bool get isPlaying => _player.playing;

  /// Dispose resources
  Future<void> dispose() async {
    _stopTimer?.cancel();
    await _player.dispose();
  }
}
