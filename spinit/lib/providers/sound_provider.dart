import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/sound_manager.dart';

const String _kMuteKey = 'is_muted';

class SoundNotifier extends StateNotifier<bool> {
  SoundNotifier() : super(false) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isMuted = prefs.getBool(_kMuteKey) ?? false;
    state = isMuted;
    soundManager.setMute(isMuted);
  }

  Future<void> toggleMute() async {
    final prefs = await SharedPreferences.getInstance();
    final newState = !state;
    await prefs.setBool(_kMuteKey, newState);
    state = newState;
    soundManager.setMute(newState);
  }
}

final soundProvider = StateNotifierProvider<SoundNotifier, bool>(
  (ref) => SoundNotifier(),
);
