import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/index.dart';
import 'package:brightbound_adventures/features/literacy/screens/skill_practice_screen.dart';
import 'package:brightbound_adventures/features/numeracy/screens/numeracy_practice_screen.dart';
import 'package:brightbound_adventures/features/storytelling/screens/story_practice_screen.dart';
import 'package:brightbound_adventures/features/logic/screens/logic_practice_screen.dart';
import 'package:brightbound_adventures/features/motor/screens/motor_practice_screen.dart';

class ZoneDetailScreen extends StatefulWidget {
  final String zoneId;
  final String zoneName;
  final String zoneDescription;
  final Color zoneColor;

  const ZoneDetailScreen({
    super.key,
    required this.zoneId,
    required this.zoneName,
    required this.zoneDescription,
    required this.zoneColor,
  });

  @override
  State<ZoneDetailScreen> createState() => _ZoneDetailScreenState();
}

class _ZoneDetailScreenState extends State<ZoneDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger lazy initialization of skills when zone is first entered
    Future.microtask(() {
      if (mounted) {
        context.read<SkillProvider>().initializeSkills();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.zoneName),
        elevation: 0,
        backgroundColor: widget.zoneColor,
      ),
      body: Consumer<SkillProvider>(
        builder: (context, skillProvider, _) {
          if (!skillProvider.isInitialized) {
            return const BrightBoundLoading(
              message: 'Loading skills...',
            );
          }

          final zoneSkills = skillProvider.getZoneSkills(widget.zoneId);
          final zoneStats = skillProvider.getZoneStats(widget.zoneId);

          if (zoneSkills.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No skills in this zone yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Enhanced zone header with animated character
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 200,
                floating: false,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Consumer<AvatarProvider>(
                    builder: (context, avatarProvider, _) {
                      return EnhancedZoneHeader(
                        zoneId: widget.zoneId,
                        zoneName: widget.zoneName,
                        zoneDescription: widget.zoneDescription,
                        zoneColor: widget.zoneColor,
                        avatar: avatarProvider.avatar,
                      );
                    },
                  ),
                ),
              ),

              // Zone stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ZoneProgressCard(
                    zoneName: widget.zoneName,
                    masteredSkills: zoneStats.masteredSkills,
                    totalSkills: zoneStats.totalSkills,
                    averageAccuracy: zoneStats.averageAccuracy,
                  ),
                ),
              ),

              // Filter/sort options
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${zoneSkills.length} Skills',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            // TODO: Implement filtering
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'all',
                            child: Text('All Skills'),
                          ),
                          const PopupMenuItem(
                            value: 'locked',
                            child: Text('Locked'),
                          ),
                          const PopupMenuItem(
                            value: 'available',
                            child: Text('Available'),
                          ),
                          const PopupMenuItem(
                            value: 'mastered',
                            child: Text('Mastered'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Skills list
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final skill = zoneSkills[index];
                      final isLocked = skill.state == SkillState.locked;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SkillCard(
                          skill: skill,
                          onTap: isLocked
                              ? null
                              : () {
                                  _showSkillDetail(context, skill);
                                },
                          showLockOverlay: isLocked,
                        ),
                      );
                    },
                    childCount: zoneSkills.length,
                  ),
                ),
              ),

              // Bottom padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          );
        },
      ),
    );
  }

  void _showSkillDetail(BuildContext context, Skill skill) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Skill header
              Row(
                children: [
                  BrightBoundGraphics.buildMasteryBadge(skill.state),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          skill.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats grid
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildStatTile(
                    context,
                    'Accuracy',
                    '${(skill.accuracy * 100).toStringAsFixed(0)}%',
                    AppColors.secondary,
                  ),
                  _buildStatTile(
                    context,
                    'Attempts',
                    skill.attempts.toString(),
                    AppColors.tertiary,
                  ),
                  _buildStatTile(
                    context,
                    'Difficulty',
                    '${skill.difficulty}/5',
                    AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Mastery indicators
              if (skill.state != SkillState.locked) ...[
                Text(
                  'Progress to Next Level',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildMasteryGuideline(context, skill),
                const SizedBox(height: 24),
              ],

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _launchSkillPractice(context, skill);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Practice Skill'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryGuideline(BuildContext context, Skill skill) {
    final nextState = skill.getNextState();
    final nextStateText = switch (nextState) {
      SkillState.introduced => 'Reach 65% accuracy to introduce',
      SkillState.practising => 'Reach 85% accuracy without hints to master',
      SkillState.mastered => '✓ Mastered!',
      _ => 'Continue practicing',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nextStateText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.info,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchSkillPractice(BuildContext context, Skill skill) {
    // Choose the appropriate practice screen based on zone
    Widget practiceScreen;

    if (widget.zoneId == 'number_nebula') {
      practiceScreen = NumeracyPracticeScreen(
        skill: skill,
        themeColor: widget.zoneColor,
      );
    } else if (widget.zoneId == 'story_springs') {
      practiceScreen = StoryPracticeScreen(
        skillId: skill.id,
        skillName: skill.name,
      );
    } else if (widget.zoneId == 'puzzle_peaks') {
      practiceScreen = LogicPracticeScreen(
        skillId: skill.id,
        skillName: skill.name,
      );
    } else if (widget.zoneId == 'adventure_arena') {
      practiceScreen = MotorPracticeScreen(
        skillId: skill.id,
        skillName: skill.name,
      );
    } else {
      // Default to literacy practice screen for other zones (Word Woods)
      practiceScreen = SkillPracticeScreen(
        skill: skill,
        themeColor: widget.zoneColor,
      );
    }

    Navigator.push(
      context,
      FadeSlidePageRoute(page: practiceScreen),
    );
  }
}
