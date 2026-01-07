import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/graphics_helpers.dart';

class SkillCard extends StatefulWidget {
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
  State<SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<SkillCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getSkillColor() {
    switch (widget.skill.state) {
      case SkillState.mastered:
        return AppColors.success;
      case SkillState.practising:
        return AppColors.secondary;
      case SkillState.introduced:
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  String _getSkillEmoji() {
    // Map skill names to relevant emojis
    final name = widget.skill.name.toLowerCase();
    if (name.contains('letter')) return '🔤';
    if (name.contains('phoneme') || name.contains('sound')) return '🔊';
    if (name.contains('sight') || name.contains('word')) return '👁️';
    if (name.contains('blend')) return '🔀';
    if (name.contains('sentence')) return '📝';
    if (name.contains('reading')) return '📖';
    if (name.contains('spell')) return '✏️';
    if (name.contains('vocab')) return '📚';
    if (name.contains('comprehension')) return '🧠';
    if (name.contains('punctuation') || name.contains('comma')) return '❗';
    if (name.contains('apostrophe')) return '✨';
    if (name.contains('homophone')) return '👂';
    return '⭐';
  }

  @override
  Widget build(BuildContext context) {
    final skillColor = _getSkillColor();
    final emoji = _getSkillEmoji();
    final isLocked = widget.showLockOverlay;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered && !isLocked ? 1.02 : 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLocked
                  ? [Colors.grey.shade100, Colors.grey.shade200]
                  : [
                      Colors.white,
                      skillColor.withValues(alpha: 0.08),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLocked 
                  ? Colors.grey.shade300 
                  : skillColor.withValues(alpha: _isHovered ? 0.6 : 0.3),
              width: _isHovered ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isLocked 
                    ? Colors.black.withValues(alpha: 0.05)
                    : skillColor.withValues(alpha: _isHovered ? 0.3 : 0.15),
                blurRadius: _isHovered ? 20 : 12,
                offset: const Offset(0, 6),
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLocked ? null : widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Left: Emoji icon with animated background
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final pulse = isLocked ? 0.0 : _pulseController.value * 0.15;
                        return Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: isLocked
                                  ? [Colors.grey.shade200, Colors.grey.shade300]
                                  : [
                                      skillColor.withValues(alpha: 0.2 + pulse),
                                      skillColor.withValues(alpha: 0.05),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isLocked ? null : [
                              BoxShadow(
                                color: skillColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              isLocked ? '🔒' : emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    
                    // Middle: Skill info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.skill.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isLocked ? Colors.grey : Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.skill.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isLocked ? Colors.grey : AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          
                          // Progress bar with glow
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: widget.skill.accuracy,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isLocked 
                                        ? [Colors.grey, Colors.grey.shade400]
                                        : [skillColor, skillColor.withValues(alpha: 0.7)],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: isLocked ? null : [
                                    BoxShadow(
                                      color: skillColor.withValues(alpha: 0.4),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Stats row
                          Row(
                            children: [
                              _buildMiniStat(
                                'Accuracy',
                                '${(widget.skill.accuracy * 100).toStringAsFixed(0)}%',
                                skillColor,
                                isLocked,
                              ),
                              const SizedBox(width: 16),
                              _buildMiniStat(
                                'Attempts',
                                widget.skill.attempts.toString(),
                                Colors.blue,
                                isLocked,
                              ),
                              const SizedBox(width: 16),
                              // Difficulty stars
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < widget.skill.difficulty 
                                        ? Icons.star 
                                        : Icons.star_border,
                                    size: 14,
                                    color: isLocked 
                                        ? Colors.grey.shade400 
                                        : (i < widget.skill.difficulty 
                                            ? Colors.amber 
                                            : Colors.grey.shade300),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Right: Play button
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: isLocked
                            ? LinearGradient(
                                colors: [Colors.grey.shade300, Colors.grey.shade400],
                              )
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [skillColor, skillColor.withValues(alpha: 0.8)],
                              ),
                        shape: BoxShape.circle,
                        boxShadow: isLocked ? null : [
                          BoxShadow(
                            color: skillColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isLocked ? Icons.lock : Icons.play_arrow,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, bool isLocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isLocked ? Colors.grey : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isLocked ? Colors.grey : color,
          ),
        ),
      ],
    );
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
