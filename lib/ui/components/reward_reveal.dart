import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/audio_manager.dart';
import 'package:brightbound_adventures/core/services/reward_transaction_service.dart';
import 'package:brightbound_adventures/features/world_map/services/recommendation_service.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/reward_animations.dart';

/// The one choreographed reward moment for a completed quest.
///
/// Consumes an already-persisted [RewardResult] from
/// `RewardTransactionService` — it never awards anything itself, so replaying
/// a result screen (rebuild, resume, revisit) shows the same numbers without
/// re-earning them.
///
/// The sequence, in order, is: session stars → star balance → XP and level
/// → unlocks queued one at a time → skill/mastery movement → what to do
/// next. Under reduced motion the same information appears immediately as
/// static, fully-populated content: the reveal carries information, so it
/// collapses rather than disappears.
class RewardReveal extends StatefulWidget {
  const RewardReveal({
    super.key,
    required this.result,
    required this.breakdown,
    required this.starBalance,
    required this.levelProgressBefore,
    required this.levelProgressAfter,
    this.accent,
    this.skillName,
    this.skillAccuracyBefore,
    this.skillAccuracyAfter,
    this.recommendation,
    this.unlockNames = const <String>[],
    this.onBackToMap,
    this.onRevealComplete,
  });

  /// The persisted outcome of this completion.
  final RewardResult result;

  /// Why the XP is what it is.
  final RewardBreakdown breakdown;

  /// Player's star balance *after* the award.
  final int starBalance;

  /// Level progress (0–1) immediately before and after this award.
  final double levelProgressBefore;
  final double levelProgressAfter;

  /// Zone/brand accent for the card.
  final Color? accent;

  final String? skillName;
  final double? skillAccuracyBefore;
  final double? skillAccuracyAfter;

  /// The recommended next activity, shown as the closing card.
  final QuestRecommendation? recommendation;

  /// Friendly names for achievement/cosmetic unlocks, queued one at a time.
  final List<String> unlockNames;

  /// Returns the player to the living world map.
  final VoidCallback? onBackToMap;

  /// Fired once the choreography has finished (for audio/TTS hooks).
  final VoidCallback? onRevealComplete;

  @override
  State<RewardReveal> createState() => _RewardRevealState();
}

