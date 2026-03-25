import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _storedPin = '1234';

  static const String _pinPrefKey = 'parentPin';

  @override
  void initState() {
    super.initState();
    _loadStoredPin();
  }

  Future<void> _loadStoredPin() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _storedPin = prefs.getString(_pinPrefKey) ?? '1234');
    }
  }

  Future<void> _savePin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinPrefKey, newPin);
    if (mounted) setState(() => _storedPin = newPin);
  }

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
                    'Enter your parent PIN',
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
    if (_currentPin == _storedPin) {
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

  void _showChangePinDialog() {
    String newPin = '';
    String confirmPin = '';
    int step = 0; // 0 = enter new PIN, 1 = confirm new PIN

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentEntry = step == 0 ? newPin : confirmPin;
            final title = step == 0 ? 'Enter New PIN' : 'Confirm New PIN';

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade700, Colors.purple.shade700],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // PIN dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        final filled = i < currentEntry.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: filled
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 2),
                          ),
                          child: Center(
                            child: filled
                                ? const Text('•',
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.indigo))
                                : null,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    // Mini number pad
                    ...[ ['1','2','3'], ['4','5','6'], ['7','8','9'] ].map((row) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: row.map((n) {
                          return Padding(
                            padding: const EdgeInsets.all(6),
                            child: Material(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  if (currentEntry.length < 4) {
                                    setDialogState(() {
                                      if (step == 0) {
                                        newPin += n;
                                      } else {
                                        confirmPin += n;
                                      }
                                    });
                                    final updated = step == 0 ? newPin : confirmPin;
                                    if (updated.length == 4) {
                                      final messenger = ScaffoldMessenger.of(this.context);
                                      Future.delayed(const Duration(milliseconds: 200), () {
                                        if (step == 0) {
                                          setDialogState(() => step = 1);
                                        } else {
                                          if (newPin == confirmPin) {
                                            Navigator.pop(dialogContext);
                                            _savePin(newPin);
                                            messenger.showSnackBar(
                                              const SnackBar(
                                                content: Text('PIN changed successfully'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } else {
                                            setDialogState(() {
                                              newPin = '';
                                              confirmPin = '';
                                              step = 0;
                                            });
                                            messenger.showSnackBar(
                                              const SnackBar(
                                                content: Text('PINs did not match — try again'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      });
                                    }
                                  }
                                },
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Center(
                                    child: Text(n,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setDialogState(() {
                                  if (step == 0 && newPin.isNotEmpty) {
                                    newPin = newPin.substring(0, newPin.length - 1);
                                  } else if (step == 1 && confirmPin.isNotEmpty) {
                                    confirmPin = confirmPin.substring(0, confirmPin.length - 1);
                                  }
                                });
                              },
                              child: const SizedBox(width: 60, height: 60,
                                child: Center(child: Icon(Icons.backspace_outlined, color: Colors.white, size: 24))),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                final entry = step == 0 ? newPin : confirmPin;
                                if (entry.length < 4) {
                                  setDialogState(() {
                                    if (step == 0) {
                                      newPin += '0';
                                    } else {
                                      confirmPin += '0';
                                    }
                                  });
                                }
                              },
                              child: const SizedBox(width: 60, height: 60,
                                child: Center(child: Text('0', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)))),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Material(
                            color: Colors.red.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.pop(dialogContext),
                              child: const SizedBox(width: 60, height: 60,
                                child: Center(child: Icon(Icons.close, color: Colors.white, size: 24))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
                    icon: const Icon(Icons.edit),
                    onPressed: _showChangePinDialog,
                    tooltip: 'Change PIN',
                  ),
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
