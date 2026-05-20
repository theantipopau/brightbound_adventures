import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:brightbound_adventures/core/utils/web_sound_player.dart';

class AudioManager extends ChangeNotifier {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final List<AudioPlayer> _sfxPool =
      List<AudioPlayer>.generate(6, (_) => AudioPlayer());
  int _sfxPoolCursor = 0;

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  double _musicVolume = 0.3;
  double _sfxVolume = 0.8;
  String? _currentMusicTrack;
  bool _assetManifestLoaded = false;
  final Set<String> _bundledAssetKeys = {};

  // Cache for failed assets to prevent console spam
  final Set<String> _failedAssets = {};

  static const List<String> _expectedAudioAssets = [
    'sounds/sfx/correct/correct1.mp3',
    'sounds/sfx/correct/correct2.mp3',
    'sounds/sfx/correct/correct3.mp3',
    'sounds/sfx/incorrect/wrong1.mp3',
    'sounds/sfx/incorrect/wrong2.mp3',
    'sounds/sfx/celebration/perfect.mp3',
    'sounds/sfx/celebration/streak3.mp3',
    'sounds/sfx/celebration/streak5.mp3',
    'sounds/sfx/celebration/streak10.mp3',
    'sounds/sfx/celebration/levelup.mp3',
    'sounds/sfx/celebration/unlock.mp3',
    'sounds/sfx/ui/click.mp3',
    'sounds/sfx/ui/whoosh.mp3',
    'sounds/sfx/ui/popup.mp3',
    'sounds/music/menu.mp3',
    'sounds/music/splash.mp3',
    'sounds/music/zones/word_woods.mp3',
    'sounds/music/zones/number_nebula.mp3',
    'sounds/music/zones/story_springs.mp3',
    'sounds/music/zones/puzzle_peaks.mp3',
    'sounds/music/zones/adventure_arena.mp3',
  ];

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  Future<void> initialize() async {
    // Set up audio players
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    for (final player in _sfxPool) {
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(_sfxVolume);
    }
    await _loadBundledAudioManifest();
    _updateVolumes();
  }

  Future<void> _loadBundledAudioManifest() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      for (final key in manifest.listAssets()) {
        if (key.startsWith('assets/sounds/')) {
          _bundledAssetKeys.add(key);
        }
      }
      _assetManifestLoaded = true;
      _logExpectedAssetCoverage();
      if (kDebugMode) {
        debugPrint(
          'AudioManager: discovered ${_bundledAssetKeys.length} bundled audio assets.',
        );
      }
    } catch (e) {
      // On web, prefer fail-closed so missing audio assets do not trigger
      // repeated exception-driven probing in the browser.
      _assetManifestLoaded = kIsWeb;
      if (kDebugMode) {
        debugPrint(
          'AudioManager: failed to read AssetManifest, '
          '${kIsWeb ? 'disabling bundled web audio checks.' : 'using runtime checks only.'}',
        );
      }
    }
  }

  String _manifestKeyFor(String assetPath) {
    final normalized =
        assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';
    return normalized.replaceAll('\\\\', '/');
  }

  bool _isBundledAssetAvailable(String assetPath) {
    if (!_assetManifestLoaded) return !kIsWeb;
    return _bundledAssetKeys.contains(_manifestKeyFor(assetPath));
  }

  void _logExpectedAssetCoverage() {
    if (!kDebugMode) return;
    final missing = _expectedAudioAssets
        .where((path) => !_isBundledAssetAvailable(path))
        .toList(growable: false);
    if (missing.isEmpty) {
      debugPrint('AudioManager: all expected audio assets are bundled.');
      return;
    }

    debugPrint(
      'AudioManager: ${missing.length}/${_expectedAudioAssets.length} expected audio assets are missing.',
    );
    for (final path in missing) {
      debugPrint(' - missing: $path');
    }
  }

  void _markMissingAsset(String assetPath, String category) {
    if (_failedAssets.contains(assetPath)) return;
    _failedAssets.add(assetPath);
    if (kDebugMode) {
      debugPrint(
        'Note: $category asset $assetPath is not bundled. Using fallback behavior.',
      );
    }
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
    if (!_isBundledAssetAvailable(assetPath)) {
      _markMissingAsset(assetPath, 'Music');
      return;
    }

    try {
      await _musicPlayer.play(AssetSource(assetPath));
      _currentMusicTrack = assetPath;
    } catch (e) {
      _markMissingAsset(assetPath, 'Music');
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
    if (!_isBundledAssetAvailable(assetPath)) {
      _markMissingAsset(assetPath, 'SFX');
      _triggerHapticFallback(assetPath);
      return;
    }

    try {
      final player = _sfxPool[_sfxPoolCursor++ % _sfxPool.length];
      await player.stop();
      await player.setVolume(_sfxVolume);
      await player.play(AssetSource(assetPath));
    } catch (e) {
      _markMissingAsset(assetPath, 'SFX');
      _triggerHapticFallback(assetPath);
    }
  }

  /// Trigger haptic/system sound feedback when asset is missing.
  /// Also fires the Web Audio synthesiser when running in a browser.
  void _triggerHapticFallback(String assetPath) {
    if (assetPath.contains('click') || assetPath.contains('button')) {
      playWebSound('click');
      SystemSound.play(SystemSoundType.click);
    } else if (assetPath.contains('perfect')) {
      playWebSound('perfect');
      HapticFeedback.mediumImpact();
    } else if (assetPath.contains('correct')) {
      playWebSound('correct');
      HapticFeedback.mediumImpact();
    } else if (assetPath.contains('wrong') || assetPath.contains('incorrect')) {
      playWebSound('wrong');
      HapticFeedback.heavyImpact();
    } else if (assetPath.contains('streak')) {
      playWebSound('streak');
      HapticFeedback.selectionClick();
    } else if (assetPath.contains('levelup') || assetPath.contains('level')) {
      playWebSound('levelup');
      HapticFeedback.mediumImpact();
    } else if (assetPath.contains('unlock')) {
      playWebSound('unlock');
      HapticFeedback.selectionClick();
    } else if (assetPath.contains('whoosh')) {
      playWebSound('whoosh');
    } else if (assetPath.contains('popup')) {
      playWebSound('popup');
    } else {
      playWebSound('click');
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
    for (final player in _sfxPool) {
      player.setVolume(_sfxVolume);
    }
  }

  @override
  void dispose() {
    _musicPlayer.dispose();
    for (final player in _sfxPool) {
      player.dispose();
    }
    super.dispose();
  }
}
