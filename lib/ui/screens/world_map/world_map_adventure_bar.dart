import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/animated_score_counter.dart';

/// Presentation-only Adventure Bar for the world map.
///
/// The parent owns providers, navigation, and world-map state. This widget
/// renders the supplied snapshot and raises user intent through callbacks.
class WorldMapAdventureBar extends StatelessWidget {
  final Avatar avatar;
  final int totalStars;
  final int streak;
  final int dailyCompleted;
  final int dailyTotal;
  final int reviewDue;
  final bool compact;
  final double uiScale;
  final VoidCallback onAvatarInfo;
  final VoidCallback onAvatarCreator;
  final VoidCallback onAppInfo;
  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final VoidCallback onParentDashboard;
  final VoidCallback onDailyChallenges;
  final VoidCallback onMiniGames;
  final VoidCallback onShop;
  final VoidCallback onAchievements;

  const WorldMapAdventureBar({
    super.key,
    required this.avatar,
    required this.totalStars,
    required this.streak,
    required this.dailyCompleted,
    required this.dailyTotal,
    required this.reviewDue,
    required this.compact,
    required this.uiScale,
    required this.onAvatarInfo,
    required this.onAvatarCreator,
    required this.onAppInfo,
    required this.onProfile,
    required this.onSettings,
    required this.onParentDashboard,
    required this.onDailyChallenges,
    required this.onMiniGames,
    required this.onShop,
    required this.onAchievements,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact(context);
    return _buildExpanded(context);
  }

  Widget _buildExpanded(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final hudButtonSize = 40.0;
    final hudIconSize = 22.0;
    final hudButtonGap = 8.0;
    final hudRightMargin = 12.0;

    return _positioned(
      context,
      top: 16,
      child: Row(
        children: [
          _identity(context, compact: false),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _circleAction(
                context,
                tooltip: 'My Profile',
                icon: Icons.person_rounded,
                color: theme.colorScheme.primary,
                size: hudButtonSize,
                iconSize: hudIconSize,
                margin: hudButtonGap,
                onTap: onProfile,
              ),
              _circleAction(
                context,
                tooltip: 'Settings',
                icon: Icons.settings_rounded,
                color: semantic.textSecondary,
                size: hudButtonSize,
                iconSize: 20,
                margin: hudButtonGap,
                onTap: onSettings,
              ),
              _circleAction(
                context,
                tooltip: 'Parent Dashboard',
                icon: Icons.supervised_user_circle_rounded,
                color: Theme.of(context).colorScheme.secondary,
                size: hudButtonSize,
                iconSize: hudIconSize,
                margin: hudRightMargin,
                onTap: onParentDashboard,
              ),
            ],
          ),
          _expandedStats(context),
          _avatarShortcut(context),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return _positioned(
      context,
      top: 8,
      left: 10,
      right: 10,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primary.withValues(alpha: 0.24)),
          boxShadow: AppShadows.md(primary),
        ),
        child: Row(
          children: [
            Expanded(child: _identity(context, compact: true)),
            _buildCompactStat(context, '⭐', '$totalStars', 'Stars'),
            if (streak > 0) _buildCompactStat(context, '🔥', '$streak', 'Days'),
            PopupMenuButton<String>(
              tooltip: 'Adventure menu',
              onSelected: _selectMenuAction,
              icon: const Icon(Icons.menu_rounded),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person_rounded),
                    title: Text('My profile'),
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings_rounded),
                    title: Text('Settings'),
                  ),
                ),
                PopupMenuItem(
                  value: 'parent',
                  child: ListTile(
                    leading: Icon(Icons.supervised_user_circle_rounded),
                    title: Text('Parent dashboard'),
                  ),
                ),
                PopupMenuItem(
                  value: 'daily',
                  child: ListTile(
                    leading: Icon(Icons.track_changes_rounded),
                    title: Text('Daily challenges'),
                  ),
                ),
                PopupMenuItem(
                  value: 'mini_games',
                  child: ListTile(
                    leading: Icon(Icons.sports_esports_rounded),
                    title: Text('Mini-games'),
                  ),
                ),
                PopupMenuItem(
                  value: 'shop',
                  child: ListTile(
                    leading: Icon(Icons.shopping_bag_rounded),
                    title: Text('Star Shop'),
                  ),
                ),
                PopupMenuItem(
                  value: 'achievements',
                  child: ListTile(
                    leading: Icon(Icons.emoji_events_rounded),
                    title: Text('Achievements'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _positioned(
    BuildContext context, {
    required double top,
    double left = 16,
    double right = 16,
    required Widget child,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Transform.scale(
        alignment: Alignment.topCenter,
        scale: uiScale,
        child: child,
      ),
    );
  }

  Widget _identity(BuildContext context, {required bool compact}) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    return Semantics(
      button: true,
      label:
          '${avatar.name}, level ${avatar.level}, ${avatar.experiencePoints} experience points',
      child: GestureDetector(
        onTap: onAvatarInfo,
        child: Container(
          width: compact ? null : 248,
          height: compact ? 48 : 58,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                theme.colorScheme.primary.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(compact ? 999 : 20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.24),
              width: 1.5,
            ),
            boxShadow: AppShadows.md(theme.colorScheme.primary),
          ),
          child: Row(
            mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Hero(
                tag: compact ? 'compact_app_logo' : 'app_logo',
                child: CircleAvatar(
                  radius: compact ? 19 : 22,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    CompanionCatalog.emojiFor(avatar.baseCharacter),
                    style: TextStyle(fontSize: compact ? 19 : 22),
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        avatar.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyLarge.copyWith(
                          color: semantic.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Lv ${avatar.level} • ${avatar.experiencePoints} XP',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: semantic.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'About BrightBound',
                  child: IconButton(
                    onPressed: onAppInfo,
                    tooltip: 'About BrightBound',
                    icon: Icon(
                      Icons.auto_awesome_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ] else
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      avatar.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
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

  Widget _expandedStats(BuildContext context) {
    final semantic = context.semanticColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScoreCounter(
          value: totalStars,
          label: 'Stars',
          emoji: '⭐',
          color: semantic.reward,
        ),
        if (streak > 0) ...[
          const SizedBox(width: 12),
          AnimatedScoreCounter(
            value: streak,
            label: 'Days',
            emoji: '🔥',
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ],
        const SizedBox(width: 12),
        _dailyBadge(context),
        if (reviewDue > 0) _reviewBadge(context),
      ],
    );
  }

  Widget _buildCompactStat(
    BuildContext context,
    String icon,
    String value,
    String label,
  ) {
    return Tooltip(
      message: '$value $label',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          '$icon $value',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _dailyBadge(BuildContext context) {
    final complete = dailyTotal > 0 && dailyCompleted == dailyTotal;
    return Tooltip(
      message: 'Daily Challenges',
      child: GestureDetector(
        onTap: onDailyChallenges,
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: complete
                ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.20)
                : Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: complete
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.30),
            ),
          ),
          child: Text(
            complete ? '🏆 Quest complete' : '🎯 $dailyCompleted/$dailyTotal',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _reviewBadge(BuildContext context) {
    return Tooltip(
      message: '$reviewDue skill${reviewDue == 1 ? '' : 's'} due for review',
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
        ),
        child: Text(
          '🔁 $reviewDue',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _circleAction(
    BuildContext context, {
    required String tooltip,
    required IconData icon,
    required Color color,
    required double size,
    required double iconSize,
    required double margin,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            margin: EdgeInsets.only(right: margin),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              boxShadow: AppShadows.sm(color),
            ),
            child: Icon(icon, size: iconSize, color: color),
          ),
        ),
      ),
    );
  }

  Widget _avatarShortcut(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onAvatarCreator,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: AppShadows.md(theme.colorScheme.primary),
          border: Border.all(color: theme.colorScheme.primary, width: 2),
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            CompanionCatalog.emojiFor(avatar.baseCharacter),
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  void _selectMenuAction(String action) {
    switch (action) {
      case 'profile':
        onProfile();
        break;
      case 'settings':
        onSettings();
        break;
      case 'parent':
        onParentDashboard();
        break;
      case 'daily':
        onDailyChallenges();
        break;
      case 'mini_games':
        onMiniGames();
        break;
      case 'shop':
        onShop();
        break;
      case 'achievements':
        onAchievements();
        break;
    }
  }
}
