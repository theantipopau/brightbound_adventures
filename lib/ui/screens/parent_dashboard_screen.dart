import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// Parent Dashboard with PIN protection
/// Shows progress statistics, zone breakdowns, and learning insights
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  bool _isUnlocked = false;
  final _pinController = TextEditingController();
  String _currentPin = '';

  // Default PIN - parents can change this
  static const String _defaultPin = '1234';

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return _buildPinScreen();
    }
    return _buildDashboard();
  }

  Widget _buildPinScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade700,
              Colors.purple.shade800,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Parent Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Enter PIN to access',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // PIN display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isFilled = index < _currentPin.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isFilled
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isFilled
                              ? const Text(
                                  '•',
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: Colors.indigo,
                                  ),
                                )
                              : null,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 40),

                  // Number pad
                  _buildNumberPad(),

                  const SizedBox(height: 24),

                  // Back button
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    label: const Text(
                      'Back to Game',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Hint
                  Text(
                    'Default PIN: 1234',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('1'),
            _buildNumberButton('2'),
            _buildNumberButton('3'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('4'),
            _buildNumberButton('5'),
            _buildNumberButton('6'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('7'),
            _buildNumberButton('8'),
            _buildNumberButton('9'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              icon: Icons.backspace_outlined,
              onTap: _handleBackspace,
            ),
            _buildNumberButton('0'),
            _buildActionButton(
              icon: Icons.check,
              onTap: _handleSubmit,
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _handleNumberTap(number),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: (color ?? Colors.white).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: color ?? Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  void _handleNumberTap(String number) {
    if (_currentPin.length < 4) {
      setState(() {
        _currentPin += number;
      });

      // Auto-submit when 4 digits entered
      if (_currentPin.length == 4) {
        Future.delayed(const Duration(milliseconds: 200), _handleSubmit);
      }
    }
  }

  void _handleBackspace() {
    if (_currentPin.isNotEmpty) {
      setState(() {
        _currentPin = _currentPin.substring(0, _currentPin.length - 1);
      });
    }
  }

  void _handleSubmit() {
    if (_currentPin == _defaultPin) {
      setState(() {
        _isUnlocked = true;
      });
    } else {
      // Wrong PIN - shake animation would be nice
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect PIN'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _currentPin = '';
      });
    }
  }

  Widget _buildDashboard() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade50,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: Colors.indigo,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.lock),
                    onPressed: () {
                      setState(() {
                        _isUnlocked = false;
                        _currentPin = '';
                      });
                    },
                    tooltip: 'Lock Dashboard',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Parent Dashboard'),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.shade700,
                          Colors.purple.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),

              // Summary Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer2<SkillProvider, StreakService>(
                    builder: (context, skillProvider, streakService, _) {
                      final stats = skillProvider.isInitialized
                          ? skillProvider.getProgressionStats()
                          : null;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Player info
                          Consumer<AvatarProvider>(
                            builder: (context, avatarProvider, _) {
                              final avatar = avatarProvider.avatar;
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.shade100,
                                    child: const Text('👤',
                                        style: TextStyle(fontSize: 20)),
                                  ),
                                  title: Text(
                                    avatar?.name ?? 'No Player',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: const Text('Current Player'),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Quick stats row
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  '${streakService.currentStreak}',
                                  'Day Streak',
                                  Icons.local_fire_department,
                                  Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  '${streakService.totalDaysPlayed}',
                                  'Days Played',
                                  Icons.calendar_today,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  '${stats?.mastered ?? 0}',
                                  'Mastered',
                                  Icons.star,
                                  Colors.amber,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Progress section
                          const Text(
                            'Learning Progress',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          if (stats != null) ...[
                            _buildProgressOverview(stats, skillProvider),
                          ],

                          const SizedBox(height: 24),

                          // Zone breakdown
                          const Text(
                            'Zone Progress',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          if (skillProvider.isInitialized) ...[
                            _buildZoneProgress(skillProvider, 'word_woods',
                                '🌲 Word Woods', AppColors.wordWoodsColor),
                            _buildZoneProgress(
                                skillProvider,
                                'number_nebula',
                                '🌌 Number Nebula',
                                AppColors.numberNebulaColor),
                            _buildZoneProgress(skillProvider, 'puzzle_peaks',
                                '🧩 Puzzle Peaks', AppColors.puzzlePeaksColor),
                            _buildZoneProgress(
                                skillProvider,
                                'story_springs',
                                '📖 Story Springs',
                                AppColors.storyspringsColor),
                            _buildZoneProgress(
                                skillProvider,
                                'adventure_arena',
                                '🏆 Adventure Arena',
                                AppColors.adventureArenaColor),
                          ],

                          const SizedBox(height: 24),

                          // Achievements summary
                          const Text(
                            'Achievements',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Consumer<AchievementService>(
                            builder: (context, achievements, _) {
                              final unlocked =
                                  achievements.getUnlocked().length;
                              final total = achievements.achievements.length;

                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.amber
                                              .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Text('🏆',
                                            style: TextStyle(fontSize: 28)),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '$unlocked of $total Unlocked',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            LinearProgressIndicator(
                                              value: total > 0
                                                  ? unlocked / total
                                                  : 0,
                                              backgroundColor: Colors.grey[300],
                                              valueColor:
                                                  const AlwaysStoppedAnimation(
                                                      Colors.amber),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverview(dynamic stats, SkillProvider skillProvider) {
    final totalSkills = skillProvider.skills.length;
    final mastered = stats.mastered as int;
    final practising = stats.practising as int;
    final locked = stats.locked as int;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressStat('$mastered', 'Mastered', Colors.green),
                _buildProgressStat('$practising', 'In Progress', Colors.blue),
                _buildProgressStat('$locked', 'Locked', Colors.grey),
                _buildProgressStat('$totalSkills', 'Total', Colors.purple),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: totalSkills > 0 ? mastered / totalSkills : 0,
                minHeight: 12,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation(Colors.green),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${((mastered / totalSkills) * 100).toStringAsFixed(1)}% Complete',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildZoneProgress(SkillProvider skillProvider, String zoneId,
      String zoneName, Color color) {
    final stats = skillProvider.getZoneStats(zoneId);
    final progress =
        stats.totalSkills > 0 ? stats.masteredSkills / stats.totalSkills : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  zoneName.split(' ')[0], // Get emoji
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zoneName.substring(zoneName.indexOf(' ') + 1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation(color),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${stats.masteredSkills}/${stats.totalSkills}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (stats.averageAccuracy > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Avg. Accuracy: ${stats.averageAccuracy.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
