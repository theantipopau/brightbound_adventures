import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager extends ChangeNotifier {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  double _musicVolume = 0.3;
  double _sfxVolume = 0.8;
  String? _currentMusicTrack;

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  Future<void> initialize() async {
    // Set up audio players
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    _updateVolumes();
  }

  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    if (_isMusicEnabled) {
      _musicPlayer.resume();
    } else {
      _musicPlayer.pause();
    }
    notifyListeners();
  }

  void toggleSfx() {
    _isSfxEnabled = !_isSfxEnabled;
    notifyListeners();
  }
  
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
    notifyListeners();
  }
  
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  Future<void> playMusic(String assetPath) async {
    if (!_isMusicEnabled) return;
    if (_currentMusicTrack == assetPath) return; // Already playing
    
    try {
      await _musicPlayer.play(AssetSource(assetPath));
      _currentMusicTrack = assetPath;
    } catch (e) {
      debugPrint('Error playing music: $e');
    }
  }
  
  /// Play zone-specific background music
  Future<void> playZoneMusic(String zoneId) async {
    final musicPath = 'sounds/zones/$zoneId-bg.mp3';
    await playMusic(musicPath);
  }
  
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _currentMusicTrack = null;
  }

  Future<void> playSfx(String assetPath) async {
    if (!_isSfxEnabled) return;
    try {
      // Create a temporary player for SFX to allow overlapping sounds
      final player = AudioPlayer();
      await player.setVolume(_sfxVolume);
      await player.play(AssetSource(assetPath));
      
      // Dispose player after completion
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      debugPrint('Error playing SFX: $e');
    }
  }
  
  /// Play UI feedback sounds
  Future<void> playButtonClick() => playSfx('sounds/sfx/click.wav');
  Future<void> playCorrectAnswer() => playSfx('sounds/sfx/correct.wav');
  Future<void> playIncorrectAnswer() => playSfx('sounds/sfx/incorrect.wav');
  Future<void> playCelebration() => playSfx('sounds/sfx/celebration.wav');
  Future<void> playLevelUp() => playSfx('sounds/sfx/levelup.wav');
  Future<void> playZoneUnlock() => playSfx('sounds/sfx/unlock.wav');

  void _updateVolumes() {
    _musicPlayer.setVolume(_musicVolume);
    _sfxPlayer.setVolume(_sfxVolume);
  }
  
  @override
  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }
}
