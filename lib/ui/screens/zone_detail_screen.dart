import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/themes/app_theme.dart';
import 'package:brightbound_adventures/ui/widgets/index.dart';
import 'package:brightbound_adventures/features/literacy/screens/skill_practice_screen.dart';
import 'package:brightbound_adventures/features/numeracy/screens/numeracy_practice_screen.dart';
import 'package:brightbound_adventures/features/storytelling/screens/story_practice_screen.dart';
import 'package:brightbound_adventures/features/logic/screens/logic_practice_screen.dart';
import 'package:brightbound_adventures/features/motor/screens/motor_practice_screen.dart';
import 'package:brightbound_adventures/features/science/screens/science_practice_screen.dart';
import 'package:brightbound_adventures/ui/screens/boss_battle_screen.dart';

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
  String _selectedFilter = 'all';
  String _selectedSort = 'recommended';

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
    final worldTokens = WorldTokens.fromZoneId(widget.zoneId);
    return Scaffold(
      backgroundColor: worldTokens.primaryColor.withValues(alpha: 0.06),
      appBar: AppBar(
        title: Text(widget.zoneName),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: worldTokens.headerGradient,
          ),
        ),
        backgroundColor: Colors.transparent,
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
          final filteredSkills = _applySkillFilter(zoneSkills);
          final sortedSkills = _sortSkills(filteredSkills);
          final recommendedSkill = _findRecommendedSkill(zoneSkills);

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
                    zoneId: widget.zoneId,
                    zoneName: widget.zoneName,
                    masteredSkills: zoneStats.masteredSkills,
                    totalSkills: zoneStats.totalSkills,
                    averageAccuracy: zoneStats.averageAccuracy,
                  ),
                ),
              ),

              // Breadcrumb strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: worldTokens.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: worldTokens.primaryColor.withValues(alpha: 0.2),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Image.asset('assets/images/logo.png',
                              fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right,
                            size: 16, color: Colors.black38),
                        const SizedBox(width: 4),
                        Text(
                          widget.zoneName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: worldTokens.primaryColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          worldTokens.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Image.asset('assets/images/questsandtasks.PNG',
                              fit: BoxFit.contain),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _buildZoneHeroCard(
                    context,
                    worldTokens,
                    zoneStats,
                    zoneSkills.length,
                  ),
                ),
              ),

              if (recommendedSkill != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: _buildRecommendedSkillCard(
                      context,
                      worldTokens,
                      recommendedSkill,
                    ),
                  ),
                ),

              // ── Boss Battle banner (Adventure Arena only) ──
              if (SkillProvider.normalizeZoneId(widget.zoneId) ==
                  'adventure_arena')
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        FadeSlidePageRoute(
                          page: const BossBattleScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1A2340),
                              Color(0xFF3B1F5E),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text('⚔️', style: TextStyle(fontSize: 40)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'BOSS BATTLE',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '10-question mixed gauntlet\nDefeat the Shadow Champion!',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.amber.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.amber
                                              .withValues(alpha: 0.4)),
                                    ),
                                    child: const Text(
                                      '75 Stars Reward ⭐',
                                      style: TextStyle(
                                          color: Colors.amber,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.white38, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Zone guardian NPC banner
              SliverToBoxAdapter(
                child: ZoneGuardianBanner(
                  zoneId: widget.zoneId,
                  themeColor: widget.zoneColor,
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
                          '${filteredSkills.length} Skills',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      PopupMenuButton<String>(
                        initialValue: _selectedFilter,
                        onSelected: (value) {
                          setState(() {
                            _selectedFilter = value;
                          });
                        },
                        tooltip: 'Filter skills',
                        icon: const Icon(Icons.filter_list_rounded),
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
                      PopupMenuButton<String>(
                        initialValue: _selectedSort,
                        onSelected: (value) {
                          setState(() {
                            _selectedSort = value;
                          });
                        },
                        tooltip: 'Sort skills',
                        icon: const Icon(Icons.sort_rounded),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'recommended',
                            child: Text('Recommended'),
                          ),
                          const PopupMenuItem(
                            value: 'progress',
                            child: Text('Progress'),
                          ),
                          const PopupMenuItem(
                            value: 'difficulty',
                            child: Text('Difficulty'),
                          ),
                          const PopupMenuItem(
                            value: 'attempts',
                            child: Text('Fewest Attempts'),
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
                sliver: sortedSkills.isEmpty
                    ? SliverToBoxAdapter(
                        child: _buildEmptyFilterCard(context, worldTokens),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final skill = sortedSkills[index];
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
                          childCount: sortedSkills.length,
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

  List<Skill> _applySkillFilter(List<Skill> skills) {
    switch (_selectedFilter) {
      case 'locked':
        return skills
            .where((skill) => skill.state == SkillState.locked)
            .toList(growable: false);
      case 'available':
        return skills
            .where((skill) => skill.state != SkillState.locked)
            .toList(growable: false);
      case 'mastered':
        return skills
            .where((skill) => skill.state == SkillState.mastered)
            .toList(growable: false);
      case 'all':
      default:
        return skills;
    }
  }

  List<Skill> _sortSkills(List<Skill> skills) {
    final sorted = List<Skill>.of(skills);
    sorted.sort((a, b) {
      final lockedCompare = _lockedSortRank(a).compareTo(_lockedSortRank(b));
      if (lockedCompare != 0) return lockedCompare;

      switch (_selectedSort) {
        case 'progress':
          final accuracyCompare = b.accuracy.compareTo(a.accuracy);
          if (accuracyCompare != 0) return accuracyCompare;
          return b.attempts.compareTo(a.attempts);
        case 'difficulty':
          final difficultyCompare = a.difficulty.compareTo(b.difficulty);
          if (difficultyCompare != 0) return difficultyCompare;
          return a.name.compareTo(b.name);
        case 'attempts':
          final attemptsCompare = a.attempts.compareTo(b.attempts);
          if (attemptsCompare != 0) return attemptsCompare;
          return a.accuracy.compareTo(b.accuracy);
        case 'recommended':
        default:
          final stateCompare = _learningSortRank(a).compareTo(
            _learningSortRank(b),
          );
          if (stateCompare != 0) return stateCompare;

          final attemptsCompare = a.attempts.compareTo(b.attempts);
          if (attemptsCompare != 0) return attemptsCompare;

          final accuracyCompare = a.accuracy.compareTo(b.accuracy);
          if (accuracyCompare != 0) return accuracyCompare;

          return a.difficulty.compareTo(b.difficulty);
      }
    });
    return sorted;
  }

  Skill? _findRecommendedSkill(List<Skill> skills) {
    final candidates = skills
        .where(
          (skill) =>
              skill.state != SkillState.locked &&
              skill.state != SkillState.mastered,
        )
        .toList();

    if (candidates.isEmpty) {
      final unlocked =
          skills.where((skill) => skill.state != SkillState.locked).toList();
      if (unlocked.isEmpty) return null;
      unlocked.sort((a, b) => a.name.compareTo(b.name));
      return unlocked.first;
    }

    candidates.sort((a, b) {
      final stateCompare = _learningSortRank(a).compareTo(_learningSortRank(b));
      if (stateCompare != 0) return stateCompare;

      final attemptsCompare = a.attempts.compareTo(b.attempts);
      if (attemptsCompare != 0) return attemptsCompare;

      final accuracyCompare = a.accuracy.compareTo(b.accuracy);
      if (accuracyCompare != 0) return accuracyCompare;

      return a.difficulty.compareTo(b.difficulty);
    });

    return candidates.first;
  }

  int _lockedSortRank(Skill skill) {
    return skill.state == SkillState.locked ? 1 : 0;
  }

  int _learningSortRank(Skill skill) {
    switch (skill.state) {
      case SkillState.introduced:
        return 0;
      case SkillState.practising:
        return 1;
      case SkillState.mastered:
        return 2;
      case SkillState.locked:
        return 3;
    }
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

  Widget _buildRecommendedSkillCard(
    BuildContext context,
    WorldTokens worldTokens,
    Skill skill,
  ) {
    final progressText = skill.attempts == 0
        ? 'New challenge'
        : '${(skill.accuracy * 100).toStringAsFixed(0)}% accuracy';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        final art = Container(
          width: isWide ? 118 : 88,
          height: isWide ? 118 : 88,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.32),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              skill.state == SkillState.mastered
                  ? 'assets/images/goldkey.PNG'
                  : 'assets/images/potion.PNG',
              fit: BoxFit.contain,
            ),
          ),
        );

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended Next',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              skill.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              skill.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                    height: 1.35,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildRecommendedBadge(
                  Icons.insights_rounded,
                  progressText,
                ),
                _buildRecommendedBadge(
                  Icons.repeat_rounded,
                  '${skill.attempts} attempts',
                ),
                _buildRecommendedBadge(
                  Icons.star_rounded,
                  'Level ${skill.difficulty}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _launchSkillPractice(context, skill),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Skill'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: worldTokens.primaryColor,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showSkillDetail(context, skill),
                  icon: const Icon(Icons.info_outline_rounded),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.72),
                      width: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                worldTokens.primaryColor,
                worldTokens.secondaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: worldTokens.primaryColor.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: isWide
              ? Row(
                  children: [
                    Expanded(child: content),
                    const SizedBox(width: 18),
                    art,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    art,
                    const SizedBox(height: 14),
                    content,
                  ],
                ),
        );
      },
    );
  }

  Widget _buildRecommendedBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterCard(
    BuildContext context,
    WorldTokens worldTokens,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: worldTokens.primaryColor.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.filter_alt_off_rounded,
            size: 42,
            color: worldTokens.primaryColor,
          ),
          const SizedBox(height: 10),
          Text(
            'No skills match this filter',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Try another view to keep exploring this zone.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedFilter = 'all';
              });
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Show All Skills'),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneHeroCard(
    BuildContext context,
    WorldTokens worldTokens,
    dynamic zoneStats,
    int totalSkills,
  ) {
    final mastered = zoneStats.masteredSkills as int;
    final averageAccuracy = zoneStats.averageAccuracy as double;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            worldTokens.primaryColor.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: worldTokens.primaryColor.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: worldTokens.primaryColor.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      worldTokens.primaryColor,
                      worldTokens.secondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    worldTokens.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.zoneName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: worldTokens.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.zoneDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildZoneBadge(
                icon: Icons.auto_graph_rounded,
                label: '$totalSkills skills',
                color: worldTokens.primaryColor,
              ),
              _buildZoneBadge(
                icon: Icons.emoji_events_rounded,
                label: '$mastered mastered',
                color: AppColors.reward,
              ),
              _buildZoneBadge(
                icon: Icons.insights_rounded,
                label:
                    '${(averageAccuracy * 100).toStringAsFixed(0)}% accuracy',
                color: AppColors.info,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: totalSkills > 0 ? mastered / totalSkills : 0,
              backgroundColor: worldTokens.primaryColor.withValues(alpha: 0.10),
              valueColor:
                  AlwaysStoppedAnimation<Color>(worldTokens.primaryColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Progress is saved locally and your next challenge gets smarter as you improve.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryGuideline(BuildContext context, Skill skill) {
    final nextState = skill.getNextState();
    final nextStateText = switch (nextState) {
      SkillState.introduced => 'Reach 60% accuracy to practise',
      SkillState.practising => 'Reach 80% accuracy to master',
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
    final zoneId = SkillProvider.normalizeZoneId(widget.zoneId);
    final zoneColor = WorldTokens.fromZoneId(zoneId).primaryColor;

    if (zoneId == 'number_nebula' || zoneId == 'math_facts') {
      practiceScreen = NumeracyPracticeScreen(
        skill: skill,
        themeColor: zoneColor,
        zoneId: zoneId,
        zoneName: widget.zoneName,
      );
    } else if (zoneId == 'story_springs') {
      practiceScreen = StoryPracticeScreen(
        skillId: skill.id,
        skillName: skill.name,
        zoneId: zoneId,
        zoneName: widget.zoneName,
      );
    } else if (zoneId == 'puzzle_peaks') {
      practiceScreen = LogicPracticeScreen(
        skillId: skill.id,
        skillName: skill.name,
        zoneId: zoneId,
        zoneName: widget.zoneName,
      );
    } else if (zoneId == 'adventure_arena') {
      practiceScreen = MotorPracticeScreen(
        skillId: skill.id,
        skillName: skill.name,
        zoneId: zoneId,
        zoneName: widget.zoneName,
      );
    } else if (zoneId == 'science_explorers') {
      practiceScreen = SciencePracticeScreen(
        skillId: skill.id,
        skillName: skill.name,
        zoneId: zoneId,
        zoneName: widget.zoneName,
      );
    } else {
      // Word Woods and Creative Corner both use the literacy-style quiz shell.
      practiceScreen = SkillPracticeScreen(
        skill: skill,
        themeColor: zoneColor,
        zoneId: zoneId,
        zoneName: widget.zoneName,
      );
    }

    Navigator.push(
      context,
      FadeSlidePageRoute(page: practiceScreen),
    );
  }
}
