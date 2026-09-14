import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/features/world_map/models/world_map_view_model.dart';
import '../themes/index.dart';
import '../widgets/xp_widgets.dart';

/// Player-facing progress profile.
///
/// Reads exclusively from the app's canonical, provider-owned progression
/// sources (AvatarProvider, SkillProvider, ShopService, StreakService,
/// QuestSessionHistoryService) — not the legacy `StatsService`/`PlayerStats`
/// model, which nothing in the app ever writes to and which therefore
/// always showed a fresh, all-zero record regardless of real play. See
/// docs/PROMPT_MD_EXECUTION_TRACKER.md for the root-cause investigation.
class ProfileStatsScreen extends StatefulWidget {
  const ProfileStatsScreen({super.key});

  @override
  State<ProfileStatsScreen> createState() => _ProfileStatsScreenState();
}

class _ProfileStatsScreenState extends State<ProfileStatsScreen> {
  bool _loading = true;
  bool _hydrationFailed = false;

  @override
  void initState() {
    super.initState();
    // Deferred to a microtask rather than called directly: SkillProvider
    // .initializeSkills() calls notifyListeners() synchronously before its
    // first `await`, and triggering that during this widget's own initial
    // build (i.e. calling it straight from initState) throws "setState()
    // or markNeedsBuild() called during build" — the provider tree is
    // still mid-build at that point. Deferring lets the current frame
    // finish building first.
    Future.microtask(_hydrate);
  }

  /// SkillProvider and QuestSessionHistoryService are lazily initialised on
  /// first use elsewhere in the app (e.g. entering a zone) — Profile can be
  /// the first screen a session opens, so it must not assume either is
  /// already hydrated. Both guard their own re-entrancy, so calling them
  /// again here is safe even if the world map already triggered it.
  Future<void> _hydrate() async {
    try {
      // Read both providers before any `await` so no read happens across an
      // async gap.
      final skillProvider = context.read<SkillProvider>();
      final questHistory = context.read<QuestSessionHistoryService>();

      if (!skillProvider.isInitialized) {
        await skillProvider.initializeSkills();
      }
      if (!questHistory.initialized) {
        await questHistory.initialize();
      }

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      debugPrint('ProfileStatsScreen: hydration failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hydrationFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarProvider = context.watch<AvatarProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(avatarProvider.avatar),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : !avatarProvider.hasAvatar
                        ? _buildEmptyState()
                        : _hydrationFailed
                            ? _buildErrorState()
                            : _buildContent(context, avatarProvider.avatar!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Avatar? avatar) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
          ),
          if (avatar != null) ...[
            Text(
              CompanionCatalog.emojiFor(avatar.baseCharacter),
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              avatar != null ? '${avatar.name}\'s Progress' : 'Your Progress',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'No progress yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an avatar and finish a quest to start building your progress story.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.textSecondary,
                  size: 40,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Couldn\'t load your progress',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Something went wrong loading your stats. You can try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _loading = true);
                    _hydrate();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Avatar avatar) {
    final skillProvider = context.watch<SkillProvider>();
    final shop = context.watch<ShopService>();
    final streak = context.watch<StreakService>();
    final questHistory = context.watch<QuestSessionHistoryService>();

    const viewModel = WorldMapViewModel(zones: ZoneCatalog.zones);
    final totalStars = viewModel.calculateTotalStars(skillProvider);
    final recommendedIndex =
        viewModel.recommendedZoneIndex(0, totalStars, skillProvider);
    final progression = skillProvider.getProgressionStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLevelCard(avatar),
          const SizedBox(height: 16),
          _buildStatsGrid(
            stars: shop.starBalance,
            questsCompleted: questHistory.sessions.length,
            currentStreak: streak.currentStreak,
            skillsMastered: progression.mastered,
            totalSkills: progression.totalSkills,
          ),
          const SizedBox(height: 16),
          _buildZoneProgress(
            viewModel: viewModel,
            skillProvider: skillProvider,
            totalStars: totalStars,
            recommendedIndex: recommendedIndex,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLevelCard(Avatar avatar) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade700,
            Colors.blue.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Level',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              LevelBadge(level: avatar.level, size: 60),
            ],
          ),
          const SizedBox(height: 24),
          XpBar(
            currentLevel: avatar.level,
            currentLevelXp: avatar.experiencePoints,
            xpNeeded: avatar.nextLevelXP,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid({
    required int stars,
    required int questsCompleted,
    required int currentStreak,
    required int skillsMastered,
    required int totalSkills,
  }) {
    // A fixed-aspect-ratio grid forces every card to one pixel height
    // regardless of content — that overflowed as soon as a label needed two
    // lines (e.g. "Quests Completed", "Skills Mastered") and will overflow
    // again at larger text scales no matter how the fixed ratio is tuned.
    // A Wrap of content-sized cards has no such ceiling: each card grows
    // with its own text instead of being clipped or forced to fit.
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final cardWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: '⭐',
                label: 'Stars',
                value: stars.toString(),
                color: Colors.amber,
                semanticLabel: '$stars stars',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: '🎯',
                label: 'Quests Completed',
                value: questsCompleted.toString(),
                color: Colors.green,
                semanticLabel: '$questsCompleted quests completed',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: '🔥',
                label: 'Day Streak',
                value: currentStreak.toString(),
                color: Colors.orange,
                semanticLabel: '$currentStreak day streak',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: '🏅',
                label: 'Skills Mastered',
                value: '$skillsMastered/$totalSkills',
                color: Colors.blue,
                semanticLabel:
                    '$skillsMastered of $totalSkills skills mastered',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
    required String semanticLabel,
  }) {
    return Semantics(
      label: '$label: $semanticLabel',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 96),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneProgress({
    required WorldMapViewModel viewModel,
    required SkillProvider skillProvider,
    required int totalStars,
    required int recommendedIndex,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zone Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < viewModel.zones.length; i++)
            _buildZoneRow(
              zone: viewModel.zones[i],
              status: viewModel.evaluateZoneState(
                zoneIndex: i,
                totalStars: totalStars,
                skillProvider: skillProvider,
                recommendedZoneIndex: recommendedIndex,
              ),
              stats: skillProvider.getZoneStats(viewModel.zones[i].skillZoneId),
            ),
        ],
      ),
    );
  }

