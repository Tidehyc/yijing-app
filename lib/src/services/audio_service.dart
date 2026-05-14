import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioService {
  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _bgMusicEnabled = true;
  bool _sfxEnabled = true;
  bool _initialized = false;

  bool get bgMusicEnabled => _bgMusicEnabled;
  bool get sfxEnabled => _sfxEnabled;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _bgMusicPlayer.setSource(AssetSource('audio/guzheng_bg.mp3'));
      await _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgMusicPlayer.setVolume(0.25);
    } catch (_) {
      debugPrint('Background music asset not found, audio disabled');
    }
  }

  Future<void> playBgMusic() async {
    if (!_bgMusicEnabled || !_initialized) return;
    try {
      await _bgMusicPlayer.resume();
    } catch (_) {}
  }

  Future<void> stopBgMusic() async {
    try {
      await _bgMusicPlayer.pause();
    } catch (_) {}
  }

  Future<void> playCoinCollision() async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/coin_collision.mp3'));
    } catch (_) {}
  }

  Future<void> playCoinLand() async {
    if (!_sfxEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/coin_land.mp3'));
    } catch (_) {}
  }

  void setBgMusicEnabled(bool enabled) {
    _bgMusicEnabled = enabled;
    if (enabled) {
      playBgMusic();
    } else {
      stopBgMusic();
    }
  }

  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
  }

  Future<void> dispose() async {
    await _bgMusicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

/// Audio toggle state managed via shared_preferences
class AudioSettingsNotifier extends StateNotifier<AudioSettings> {
  final AudioService _audioService;

  AudioSettingsNotifier(this._audioService)
      : super(const AudioSettings());

  void toggleBgMusic() {
    final newVal = !state.bgMusicEnabled;
    _audioService.setBgMusicEnabled(newVal);
    state = state.copyWith(bgMusicEnabled: newVal);
  }

  void toggleSfx() {
    final newVal = !state.sfxEnabled;
    _audioService.setSfxEnabled(newVal);
    state = state.copyWith(sfxEnabled: newVal);
  }
}

final audioSettingsProvider =
    StateNotifierProvider<AudioSettingsNotifier, AudioSettings>((ref) {
  final audio = ref.watch(audioServiceProvider);
  return AudioSettingsNotifier(audio);
});

class AudioSettings {
  final bool bgMusicEnabled;
  final bool sfxEnabled;

  const AudioSettings({
    this.bgMusicEnabled = true,
    this.sfxEnabled = true,
  });

  AudioSettings copyWith({bool? bgMusicEnabled, bool? sfxEnabled}) {
    return AudioSettings(
      bgMusicEnabled: bgMusicEnabled ?? this.bgMusicEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
    );
  }
}
