import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;

  late AudioPlayer _tickPlayer;
  late AudioPlayer _resultPlayer;
  late AudioPlayer _uiPlayer;

  bool _isMuted = false;

  SoundManager._internal() {
    _tickPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _resultPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _uiPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  }

  void setMute(bool muted) {
    _isMuted = muted;
  }

  Future<void> playTick() async {
    if (_isMuted) return;
    if (_tickPlayer.state == PlayerState.playing) {
      await _tickPlayer.stop();
    }
    await _tickPlayer.play(AssetSource('sounds/spin_tick.mp3'), volume: 0.1);
  }

  Future<void> playResult() async {
    if (_isMuted) return;
    await _resultPlayer.play(AssetSource('sounds/spin_result.mp3'), volume: 0.6);
  }

  Future<void> playButtonTap() async {
    if (_isMuted) return;
    await _uiPlayer.play(AssetSource('sounds/button_tap.mp3'), volume: 0.4);
  }
}

final soundManager = SoundManager();
