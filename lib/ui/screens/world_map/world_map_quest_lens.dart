import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/features/world_map/models/world_map_view_model.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/juicy_button.dart';

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

  /// Acknowledges what already happened here (e.g. "You finished a quest
  /// here today"), derived from persisted session history. Null hides it.
  final String? recentNote;
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
    this.recentNote,
    required this.onToggleExpanded,
    required this.onPrimaryAction,
    required this.onRewardPreview,
  });

  @override
  Widget build(BuildContext context) {
    // Wide only: on compact layouts the screen renders
    // [WorldMapCompactBottomSheet] instead, so the map itself stays
    // visible and details open as a bottom sheet. `compact` is still
    // supported here for the presentation test + bottom-sheet content.
    final width = compact ? 224.0 : 304.0;
    return Positioned(
      top: compact ? 92 : 112,
      right: compact ? 12 : 18,
      child: Transform.scale(
        alignment: Alignment.topRight,
        scale: uiScale,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: width, maxHeight: compact ? 340 : 610),
          child: buildCard(context),
        ),
      ),
    );
  }

  /// The lens card without any positioning — reused by the compact bottom
  /// sheet. Pass [expanded] to override the widget's flag (the sheet
  /// always shows full details).
  Widget buildCard(BuildContext context, {bool? expanded}) {
    final showExpanded = expanded ?? this.expanded;
    final width = compact ? 224.0 : 304.0;
    return Container(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 10),
            _buildZoneHeader(context),
            if (compact && !showExpanded) ...[
              const SizedBox(height: 10),
              _buildCompactSummary(context),
            ],
            if (!compact || showExpanded) ...[
              const SizedBox(height: 8),
              _buildExpandedDetails(context),
            ],
          ],
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
        // Flexible with a lower effective priority than the status chip:
        // "Quest Board" is a decorative eyebrow label, status.label (e.g.
        // "Recommended"/"Mastered") is the information that actually
        // matters. At 200% text scale the chip's own text roughly doubles
        // in width; previously only this label was flexible; the chip
        // (was a fixed-size Container) and the icon button were not, so
        // when the chip alone needed more room than was left the whole
        // Row overflowed by ~80px regardless of how far this label
        // shrank. Both are Flexible now.
        // Compact (252px lens): the eyebrow is dropped entirely so the
        // status chip + chevron get the room — 'Quest Board' + chip
        // ellipsized to 'Quest B…' next to a squeezed chip at 390px.
        if (!compact)
          Flexible(
            flex: 2,
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
        const SizedBox(width: 6),
        Flexible(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w900, color: stateColor),
            ),
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
        if (recentNote != null) ...[
          _buildRecentNote(context),
          const SizedBox(height: 8),
        ],
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
        if (recentNote != null) ...[
          const SizedBox(height: 8),
          _buildRecentNote(context),
        ],
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

  Widget _buildRecentNote(BuildContext context) {
    return Semantics(
      label: recentNote,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected.color.withValues(alpha: 0.3)),
        ),
        child: Text(
          recentNote!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
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

/// Fused bottom sheet for compact (phone) layouts: quest summary +
/// action dock in ONE card.
///
/// Replaces the two stacked floating cards (a 64px quest bar at bottom:100
/// plus the action dock at bottom:16, ~164px combined with two paddings,
/// two shadows, and a dead gap). One card with a divider costs ~137px,
/// hands ~19px of breathing room back to the islands (see the compact
/// `bottomUIReserve`), and keeps every contract: the quest section keeps
/// the `compact-quest-bar` key and the `Quest details` tooltip (tests),
/// the actions strip keeps the `action-dock` key (overlap net), and full
/// details still open as a modal bottom sheet via [onExpand].
class WorldMapCompactBottomSheet extends StatelessWidget {
  final ZoneData selected;
  final WorldMapZoneStatus status;
  final ZoneStats stats;
  final bool isUnlocked;
  final bool isCurrentZone;
  final bool isMoving;
  final double uiScale;
  final ZoneData recommendedZone;
  final bool recommendShimmer;
  final VoidCallback onPrimaryAction;
  final VoidCallback onExpand;
  final VoidCallback onNextQuest;
  final VoidCallback onDaily;
  final VoidCallback onMiniGames;
  final VoidCallback onShop;
  final VoidCallback onAchievements;

  const WorldMapCompactBottomSheet({
    super.key,
    required this.selected,
    required this.status,
    required this.stats,
    required this.isUnlocked,
    required this.isCurrentZone,
    required this.isMoving,
    required this.uiScale,
    required this.recommendedZone,
    required this.recommendShimmer,
    required this.onPrimaryAction,
    required this.onExpand,
    required this.onNextQuest,
    required this.onDaily,
    required this.onMiniGames,
    required this.onShop,
    required this.onAchievements,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final actionLabel = !isUnlocked
        ? 'Locked'
        : (isCurrentZone ? 'Enter' : 'Go');
    // Fixed section heights keep the island safe-field math exact at every
    // text scale: a free-height bar once grew to ~87px at 200% and
    // overlapped the bottom-row islands by ~2px. Quest text is capped at
    // 1.3x so it always fits (full-scale text lives one tap away in the
    // details sheet); dock buttons keep full scale and shrink their own
    // labels instead of overflowing (see JuicyButton).
    final chromeScaler = MediaQuery.textScalerOf(context)
        .scale(1.0)
        .clamp(1.0, 1.3);
    // Slim padding: the JuicyButton default 28px horizontal padding left
    // 'Achievements' exactly its content width and clipped it to
    // 'My Achieve…' (same fix as the old standalone dock).
    const dockPad = EdgeInsets.symmetric(horizontal: 14, vertical: 0);
    Widget dockAction({
      required String label,
      required String emoji,
      required Color color,
      required VoidCallback onTap,
      bool shimmer = false,
    }) =>
        JuicyButton(
          label: label,
          emoji: emoji,
          width: null,
          height: 56,
          fontSize: 14,
          padding: dockPad,
          color: color,
          shimmer: shimmer,
          onPressed: onTap,
        );
    // Card footprint: 6 + 56 + 9 + 56 + 10 = ~137px, plus bottom:16.
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Transform.scale(
        alignment: Alignment.bottomCenter,
        scale: uiScale,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: selected.color.withValues(alpha: 0.35), width: 1.6),
            boxShadow: AppShadows.md(selected.color),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                key: const ValueKey('compact-quest-bar'),
                height: 56,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(chromeScaler),
                  ),
                  child: Semantics(
                    button: true,
                    label:
                        '${selected.name}, ${status.label}, mastered ${stats.masteredSkills} of ${stats.totalSkills} skills. Activate for quest details.',
                    child: GestureDetector(
                      onTap: onExpand,
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: selected.color,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                                child: Text(selected.emoji,
                                    style:
                                        const TextStyle(fontSize: 19))),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  selected.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    height: 1.15,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                Text(
                                  isUnlocked
                                      ? '${status.label} • ${stats.masteredSkills}/${stats.totalSkills}'
                                      : '${selected.requiredStars}⭐ to unlock',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.72),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton(
                            onPressed: isMoving ? null : onPrimaryAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selected.color,
                              foregroundColor: scheme.onPrimary,
                              minimumSize: const Size(64, 40),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(actionLabel),
                          ),
                          IconButton(
                            tooltip: 'Quest details',
                            onPressed: onExpand,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 36, minHeight: 36),
                            visualDensity: VisualDensity.compact,
                            icon:
                                const Icon(Icons.expand_less_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                height: 9,
                thickness: 1,
                color: scheme.onSurface.withValues(alpha: 0.10),
              ),
              SizedBox(
                key: const ValueKey('action-dock'),
                height: 56,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text('▶ Play',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textSecondary)),
                      ),
                      dockAction(
                        label: 'Next\nQuest',
                        emoji: recommendedZone.emoji,
                        color: recommendedZone.color,
                        shimmer: recommendShimmer,
                        onTap: onNextQuest,
                      ),
                      const SizedBox(width: 8),
                      dockAction(
                        label: 'Daily\nChallenge',
                        emoji: '🎯',
                        color: Colors.orange,
                        shimmer: true,
                        onTap: onDaily,
                      ),
                      const SizedBox(width: 8),
                      dockAction(
                        label: 'Mini\nGames',
                        emoji: '🎮',
                        color: AppColors.secondary,
                        onTap: onMiniGames,
                      ),
                      const SizedBox(width: 8),
                      dockAction(
                        label: 'Star\nShop',
                        emoji: '🛍️',
                        color: Colors.teal,
                        onTap: onShop,
                      ),
                      const SizedBox(width: 8),
                      dockAction(
                        label: 'My\nAchievements',
                        emoji: '🏆',
                        color: AppColors.reward,
                        onTap: onAchievements,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
