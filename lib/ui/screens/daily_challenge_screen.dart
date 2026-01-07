import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/models/daily_challenge.dart';
import 'package:brightbound_adventures/core/services/skill_provider.dart';
import 'package:brightbound_adventures/ui/themes/app_theme.dart';

/// Daily Skill Challenges Screen
/// Features rotating daily challenges with rewards
class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late List<DailyChallenge> challenges;
  late Map<String, bool> completedChallenges;

  @override
  void initState() {
    super.initState();
    challenges = DailyChallengeGenerator.generateDailyChallenges(DateTime.now());
    completedChallenges = {};
    for (final challenge in challenges) {
      completedChallenges[challenge.id] = false;
    }
  }

  int get completedCount => completedChallenges.values.where((v) => v).length;
  int get totalRewards => completedCount * 10;

  String _getTimeUntilReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final difference = tomorrow.difference(now);
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.indigo.shade900,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.indigo.shade900,
                      Colors.purple.shade800,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Row(
                        children: [
                          Text('🎯', style: TextStyle(fontSize: 40)),
                          SizedBox(width: 12),
                          Text(
                            'Daily Challenges',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${completedCount}/${challenges.length} Completed',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  'Resets in ${_getTimeUntilReset()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              title: const Text(
                'Daily Challenges',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          // Challenge Progress
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: completedCount / challenges.length,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation(
                        Colors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Rewards preview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade100,
                          Colors.orange.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.amber.shade300,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonus Rewards',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Complete daily challenges for extra XP!',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+$totalRewards XP',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Today\'s Challenges',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Challenges list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final challenge = challenges[index];
                final isCompleted = completedChallenges[challenge.id] ?? false;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: _buildChallengeCard(
                    challenge: challenge,
                    isCompleted: isCompleted,
                    onTap: () => _completedChallenge(challenge.id),
                  ),
                );
              },
              childCount: challenges.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildChallengeCard({
    required DailyChallenge challenge,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isCompleted ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted
              ? Colors.grey[200]
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? Colors.grey[400]!
                : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji indicator
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  challenge.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Challenge details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? Colors.grey[400]
                          : Colors.black,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCompleted
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Reward and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.xpReward}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 14, color: Colors.green),
                        SizedBox(width: 2),
                        Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_forward, size: 14, color: Colors.blue),
                        SizedBox(width: 2),
                        Text(
                          'Start',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _completedChallenge(String challengeId) {
    setState(() {
      completedChallenges[challengeId] = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✨ Challenge Completed! +10 XP'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Daily Challenge Generator
class DailyChallengeGenerator {
  static List<DailyChallenge> generateDailyChallenges(DateTime date) {
    return [
      DailyChallenge(
        id: 'daily_1_${date.toString().split(' ')[0]}',
        title: 'Word Wizard',
        description: 'Complete 3 lessons in Word Woods',
        zoneId: 'word_woods',
        skillId: 'letter-recognition',
        emoji: '🌲',
        targetScore: 3,
        xpReward: 50,
        date: date,
      ),
      DailyChallenge(
        id: 'daily_2_${date.toString().split(' ')[0]}',
        title: 'Number Ninja',
        description: 'Practice 5 number questions',
        zoneId: 'number_nebula',
        skillId: 'place-value',
        emoji: '🌌',
        targetScore: 5,
        xpReward: 75,
        date: date,
      ),
      DailyChallenge(
        id: 'daily_3_${date.toString().split(' ')[0]}',
        title: 'Math Master',
        description: 'Solve 10 math problems correctly',
        zoneId: 'math_facts',
        skillId: 'multiplication',
        emoji: '🔢',
        targetScore: 10,
        xpReward: 75,
        date: date,
      ),
      DailyChallenge(
        id: 'daily_4_${date.toString().split(' ')[0]}',
        title: 'Story Supreme',
        description: 'Complete a full story challenge',
        zoneId: 'story_springs',
        skillId: 'narrative-writing',
        emoji: '📖',
        targetScore: 1,
        xpReward: 100,
        date: date,
      ),
    ];
  }
}
