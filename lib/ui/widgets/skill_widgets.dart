import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/graphics_helpers.dart';

class SkillCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback? onTap;
  final bool showLockOverlay;

  const SkillCard({
    super.key,
    required this.skill,
    this.onTap,
    this.showLockOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: showLockOverlay ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and state badge
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              skill.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              skill.description,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      BrightBoundGraphics.buildMasteryBadge(skill.state),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // NAPLAN indicator if applicable
                  if (skill.naplanArea != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BrightBoundGraphics.buildSkillBadge(
                        label: '⚠️ NAPLAN Focus',
                        backgroundColor: AppColors.warning.withOpacity(0.2),
                        textColor: AppColors.warning,
                        padding: 6,
                      ),
                    ),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: skill.accuracy,
                      minHeight: 8,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation(
                        _getProgressColor(skill.state),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Accuracy
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Accuracy',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            Text(
                              '${(skill.accuracy * 100).toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // Attempts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attempts',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            Text(
                              skill.attempts.toString(),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // Difficulty
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Difficulty',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            BrightBoundGraphics.buildDifficultyBars(
                              level: skill.difficulty,
                              barHeight: 12,
                              filledColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showLockOverlay) BrightBoundGraphics.buildLockedOverlay(),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(SkillState state) {
    switch (state) {
      case SkillState.locked:
        return Colors.grey;
      case SkillState.introduced:
        return AppColors.secondary;
      case SkillState.practising:
        return AppColors.tertiary;
      case SkillState.mastered:
        return AppColors.success;
    }
  }
}

class SkillListView extends StatelessWidget {
  final List<Skill> skills;
  final ValueChanged<Skill>? onSkillTap;
  final bool showLocked;

  const SkillListView({
    super.key,
    required this.skills,
    this.onSkillTap,
    this.showLocked = true,
  });

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 64, color: AppColors.divider),
              const SizedBox(height: 16),
              Text(
                'No skills available',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        final isLocked = skill.state == SkillState.locked;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkillCard(
            skill: skill,
            onTap: isLocked ? null : () => onSkillTap?.call(skill),
            showLockOverlay: isLocked && !showLocked,
          ),
        );
      },
    );
  }
}

class ProgressionStatusWidget extends StatelessWidget {
  final int mastered;
  final int practising;
  final int introduced;
  final int locked;

  const ProgressionStatusWidget({
    super.key,
    required this.mastered,
    required this.practising,
    required this.introduced,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final total = mastered + practising + introduced + locked;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Progress',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Progress ring
            Center(
              child: BrightBoundGraphics.buildProgressRing(
                progress: total > 0 ? (mastered + practising) / total : 0,
                size: 140,
                backgroundColor: AppColors.primary,
                progressColor: AppColors.success,
                centerText: '${((mastered + practising) / (total > 0 ? total : 1) * 100).toStringAsFixed(0)}%',
                textStyle: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 20),
            // Status breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusItem(
                  context,
                  icon: Icons.check_circle,
                  label: 'Mastered',
                  count: mastered,
                  color: AppColors.success,
                ),
                _buildStatusItem(
                  context,
                  icon: Icons.repeat,
                  label: 'Practising',
                  count: practising,
                  color: AppColors.tertiary,
                ),
                _buildStatusItem(
                  context,
                  icon: Icons.play_arrow,
                  label: 'Introduced',
                  count: introduced,
                  color: AppColors.secondary,
                ),
                _buildStatusItem(
                  context,
                  icon: Icons.lock,
                  label: 'Locked',
                  count: locked,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ZoneProgressCard extends StatelessWidget {
  final String zoneName;
  final int masteredSkills;
  final int totalSkills;
  final double averageAccuracy;
  final VoidCallback? onTap;

  const ZoneProgressCard({
    super.key,
    required this.zoneName,
    required this.masteredSkills,
    required this.totalSkills,
    required this.averageAccuracy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completionPercentage = totalSkills > 0 ? (masteredSkills / totalSkills) * 100 : 0;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    zoneName,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$masteredSkills/$totalSkills Mastered',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    '${completionPercentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: completionPercentage / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation(AppColors.success),
                ),
              ),
              const SizedBox(height: 8),
              // Accuracy
              Text(
                'Average Accuracy: ${(averageAccuracy * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
