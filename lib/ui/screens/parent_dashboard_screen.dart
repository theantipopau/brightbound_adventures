import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightbound_adventures/core/models/skill.dart';
import 'package:brightbound_adventures/core/services/index.dart';

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
                                      final messenger = ScaffoldMessenger.maybeOf(context);
                                      if (step == 0) {
                                        setDialogState(() => step = 1);
                                      } else {
                                        if (newPin == confirmPin) {
                                          Navigator.pop(dialogContext);
                                          _savePin(newPin);
                                          messenger?.showSnackBar(
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
                                          messenger?.showSnackBar(
                                            const SnackBar(
                                              content: Text('PINs did not match — try again'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
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

  // ─────────────────────────────────────────────────────────────────────────
  //  Dashboard (post-unlock)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildDashboard() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Consumer2<SkillProvider, StreakService>(
          builder: (context, skillProvider, streakService, _) {
            final stats = skillProvider.isInitialized
                ? skillProvider.getProgressionStats()
                : null;
            return CustomScrollView(
              slivers: [
                // ── Header AppBar ──────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 110,
                  backgroundColor: Colors.indigo.shade700,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: _showChangePinDialog,
                      tooltip: 'Change PIN',
                    ),
                    IconButton(
                      icon: const Icon(Icons.lock, color: Colors.white),
                      onPressed: () => setState(() {
                        _isUnlocked = false;
                        _currentPin = '';
                      }),
                      tooltip: 'Lock Dashboard',
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text('Parent Dashboard',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.indigo.shade800, Colors.purple.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Player & Level card ──────────────────────────
                        Consumer<AvatarProvider>(
                          builder: (_, avatarProvider, __) {
                            final avatar = avatarProvider.avatar;
                            if (avatar == null) return const SizedBox.shrink();
                            return _buildPlayerCard(avatar, streakService);
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Quick stats ──────────────────────────────────
                        _buildQuickStats(skillProvider, streakService, stats),
                        const SizedBox(height: 20),

                        // ── 7-day activity ───────────────────────────────
                        _buildSectionHeader('📅 This Week\'s Activity'),
                        const SizedBox(height: 10),
                        _buildWeeklyActivity(streakService),
                        const SizedBox(height: 20),

                        // ── Skills overview donut ────────────────────────
                        _buildSectionHeader('🎯 Skills Overview'),
                        const SizedBox(height: 10),
                        if (stats != null) _buildSkillsBreakdownCard(stats),
                        const SizedBox(height: 20),

                        // ── Zone progress ────────────────────────────────
                        _buildSectionHeader('🗺️ Zone Progress'),
                        const SizedBox(height: 10),
                        if (skillProvider.isInitialized)
                          _buildAllZoneCards(skillProvider),
                        const SizedBox(height: 20),

                        // ── Weakest skills ───────────────────────────────
                        if (skillProvider.isInitialized) ...[
                          _buildSectionHeader('⚠️ Needs More Practice'),
                          const SizedBox(height: 10),
                          _buildWeakestSkills(skillProvider),
                          const SizedBox(height: 20),
                        ],

                        // ── Achievements ─────────────────────────────────
                        _buildSectionHeader('🏆 Achievements'),
                        const SizedBox(height: 10),
                        Consumer<AchievementService>(
                          builder: (_, achievements, __) =>
                              _buildAchievementsCard(achievements),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1F36),
      ),
    );
  }

  // ── Player Card ─────────────────────────────────────────────────────────

  Widget _buildPlayerCard(dynamic avatar, StreakService streakService) {
    final xpProgress =
        avatar.nextLevelXP > 0 ? avatar.experiencePoints / avatar.nextLevelXP : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: const Text('👤', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        avatar.name ?? 'Player',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.55)),
                      ),
                      child: Text(
                        'Lv. ${avatar.level}',
                        style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: xpProgress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.amber),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${avatar.experiencePoints} / ${avatar.nextLevelXP} XP  •  '
                  '${streakService.streakEmoji} ${streakService.currentStreak}-day streak',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick stats row ──────────────────────────────────────────────────────

  Widget _buildQuickStats(
      SkillProvider skillProvider, StreakService streakService, dynamic stats) {
    final totalAttempts = skillProvider.isInitialized
        ? skillProvider.skills.values.fold<int>(0, (s, sk) => s + sk.attempts)
        : 0;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '${streakService.currentStreak}',
            'Day Streak',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            '${streakService.totalDaysPlayed}',
            'Days Played',
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            '$totalAttempts',
            'Sessions',
            Icons.play_circle_filled,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
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
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Weekly activity ──────────────────────────────────────────────────────

  Widget _buildWeeklyActivity(StreakService streakService) {
    final activity = streakService.getWeeklyActivity();
    final now = DateTime.now();
    const dayAbbr = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final day = now.subtract(Duration(days: 6 - i));
              final played = activity[i];
              final isToday = i == 6;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300 + i * 60),
                    curve: Curves.elasticOut,
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: played
                          ? const Color(0xFF4CAF50)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: Colors.indigo.shade400, width: 2)
                          : null,
                      boxShadow: played
                          ? [
                              BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.35),
                                  blurRadius: 8)
                            ]
                          : null,
                    ),
                    child: Icon(
                      played ? Icons.check_rounded : Icons.remove,
                      size: 18,
                      color: played ? Colors.white : Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    dayAbbr[day.weekday - 1],
                    style: TextStyle(
                      fontSize: 11,
                      color: isToday
                          ? Colors.indigo.shade600
                          : Colors.grey.shade500,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _dot(const Color(0xFF4CAF50)),
              const SizedBox(width: 4),
              Text('Played', style: _legendStyle),
              const SizedBox(width: 14),
              _dot(Colors.grey.shade300),
              const SizedBox(width: 4),
              Text('Not played', style: _legendStyle),
              const Spacer(),
              Text(
                '${activity.where((b) => b).length}/7 days',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  TextStyle get _legendStyle =>
      TextStyle(fontSize: 11, color: Colors.grey.shade500);

  // ── Skills overview donut ────────────────────────────────────────────────

  Widget _buildSkillsBreakdownCard(dynamic stats) {
    final total =
        stats.mastered + stats.practising + stats.introduced + stats.locked as int;
    final pct = total > 0 ? (stats.mastered * 100 ~/ total) : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Donut chart
          SizedBox(
            width: 110,
            height: 110,
            child: _SkillDonutChart(
              mastered: stats.mastered as int,
              practising: stats.practising as int,
              introduced: stats.introduced as int,
              locked: stats.locked as int,
            ),
          ),
          const SizedBox(width: 20),
          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pct% Complete',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                const SizedBox(height: 10),
                _legendRow(Colors.green, 'Mastered', stats.mastered as int),
                const SizedBox(height: 6),
                _legendRow(const Color(0xFF2196F3), 'Practising',
                    stats.practising as int),
                const SizedBox(height: 6),
                _legendRow(Colors.orange, 'Introduced', stats.introduced as int),
                const SizedBox(height: 6),
                _legendRow(Colors.grey.shade400, 'Locked', stats.locked as int),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label, int count) => Row(
        children: [
          Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 12))),
          Text('$count',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 12)),
        ],
      );

  // ── Zone progress cards ──────────────────────────────────────────────────

  static const _zones = [
    ('word_woods', '🌲', 'Word Woods', Color(0xFF4CAF50)),
    ('number_nebula', '🌌', 'Number Nebula', Color(0xFF3F51B5)),
    ('story_springs', '📖', 'Story Springs', Color(0xFF00BCD4)),
    ('puzzle_peaks', '🧩', 'Puzzle Peaks', Color(0xFF6A1B9A)),
    ('science_explorers', '🔬', 'Science Explorers', Color(0xFF4DB6AC)),
    ('creative_corner', '🎨', 'Creative Corner', Color(0xFFFFB74D)),
    ('adventure_arena', '🏆', 'Adventure Arena', Color(0xFFF44336)),
  ];

  Widget _buildAllZoneCards(SkillProvider skillProvider) {
    return Column(
      children: _zones.map((z) {
        final (zoneId, emoji, name, color) = z;
        return _buildZoneCard(skillProvider, zoneId, emoji, name, color);
      }).toList(),
    );
  }

  Widget _buildZoneCard(SkillProvider skillProvider, String zoneId,
      String emoji, String name, Color color) {
    final stats = skillProvider.getZoneStats(zoneId);
    final masteryProgress =
        stats.totalSkills > 0 ? stats.masteredSkills / stats.totalSkills : 0.0;
    final accuracy = stats.averageAccuracy;
    final accColor = accuracy >= 0.8
        ? Colors.green
        : accuracy >= 0.5
            ? Colors.orange
            : accuracy > 0
                ? Colors.red
                : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      '${stats.masteredSkills}/${stats.totalSkills}',
                      style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: masteryProgress,
                    minHeight: 7,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      masteryProgress >= 1.0
                          ? '✅ Zone Mastered!'
                          : '${(masteryProgress * 100).toStringAsFixed(0)}% mastered',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500),
                    ),
                    if (accuracy > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: accColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(accuracy * 100).toStringAsFixed(0)}% acc',
                          style: TextStyle(
                              fontSize: 11,
                              color: accColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Weakest skills ───────────────────────────────────────────────────────

  Widget _buildWeakestSkills(SkillProvider skillProvider) {
    final attempted = skillProvider.skills.values
        .where((s) => s.attempts > 0 && s.state != SkillState.mastered)
        .toList()
      ..sort((a, b) => a.accuracy.compareTo(b.accuracy));
    final bottom5 = attempted.take(5).toList();

    if (bottom5.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            'No sessions recorded yet — start practising!',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          ...bottom5.asMap().entries.map((entry) {
            final i = entry.key;
            final skill = entry.value;
            final accuracy = skill.accuracy;
            final accColor = accuracy >= 0.7 ? Colors.orange : Colors.red;
            return Container(
              decoration: BoxDecoration(
                border: i < bottom5.length - 1
                    ? Border(
                        bottom: BorderSide(
                            color: Colors.grey.shade100, width: 1))
                    : null,
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Text(_strandEmoji(skill.strand),
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(skill.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('${skill.attempts} session(s)',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(accuracy * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                          color: accColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _strandEmoji(String strand) {
    switch (strand) {
      case 'literacy':
        return '📝';
      case 'numeracy':
        return '🔢';
      case 'communication':
        return '💬';
      case 'logic':
        return '🧩';
      case 'motor':
        return '🏃';
      case 'arts':
        return '🎨';
      case 'science':
        return '🔬';
      default:
        return '📚';
    }
  }

  // ── Achievements ─────────────────────────────────────────────────────────

  Widget _buildAchievementsCard(AchievementService achievements) {
    final unlocked = achievements.getUnlocked().length;
    final total = achievements.achievements.length;
    final progress = total > 0 ? unlocked / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unlocked of $total Badges Unlocked',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.amber),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% complete',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Animated skill donut chart
// ─────────────────────────────────────────────────────────────────────────────

class _SkillDonutChart extends StatefulWidget {
  final int mastered;
  final int practising;
  final int introduced;
  final int locked;

  const _SkillDonutChart({
    required this.mastered,
    required this.practising,
    required this.introduced,
    required this.locked,
  });

  @override
  State<_SkillDonutChart> createState() => _SkillDonutChartState();
}

class _SkillDonutChartState extends State<_SkillDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 1400), vsync: this);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total =
        widget.mastered + widget.practising + widget.introduced + widget.locked;
    final pct = total > 0 ? (widget.mastered * 100 ~/ total) : 0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CustomPaint(
              painter: _DonutPainter(
                mastered: widget.mastered,
                practising: widget.practising,
                introduced: widget.introduced,
                locked: widget.locked,
                animValue: _anim.value,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pct%',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              Text(
                'done',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int mastered;
  final int practising;
  final int introduced;
  final int locked;
  final double animValue;

  _DonutPainter({
    required this.mastered,
    required this.practising,
    required this.introduced,
    required this.locked,
    required this.animValue,
  });

  static const _colors = [
    Color(0xFF4CAF50), // mastered – green
    Color(0xFF2196F3), // practising – blue
    Color(0xFFFF9800), // introduced – orange
    Color(0xFFE0E0E0), // locked – grey
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final total = mastered + practising + introduced + locked;
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    const strokeWidth = 18.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Grey background ring
    paint.color = const Color(0xFFEEEEEE);
    canvas.drawCircle(center, radius, paint);

    // Colored segments
    double startAngle = -math.pi / 2;
    final counts = [mastered, practising, introduced, locked];

    for (int i = 0; i < 4; i++) {
      if (counts[i] == 0) continue;
      final sweep = (counts[i] / total) * 2 * math.pi * animValue;
      paint.color = _colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.animValue != animValue;
}
