import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/features/world_map/models/world_map_view_model.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// Presentation-only Quest Lens for the world map.
class WorldMapQuestLens extends StatelessWidget {
  final ZoneData selected;
  final WorldMapZoneStatus status;
  final ZoneStats stats;
  final double progress;
  final int rewardXp;
  final CosmeticItem? nextReward;
  final double rewardProgress;
  final String? rewardRequirement;
  final String? nextSkillName;
  final String moodText;
  final List<String> featureIcons;
  final List<String> featureTags;
  final bool isUnlocked;
  final bool compact;
  final double uiScale;
  final bool expanded;
  final bool isMoving;
  final bool isCurrentZone;
  final VoidCallback onToggleExpanded;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onRewardPreview;

  const WorldMapQuestLens({
    super.key,
    required this.selected,
    required this.status,
    required this.stats,
    required this.progress,
    required this.rewardXp,
    required this.nextReward,
    required this.rewardProgress,
    required this.rewardRequirement,
    required this.nextSkillName,
    required this.moodText,
    required this.featureIcons,
    required this.featureTags,
    required this.isUnlocked,
    required this.compact,
    required this.uiScale,
    required this.expanded,
    required this.isMoving,
    required this.isCurrentZone,
    required this.onToggleExpanded,
    required this.onPrimaryAction,
    required this.onRewardPreview,
  });

  @override
  Widget build(BuildContext context) {
    final width = compact ? 252.0 : 304.0;
    return Positioned(
      top: compact ? 92 : 112,
      right: compact ? 12 : 18,
      child: Transform.scale(
        alignment: Alignment.topRight,
        scale: uiScale,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: width, maxHeight: compact ? 392 : 610),
          child: Container(
            width: width,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: selected.color.withValues(alpha: 0.30), width: 1.8),
              boxShadow: AppShadows.md(selected.color),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 10),
                  _buildZoneHeader(context),
                  if (compact && !expanded) ...[
                    const SizedBox(height: 10),
                    _buildCompactSummary(context),
                  ],
                  if (!compact || expanded) ...[
                    const SizedBox(height: 8),
                    _buildExpandedDetails(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final stateColor = isUnlocked
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    return Row(
      children: [
        Icon(Icons.assignment_rounded, color: selected.color, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Quest Board',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
              color: selected.color,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: stateColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            status.label,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w900, color: stateColor),
          ),
        ),
        if (compact)
          IconButton(
            tooltip:
                expanded ? 'Collapse quest details' : 'Expand quest details',
            onPressed: onToggleExpanded,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            visualDensity: VisualDensity.compact,
            icon: Icon(expanded
                ? Icons.expand_less_rounded
                : Icons.expand_more_rounded),
          ),
      ],
    );
  }

  Widget _buildZoneHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: selected.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 36 : 44,
            height: compact ? 36 : 44,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(selected.emoji,
                    style: TextStyle(fontSize: compact ? 20 : 26))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              selected.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          if (!isUnlocked)
            Icon(Icons.lock,
                size: 15, color: Theme.of(context).colorScheme.onPrimary),
        ],
      ),
    );
  }

  Widget _buildCompactSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(status.reason,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text('Mastered ${stats.masteredSkills}/${stats.totalSkills} skills',
            style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          minHeight: 6,
          value: progress,
          borderRadius: BorderRadius.circular(999),
          valueColor: AlwaysStoppedAnimation<Color>(selected.color),
        ),
        const SizedBox(height: 8),
        Text(
          '+$rewardXp XP${nextReward == null ? '' : ' • ${nextReward!.name} next'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 11),
        ),
        const SizedBox(height: 10),
        _buildPrimaryAction(context),
      ],
    );
  }

  Widget _buildExpandedDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(selected.description,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text(moodText, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress,
            valueColor: AlwaysStoppedAnimation<Color>(selected.color),
          ),
        ),
        const SizedBox(height: 6),
        Text('Mastered ${stats.masteredSkills}/${stats.totalSkills} skills',
            style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 10),
        _buildReward(context),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: featureIcons
              .map(
                (icon) => Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selected.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(icon)),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: featureTags.map((tag) => Chip(label: Text(tag))).toList(),
        ),
        if (nextSkillName != null) ...[
          const SizedBox(height: 8),
          Text('Next skill: $nextSkillName',
              style: TextStyle(
                  color: selected.color, fontWeight: FontWeight.w800)),
        ],
        const SizedBox(height: 10),
        _buildPrimaryAction(context),
      ],
    );
  }

  Widget _buildReward(BuildContext context) {
    return Semantics(
      button: nextReward != null,
      label: nextReward == null
          ? 'Quest reward. Earn experience and discover new character items.'
          : 'Next reward ${nextReward!.name}. ${rewardRequirement ?? ''}',
      child: InkWell(
        onTap: nextReward == null ? null : onRewardPreview,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .tertiaryContainer
                .withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nextReward == null
                    ? '+$rewardXp XP • Keep building your streak'
                    : '+$rewardXp XP • ${rewardRequirement ?? nextReward!.name}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                minHeight: 6,
                value: rewardProgress,
                borderRadius: BorderRadius.circular(999),
                valueColor: AlwaysStoppedAnimation<Color>(selected.color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryAction(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isMoving ? null : onPrimaryAction,
        icon: Icon(isUnlocked ? Icons.rocket_launch : Icons.lock),
        label: Text(
          isUnlocked
              ? (isCurrentZone ? 'Enter Zone' : 'Travel Here')
              : 'Need ${selected.requiredStars} stars',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: selected.color,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }
}