  Widget _buildZoneRow({
    required ZoneData zone,
    required WorldMapZoneStatus status,
    required ZoneStats stats,
  }) {
    final locked = status.state == WorldMapZoneState.locked;
    final progress = locked || stats.totalSkills == 0
        ? 0.0
        : (stats.masteredSkills / stats.totalSkills).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Semantics(
        label: '${zone.name}: ${status.label}. ${status.reason}',
        excludeSemantics: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(zone.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Flexible + ellipsis: the longest zone names
                      // ("Science Explorers") combined with the longest
                      // status chip label ("Recommended") do not both fit
                      // at narrow portrait widths otherwise.
                      Flexible(
                        child: Text(
                          zone.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(status.state, status.label),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status.reason,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        locked ? Colors.grey.shade400 : zone.color,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(WorldMapZoneState state, String label) {
    final IconData icon;
    final Color color;
    switch (state) {
      case WorldMapZoneState.locked:
        icon = Icons.lock_rounded;
        color = Colors.grey.shade500;
        break;
      case WorldMapZoneState.available:
        icon = Icons.explore_rounded;
        color = Colors.blueGrey;
        break;
      case WorldMapZoneState.recommended:
        icon = Icons.star_rounded;
        color = Colors.deepPurple;
        break;
      case WorldMapZoneState.inProgress:
        icon = Icons.trending_up_rounded;
        color = Colors.teal;
        break;
      case WorldMapZoneState.needsReview:
        icon = Icons.refresh_rounded;
        color = Colors.orange;
        break;
      case WorldMapZoneState.bossReady:
        icon = Icons.shield_rounded;
        color = Colors.redAccent;
        break;
      case WorldMapZoneState.mastered:
        icon = Icons.emoji_events_rounded;
        color = Colors.amber.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
