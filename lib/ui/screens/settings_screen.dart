import 'package:flutter/material.dart';
import '../themes/index.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _hapticEnabled = true;
  double _difficulty = 1.0; // 0 = Easy, 1 = Normal, 2 = Hard

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // TODO: Load settings from local storage
    // For now, using defaults
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    // TODO: Save setting to local storage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
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
                },
              ),
              _buildSwitchTile(
                title: 'Background Music',
                value: _musicEnabled,
                onChanged: (value) {
                  setState(() => _musicEnabled = value);
                  _saveSetting('musicEnabled', value);
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
              _buildDifficultySlider(),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
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
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
