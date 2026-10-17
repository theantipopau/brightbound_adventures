import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:brightbound_adventures/core/utils/web_sound_player.dart';

class AudioManager extends ChangeNotifier {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  /// Widget-test harness: audio backends (audioplayers / WebAudio) cannot
  /// run meaningfully there — playing leaves pending timers and fails the
  /// pending-timer invariant. Reactions still fire (haptics) so behaviour
  /// is exercised without spinning up a real audio device.
  static final bool _inTestHarness = !kIsWeb &&
      Platform.environment.containsKey('FLUTTER_TEST');

  static bool get inTestHarness => _inTestHarness;

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
    'sounds/sfx/correct/correct1.wav',
    'sounds/sfx/correct/correct2.wav',
    'sounds/sfx/correct/correct3.wav',
    'sounds/sfx/incorrect/wrong1.wav',
    'sounds/sfx/incorrect/wrong2.wav',
    'sounds/sfx/celebration/perfect.wav',
    'sounds/sfx/celebration/streak3.wav',
    'sounds/sfx/celebration/streak5.wav',
    'sounds/sfx/celebration/streak10.wav',
    'sounds/sfx/celebration/levelup.wav',
    'sounds/sfx/celebration/unlock.wav',
    'sounds/sfx/ui/click.wav',
    'sounds/sfx/ui/whoosh.wav',
    'sounds/sfx/ui/popup.wav',
    // Music ships as MP3 (transcoded from the generator's WAV output at
    // 96k mono — 1.5MB total vs 5.2MB as WAV). SFX stay WAV (tiny). If you
    // re-run tool/generate_audio_assets.py, re-transcode music to .mp3.
    'sounds/music/menu.mp3',
    'sounds/music/splash.mp3',
    // All eight zones ship ambience now (task A4).
    'sounds/music/zones/word_woods.mp3',
    'sounds/music/zones/number_nebula.mp3',
    'sounds/music/zones/math_facts.mp3',
    'sounds/music/zones/story_springs.mp3',
    'sounds/music/zones/science_explorers.mp3',
    'sounds/music/zones/creative_corner.mp3',
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
    if (_inTestHarness) return;
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

  /// Play zone-specific ambient music (looping, quiet focus audio)
  Future<void> playZoneMusic(String zoneId) async {
    // Music ships as MP3 only (WAVs were transcoded away); underscore and
    // hyphen spellings both occur across call sites, so try both.
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
    if (_inTestHarness) {
      // Still run the haptic fallback so the reaction contract is exercised.
      _triggerHapticFallback(assetPath);
      return;
    }
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
  Future<void> playButtonClick() => playSfx('sounds/sfx/ui/click.wav');
  Future<void> playWhoosh() => playSfx('sounds/sfx/ui/whoosh.wav');
  Future<void> playPopup() => playSfx('sounds/sfx/ui/popup.wav');

  /// Play answer feedback sounds.
  ///
  /// Haptics fire on the success path too (previously they only fired as
  /// a fallback when an asset was missing): correct = medium pop,
  /// incorrect = heavy thud. HapticFeedback is a no-op on web, so no
  /// platform guard is needed. Covers all 7 quiz games at once since
  /// they all route through these two methods.
  Future<void> playCorrectAnswer([int? variation]) {
    final num = variation ?? (DateTime.now().millisecond % 3) + 1;
    HapticFeedback.mediumImpact();
    return playSfx('sounds/sfx/correct/correct$num.wav');
  }

  Future<void> playIncorrectAnswer([int? variation]) {
    final num = variation ?? (DateTime.now().millisecond % 2) + 1;
    HapticFeedback.heavyImpact();
    return playSfx('sounds/sfx/incorrect/wrong$num.wav');
  }

  /// Play celebration sounds for achievements
  Future<void> playPerfectScore() =>
      playSfx('sounds/sfx/celebration/perfect.wav');
  Future<void> playStreak(int streakCount) {
    if (streakCount >= 10) {
      return playSfx('sounds/sfx/celebration/streak10.wav');
    } else if (streakCount >= 5) {
      return playSfx('sounds/sfx/celebration/streak5.wav');
    } else if (streakCount >= 3) {
      return playSfx('sounds/sfx/celebration/streak3.wav');
    }
    return Future.value();
  }

  Future<void> playLevelUp() {
    HapticFeedback.heavyImpact();
    return playSfx('sounds/sfx/celebration/levelup.wav');
  }

  Future<void> playUnlock() {
    HapticFeedback.mediumImpact();
    return playSfx('sounds/sfx/celebration/unlock.wav');
  }

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
