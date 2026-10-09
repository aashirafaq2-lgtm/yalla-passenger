import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playRideRequest() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/ride_request.mp3'), volume: 1.0);
    } catch (e) {
      debugPrint('[SoundService] Error playing ride request sound: $e');
    }
  }

  Future<void> playRideAccepted() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/ride_accepted.mp3'), volume: 1.0);
    } catch (e) {
      debugPrint('[SoundService] Error playing ride accepted sound: $e');
    }
  }

  Future<void> playRideCompleted() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/ride_completed.mp3'), volume: 1.0);
    } catch (e) {
      debugPrint('[SoundService] Error playing ride completed sound: $e');
    }
  }

  Future<void> playRideCancelled() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/ride_cancelled.mp3'), volume: 1.0);
    } catch (e) {
      debugPrint('[SoundService] Error playing ride cancelled sound: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('[SoundService] Error stopping sound: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