class _RewardRevealState extends State<RewardReveal>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  bool _started = false;

  /// Choreography windows, as fractions of the total celebration duration.
  static const _starsWindow = (0.00, 0.34);
  static const _xpWindow = (0.34, 0.72);
  static const _unlocksWindow = (0.72, 1.00);

  /// Motion tokens resolve through `MediaQuery`, so they can only be read
  /// from `didChangeDependencies` — reading them in `initState` throws.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final tokens = MotionTokens.of(context);
    final controller = AnimationController(
      vsync: this,
      duration: tokens.celebration,
    );
    _controller = controller;

    // A4: the reveal's two headline moments get their own sound — level-up
    // fanfare and streak milestone burst — played once, gated by the audio
    // settings toggle inside AudioManager.
    final audio = AudioManager();
    if (widget.result.leveledUp) {
      audio.playLevelUp();
    } else if (widget.result.newStreakMilestone) {
      audio.playStreak(widget.result.currentStreak);
    }

    // A6: when this completion crosses a level, the Lottie level-up
    // overlay plays on top of the reveal (auto-dismisses, tap-dismisses).
    if (widget.result.leveledUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showLevelUpOverlay(context, widget.result.newLevel);
        }
      });
    }

    if (tokens.reduced) {
      // Informational content: show the finished state immediately.
      controller.value = 1.0;
      widget.onRevealComplete?.call();
    } else {
      controller.forward().whenComplete(() {
        if (mounted) {
          // A6: badge/achievement unlocks play right after the choreography.
          final unlockNames = widget.unlockNames;
          if (unlockNames.isNotEmpty) {
            showBadgeUnlockOverlay(context, unlockNames.first);
          }
          widget.onRevealComplete?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  double _window((double, double) window) {
    final value = _controller?.value ?? 0.0;
    return ((value - window.$1) / (window.$2 - window.$1)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>();
    final shape =
        Theme.of(context).extension<ShapeTokens>() ?? ShapeTokens.standard;
    final scheme = Theme.of(context).colorScheme;
    final accent = widget.accent ?? scheme.primary;
    final result = widget.result;
    final tokens = MotionTokens.of(context);

    return AnimatedBuilder(
      animation: _controller ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, _) {
        final starsT = _window(_starsWindow);
        final xpT = _window(_xpWindow);
        final unlocksT = _window(_unlocksWindow);

        final shownStars = (widget.result.starsAwarded * starsT)
            .round()
            .clamp(0, widget.result.starsAwarded);
        final shownXp = (widget.breakdown.totalXp * xpT).round();
        final levelView = _levelView(xpT);

        return Semantics(
          container: true,
          label: _semanticSummary(shownStars, shownXp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context, semantic: semantic, accent: accent),
              const SizedBox(height: 12),
              _card(
                context,
                shape: shape,
                semantic: semantic,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _starRow(context, shownStars, accent: accent),
                    const SizedBox(height: 14),
                    _divider(semantic),
                    const SizedBox(height: 14),
                    _xpRow(
                      context,
                      shownXp: shownXp,
                      levelFraction: levelView.$1,
                      shownLevel: levelView.$2,
                      accent: accent,
                      semantic: semantic,
                    ),
                    if (widget.breakdown.lines.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _breakdown(context, semantic: semantic),
                    ],
                  ],
                ),
              ),
              if (result.newStreakMilestone) ...[
                const SizedBox(height: 12),
                _streakChip(context, semantic: semantic),
              ],
              if (widget.unlockNames.isNotEmpty) ...[
                const SizedBox(height: 12),
                _unlocks(context,
                    progress: unlocksT, accent: accent, semantic: semantic),
              ],
              if (_hasSkillMovement) ...[
                const SizedBox(height: 12),
                _skillMovement(context, semantic: semantic, accent: accent),
              ],
              if (widget.recommendation != null) ...[
                const SizedBox(height: 16),
                _nextQuest(context,
                    tokens: tokens, accent: accent, semantic: semantic),
              ],
            ],
          ),
        );
      },
    );
  }

  /// The XP bar as the choreography runs: it fills to the top on a level-up,
  /// then resets into the new level's progress, flipping the level label at
  /// the same beat. Returns `(fraction, level)`.
  (double, int) _levelView(double xpT) {
    final result = widget.result;
    if (!result.leveledUp) {
      return (widget.levelProgressAfter.clamp(0.0, 1.0), result.newLevel);
    }
    const flipAt = 0.82;
    if (xpT >= flipAt) {
      final t = (xpT - flipAt) / (1 - flipAt);
      final fraction = widget.levelProgressAfter.clamp(0.0, 1.0) * t;
      return (fraction, result.newLevel);
    }
    final t = xpT / flipAt;
    final fraction =
        widget.levelProgressBefore + (1.0 - widget.levelProgressBefore) * t;
    return (fraction.clamp(0.0, 1.0), result.previousLevel);
  }

  bool get _hasSkillMovement {
    final before = widget.skillAccuracyBefore;
    final after = widget.skillAccuracyAfter;
    return before != null && after != null;
  }

  String _semanticSummary(int stars, int xp) {
    final parts = <String>[
      'Quest reward. ${widget.breakdown.totalXp} experience points earned.',
      '$stars of 3 session stars earned.',
    ];
    if (widget.result.leveledUp) {
      parts.add('Level up to ${widget.result.newLevel}.');
    }
    if (widget.result.newStreakMilestone) {
      parts.add('${widget.result.currentStreak} day streak.');
    }
    return parts.join(' ');
  }

  Widget _header(
    BuildContext context, {
    required SemanticColors? semantic,
    required Color accent,
  }) {
    final title = widget.result.leveledUp ? 'Level up!' : 'Quest complete!';
    final subtitle = widget.skillName ?? 'Nice work';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: semantic?.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _card(
    BuildContext context, {
    required ShapeTokens shape,
    required SemanticColors? semantic,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(shape.radiusLg),
        border: Border.all(
            color: semantic?.divider ?? Theme.of(context).dividerColor),
        boxShadow: AppShadows.md(
            semantic?.reward ?? Theme.of(context).colorScheme.primary),
      ),
      child: child,
    );
  }

  Widget _divider(SemanticColors? semantic) {
    return Divider(height: 1, thickness: 1.4, color: semantic?.divider);
  }

  Widget _starRow(BuildContext context, int shownStars,
      {required Color accent}) {
    return Semantics(
      label: '$shownStars of 3 session stars earned',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                i < shownStars
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 34,
                color: i < shownStars ? accent : Theme.of(context).hintColor,
              ),
            ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+${widget.result.starsAwarded} to your star jar',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  widget.result.starsAwarded > 0
                      ? '${widget.starBalance} stars to spend'
                      : 'Reach 50% accuracy to earn stars next time',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _xpRow(
    BuildContext context, {
    required int shownXp,
    required double levelFraction,
    required int shownLevel,
    required Color accent,
    required SemanticColors? semantic,
  }) {
    final result = widget.result;
    return Semantics(
      label: '$shownXp experience points, level $shownLevel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, size: 20, color: accent),
              const SizedBox(width: 6),
              // Both text halves shrink instead of overflowing on narrow
              // sheets or at large text scale (probe: 320px/200% cases).
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '+$shownXp XP',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: accent,
                        ),
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (semantic?.info ?? accent).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Level $shownLevel',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: semantic?.info ?? accent,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: levelFraction.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: semantic?.surfaceSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          if (result.leveledUp && shownLevel == result.newLevel) ...[
            const SizedBox(height: 8),
            Text(
              'You reached level ${result.newLevel}!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: semantic?.success,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _breakdown(BuildContext context, {required SemanticColors? semantic}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in widget.breakdown.lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.check_rounded, size: 16, color: semantic?.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    line,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: semantic?.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _streakChip(BuildContext context,
      {required SemanticColors? semantic}) {
    final streak = widget.result.currentStreak;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: (semantic?.warning ?? Theme.of(context).colorScheme.primary)
            .withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$streak day streak — you played again today!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _unlocks(
    BuildContext context, {
    required double progress,
    required Color accent,
    required SemanticColors? semantic,
  }) {
    final names = widget.unlockNames;
    // Reveal one chip at a time so each unlock gets its own beat instead of
    // arriving as an unreadable pile.
    final visible = (progress * names.length).ceil().clamp(0, names.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < visible; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _UnlockChip(label: names[i], accent: accent),
          ),
      ],
    );
  }

  Widget _skillMovement(
    BuildContext context, {
    required SemanticColors? semantic,
    required Color accent,
  }) {
    final before = ((widget.skillAccuracyBefore ?? 0) * 100).round();
    final after = ((widget.skillAccuracyAfter ?? 0) * 100).round();
    final improved = after >= before;
    final tint =
        improved ? (semantic?.success ?? accent) : (semantic?.info ?? accent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tint.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            improved ? Icons.trending_up_rounded : Icons.handyman_rounded,
            size: 20,
            color: tint,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              improved
                  ? '${widget.skillName ?? 'This skill'}: $before% → $after%'
                  : '${widget.skillName ?? 'This skill'} still needs practice ($before% → $after%)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextQuest(
    BuildContext context, {
    required MotionTokens tokens,
    required Color accent,
    required SemanticColors? semantic,
  }) {
    final recommendation = widget.recommendation!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  recommendation.chipLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Up next',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            recommendation.skillName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            recommendation.childReason,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: semantic?.textSecondary,
                  height: 1.35,
                ),
          ),
          if (widget.onBackToMap != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: widget.onBackToMap,
                icon: const Icon(Icons.map_rounded),
                label: const Text('See it on the map'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent, width: 1.6),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UnlockChip extends StatelessWidget {
  const _UnlockChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_open_rounded, size: 16, color: accent),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Unlocked: $label',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
