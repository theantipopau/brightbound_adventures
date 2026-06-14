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

class _SkillCardState extends State<SkillCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
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
      case SkillState.locked:
        return Colors.grey;
    }
  }

  String _getSkillEmoji() {
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
    if (name.contains('count') || name.contains('number')) return '🔢';
    if (name.contains('pattern')) return '🧩';
    if (name.contains('science')) return '🔬';
    return '⭐';
  }

  String _getStateLabel() {
    switch (widget.skill.state) {
      case SkillState.mastered:
        return 'Mastered';
      case SkillState.practising:
        return 'Practising';
      case SkillState.introduced:
        return 'Ready';
      case SkillState.locked:
        return 'Locked';
    }
  }

  String _getStateAsset() {
    switch (widget.skill.state) {
      case SkillState.mastered:
        return 'assets/images/goldkey.PNG';
      case SkillState.practising:
        return 'assets/images/scroll.PNG';
      case SkillState.introduced:
        return 'assets/images/potion.PNG';
      case SkillState.locked:
        return 'assets/images/chest_closed.PNG';
    }
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
        duration: AppMotion.fast,
        transform: Matrix4.diagonal3Values(
          _isHovered && !isLocked ? 1.018 : 1.0,
          _isHovered && !isLocked ? 1.018 : 1.0,
          1.0,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLocked
                ? [Colors.grey.shade100, Colors.grey.shade200]
                : [
                    Colors.white,
                    skillColor.withValues(alpha: 0.045),
                    skillColor.withValues(alpha: 0.085),
                  ],
            stops: isLocked ? null : const [0, 0.62, 1],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isLocked
                ? Colors.grey.shade300
                : skillColor.withValues(alpha: _isHovered ? 0.58 : 0.28),
            width: _isHovered ? 2.4 : 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: isLocked
                  ? Colors.black.withValues(alpha: 0.05)
                  : skillColor.withValues(alpha: _isHovered ? 0.28 : 0.14),
              blurRadius: _isHovered ? 22 : 14,
              offset: const Offset(0, 7),
              spreadRadius: _isHovered ? 1 : 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                top: -10,
                right: -8,
                child: Opacity(
                  opacity: isLocked ? 0.06 : 0.10,
                  child: SizedBox(
                    width: 82,
                    height: 82,
                    child: Image.asset(_getStateAsset(), fit: BoxFit.contain),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLocked ? null : widget.onTap,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildSkillIcon(skillColor, emoji, isLocked),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSkillBody(context, skillColor, isLocked),
                        ),
                        const SizedBox(width: 10),
                        _buildActionButton(skillColor, isLocked),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillIcon(Color skillColor, String emoji, bool isLocked) {
    return AnimatedBuilder(
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
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.58),
              width: 1.5,
            ),
            boxShadow: isLocked
                ? null
                : [
                    BoxShadow(
                      color: skillColor.withValues(alpha: 0.28),
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
    );
  }

  Widget _buildSkillBody(
    BuildContext context,
    Color skillColor,
    bool isLocked,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: skillColor.withValues(alpha: isLocked ? 0.08 : 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: skillColor.withValues(alpha: isLocked ? 0.10 : 0.22),
            ),
          ),
          child: Text(
            _getStateLabel(),
            style: TextStyle(
              color: isLocked ? Colors.grey : skillColor,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              fontFamily: AppTheme.fontPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.skill.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: isLocked ? Colors.grey : AppColors.textPrimary,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          widget.skill.description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isLocked ? Colors.grey : AppColors.textSecondary,
                height: 1.28,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: widget.skill.accuracy.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              isLocked ? Colors.grey.shade400 : skillColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildMiniStat(
              'Accuracy',
              '${(widget.skill.accuracy * 100).toStringAsFixed(0)}%',
              skillColor,
              isLocked,
            ),
            _buildMiniStat(
              'Attempts',
              widget.skill.attempts.toString(),
              Colors.blue,
              isLocked,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                return Icon(
                  i < widget.skill.difficulty ? Icons.star : Icons.star_border,
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
    );
  }

  Widget _buildActionButton(Color skillColor, bool isLocked) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: isLocked
            ? LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade400])
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [skillColor, skillColor.withValues(alpha: 0.8)],
              ),
        shape: BoxShape.circle,
        boxShadow: isLocked
            ? null
            : [
                BoxShadow(
                  color: skillColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Icon(
        isLocked ? Icons.lock : Icons.play_arrow_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildMiniStat(
      String label, String value, Color color, bool isLocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isLocked ? Colors.grey : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: isLocked ? Colors.grey : color,
            fontFamily: AppTheme.fontPrimary,
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
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: BrightBoundGraphics.buildProgressRing(
                progress: total > 0 ? (mastered + practising) / total : 0,
                size: 140,
                backgroundColor: AppColors.primary,
                progressColor: AppColors.success,
                centerText:
                    '${((mastered + practising) / (total > 0 ? total : 1) * 100).toStringAsFixed(0)}%',
                textStyle: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 20),
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
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ZoneProgressCard extends StatelessWidget {
  final String? zoneId;
  final String zoneName;
  final int masteredSkills;
  final int totalSkills;
  final double averageAccuracy;
  final VoidCallback? onTap;

  const ZoneProgressCard({
    super.key,
    this.zoneId,
    required this.zoneName,
    required this.masteredSkills,
    required this.totalSkills,
    required this.averageAccuracy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completionPercentage =
        totalSkills > 0 ? (masteredSkills / totalSkills) * 100 : 0;
    final world = WorldTokens.fromZoneId(zoneId ?? zoneName);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                world.primaryColor.withValues(alpha: 0.055),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: world.primaryColor.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: Image.asset(
                      'assets/images/questsandtasks.PNG',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      zoneName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  Text(
                    '${completionPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: world.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: AppTheme.fontPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$masteredSkills/$totalSkills mastered',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    '${(averageAccuracy * 100).toStringAsFixed(0)}% average accuracy',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: completionPercentage / 100,
                  minHeight: 9,
                  backgroundColor: world.primaryColor.withValues(alpha: 0.10),
                  valueColor: AlwaysStoppedAnimation(world.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
