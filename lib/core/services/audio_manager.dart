import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  // Cache for failed assets to prevent console spam
  final Set<String> _failedAssets = {};

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
    if (_failedAssets.contains(assetPath)) return;

    try {
      await _musicPlayer.play(AssetSource(assetPath));
      _currentMusicTrack = assetPath;
    } catch (e) {
      if (!_failedAssets.contains(assetPath)) {
        _failedAssets.add(assetPath);
        debugPrint('Note: Music asset $assetPath not found or failed to load. Silencing music.');
      }
    }
  }

  /// Play zone-specific background music
  Future<void> playZoneMusic(String zoneId) async {
    // Some common variations just in case
    final variations = [
      'sounds/music/zones/$zoneId.mp3',
      'sounds/music/zones/${zoneId.replaceAll('_', '-')}.mp3',
    ];
    
    for (final musicPath in variations) {
      if (!_failedAssets.contains(musicPath)) {
        await playMusic(musicPath);
        if (_currentMusicTrack == musicPath) break;
      }
    }
  }

  /// Play menu/world map music
  Future<void> playMenuMusic() => playMusic('sounds/music/menu.mp3');
  Future<void> playSplashMusic() => playMusic('sounds/music/splash.mp3');

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _currentMusicTrack = null;
  }

  Future<void> playSfx(String assetPath) async {
    if (!_isSfxEnabled) return;
    
    // Check cache first to avoid console noise
    if (_failedAssets.contains(assetPath)) {
      _triggerHapticFallback(assetPath);
      return;
    }

    try {
      // Create a temporary player for SFX to allow overlapping sounds
      final player = AudioPlayer();
      await player.setVolume(_sfxVolume);
      
      // On web, assets missing often cause CORS/404 errors that can't be caught by try/catch 
      // around 'play' easily because they happen in the browser's fetch.
      // We log it once and then skip.
      await player.play(AssetSource(assetPath));

      // Dispose player after completion
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      if (!_failedAssets.contains(assetPath)) {
        _failedAssets.add(assetPath);
        debugPrint('Note: SFX asset $assetPath not found. Using haptic fallback.');
      }
      _triggerHapticFallback(assetPath);
    }
  }

  /// Trigger haptic/system sound feedback when asset is missing
  void _triggerHapticFallback(String assetPath) {
    if (assetPath.contains('click') || assetPath.contains('button')) {
      SystemSound.play(SystemSoundType.click);
    } else if (assetPath.contains('correct') || assetPath.contains('perfect')) {
      HapticFeedback.mediumImpact();
    } else if (assetPath.contains('wrong') || assetPath.contains('incorrect')) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  /// Play UI feedback sounds
  Future<void> playButtonClick() => playSfx('sounds/sfx/ui/click.mp3');
  Future<void> playWhoosh() => playSfx('sounds/sfx/ui/whoosh.mp3');
  Future<void> playPopup() => playSfx('sounds/sfx/ui/popup.mp3');

  /// Play answer feedback sounds
  Future<void> playCorrectAnswer([int? variation]) {
    final num = variation ?? (DateTime.now().millisecond % 3) + 1;
    return playSfx('sounds/sfx/correct/correct$num.mp3');
  }

  Future<void> playIncorrectAnswer([int? variation]) {
    final num = variation ?? (DateTime.now().millisecond % 2) + 1;
    return playSfx('sounds/sfx/incorrect/wrong$num.mp3');
  }

  /// Play celebration sounds for achievements
  Future<void> playPerfectScore() =>
      playSfx('sounds/sfx/celebration/perfect.mp3');
  Future<void> playStreak(int streakCount) {
    if (streakCount >= 10) {
      return playSfx('sounds/sfx/celebration/streak10.mp3');
    } else if (streakCount >= 5) {
      return playSfx('sounds/sfx/celebration/streak5.mp3');
    } else if (streakCount >= 3) {
      return playSfx('sounds/sfx/celebration/streak3.mp3');
    }
    return Future.value();
  }

  Future<void> playLevelUp() => playSfx('sounds/sfx/celebration/levelup.mp3');
  Future<void> playUnlock() => playSfx('sounds/sfx/celebration/unlock.mp3');

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
