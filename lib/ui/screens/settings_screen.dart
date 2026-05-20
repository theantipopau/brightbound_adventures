import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/index.dart';
import '../../core/services/index.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _hapticEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoReadQuestions = false;
  bool _aiHintsEnabled = false;
  bool _aiExplanationsEnabled = false;
  bool _aiCloudMode = false;
  bool _reduceMotion = false;
  bool _highContrast = false;
  bool _largeText = false;
  double _difficulty = 1.0; // 0 = Easy, 1 = Normal, 2 = Hard

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final audio = context.read<AudioManager>();
      final themeMode = context.read<ThemeModeService>();
      final visualAccessibility = context.read<VisualAccessibilityService>();
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _soundEnabled = prefs.getBool('soundEnabled') ?? audio.isSfxEnabled;
        _musicEnabled = prefs.getBool('musicEnabled') ?? audio.isMusicEnabled;
        _hapticEnabled = prefs.getBool('hapticEnabled') ?? true;
        _darkModeEnabled = themeMode.isDarkMode;
        _autoReadQuestions =
            prefs.getBool(QuizPreferencesService.autoReadQuestionsKey) ?? false;
        _aiHintsEnabled =
            prefs.getBool(QuizPreferencesService.aiHintsEnabledKey) ?? false;
        _aiExplanationsEnabled =
            prefs.getBool(QuizPreferencesService.aiExplanationsEnabledKey) ??
                false;
        _aiCloudMode =
            prefs.getBool(QuizPreferencesService.aiCloudModeKey) ?? false;
        _reduceMotion = visualAccessibility.reduceMotion;
        _highContrast = visualAccessibility.highContrast;
        _largeText = visualAccessibility.largeText;
        _difficulty = prefs.getDouble('difficulty') ?? 1.0;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e) {
      debugPrint('Error saving setting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF1A1E2D), Color(0xFF2A2343)]
                : const [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Audio Settings
          _buildSection(
            title: '🔊 Audio',
            children: [
              _buildSwitchTile(
                title: 'Sound Effects',
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() => _soundEnabled = value);
                  _saveSetting('soundEnabled', value);
                  final audio = context.read<AudioManager>();
                  if (audio.isSfxEnabled != value) audio.toggleSfx();
                },
              ),
              _buildSwitchTile(
                title: 'Background Music',
                value: _musicEnabled,
                onChanged: (value) {
                  setState(() => _musicEnabled = value);
                  _saveSetting('musicEnabled', value);
                  final audio = context.read<AudioManager>();
                  if (audio.isMusicEnabled != value) audio.toggleMusic();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Appearance Settings
          _buildSection(
            title: '🎨 Appearance',
            children: [
              _buildSwitchTile(
                title: 'Dark Theme',
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() => _darkModeEnabled = value);
                  context.read<ThemeModeService>().setDarkMode(value);
                },
              ),
              _buildSwitchTile(
                title: 'High Contrast',
                subtitle: 'Sharper surfaces and stronger readable edges',
                value: _highContrast,
                onChanged: (value) {
                  setState(() => _highContrast = value);
                  context
                      .read<VisualAccessibilityService>()
                      .setHighContrast(value);
                },
              ),
              _buildSwitchTile(
                title: 'Larger Text',
                subtitle: 'Gently increases app text without breaking layouts',
                value: _largeText,
                onChanged: (value) {
                  setState(() => _largeText = value);
                  context
                      .read<VisualAccessibilityService>()
                      .setLargeText(value);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Gameplay Settings
          _buildSection(
            title: '🎮 Gameplay',
            children: [
              _buildSwitchTile(
                title: 'Haptic Feedback',
                value: _hapticEnabled,
                onChanged: (value) {
                  setState(() => _hapticEnabled = value);
                  _saveSetting('hapticEnabled', value);
                },
              ),
              _buildSwitchTile(
                title: 'Reduce Motion',
                subtitle: 'Softens looping effects and respects motion comfort',
                value: _reduceMotion,
                onChanged: (value) {
                  setState(() => _reduceMotion = value);
                  context
                      .read<VisualAccessibilityService>()
                      .setReduceMotion(value);
                },
              ),
              _buildSwitchTile(
                title: 'Auto-read Questions Aloud',
                value: _autoReadQuestions,
                onChanged: (value) {
                  setState(() => _autoReadQuestions = value);
                  _saveSetting(
                      QuizPreferencesService.autoReadQuestionsKey, value);
                },
              ),
              _buildDifficultySlider(),
            ],
          ),

          const SizedBox(height: 16),

          // AI Learning Settings
          _buildSection(
            title: '🤖 AI Learning',
            children: [
              _buildSwitchTile(
                title: 'AI Hints',
                value: _aiHintsEnabled,
                onChanged: (value) {
                  setState(() => _aiHintsEnabled = value);
                  _saveSetting(QuizPreferencesService.aiHintsEnabledKey, value);
                },
              ),
              _buildSwitchTile(
                title: 'AI Explanations',
                value: _aiExplanationsEnabled,
                onChanged: (value) {
                  setState(() => _aiExplanationsEnabled = value);
                  _saveSetting(
                      QuizPreferencesService.aiExplanationsEnabledKey, value);
                },
              ),
              _buildSwitchTile(
                title: 'Cloud AI Mode (Experimental)',
                value: _aiCloudMode,
                onChanged: (value) {
                  setState(() => _aiCloudMode = value);
                  _saveSetting(QuizPreferencesService.aiCloudModeKey, value);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // About Section
          _buildSection(
            title: 'ℹ️ About',
            children: [
              _buildInfoTile(
                title: 'Version',
                value: '1.0.0',
              ),
              _buildInfoTile(
                title: 'Created By',
                value: 'Matt Hurley',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDifficultySlider() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Difficulty Level',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Easy'),
              Expanded(
                child: Slider(
                  value: _difficulty,
                  min: 0,
                  max: 2,
                  divisions: 2,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _difficulty = value);
                  },
                  onChangeEnd: (value) {
                    _saveSetting('difficulty', value);
                  },
                ),
              ),
              const Text('Hard'),
            ],
          ),
          Center(
            child: Text(
              _getDifficultyLabel(_difficulty),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getDifficultyColor(_difficulty),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyLabel(double value) {
    if (value < 0.5) return 'Easy Mode';
    if (value < 1.5) return 'Normal Mode';
    return 'Challenge Mode';
  }

  Color _getDifficultyColor(double value) {
    if (value < 0.5) return Colors.green;
    if (value < 1.5) return Colors.orange;
    return Colors.red;
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.72),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
