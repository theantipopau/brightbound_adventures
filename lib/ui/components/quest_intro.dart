import 'package:flutter/material.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/juicy_button.dart';

/// The opening beat of a quest: what we are doing, why now, what we can
/// earn, and one obvious way to begin.
///
/// Shared by every learning zone so a child meets the same shape of intro
/// wherever they start. It is deliberately a *beat*, not a gate — the intro
/// states the objective and the reward preview, then hands over: no
/// countdown, no pressure, no locking the Start button behind a timer.
class QuestIntro extends StatefulWidget {
  const QuestIntro({
    super.key,
    required this.zoneLabel,
    required this.title,
    required this.objective,
    required this.reason,
    required this.questionCount,
    required this.rewardXp,
    required this.rewardStars,
    required this.onStart,
    this.onBack,
    this.accent,
    this.companionEmoji,
    this.companionLine,
    this.difficulty,
    this.naplanLabel,
  });

  /// e.g. "🌲 Word Woods" — shown as-is so callers can keep the emoji
  /// already carried by their zone route.
  final String zoneLabel;

  /// Skill/quest title, e.g. "Homophones".
  final String title;

  /// Child-facing objective: what they will be able to do.
  final String objective;

  /// Why this quest is being offered now (recommendation reason).
  final String reason;

  final int questionCount;
  final int rewardXp;
  final int rewardStars;

  /// Zone/brand accent colour.
  final Color? accent;

  final VoidCallback onStart;
  final VoidCallback? onBack;

  /// Optional companion/guardian reaction.
  final String? companionEmoji;
  final String? companionLine;

  /// 1–5 challenge estimate; rendered as a friendly word, never a number.
  final int? difficulty;

  /// NAPLAN focus area for this quest (e.g. "Homophones"), rendered as a
  /// gold badge beside the zone chip so families can see the alignment at
  /// a glance. Null for skills with no NAPLAN tag.
  final String? naplanLabel;

  @override
  State<QuestIntro> createState() => _QuestIntroState();
}

class _QuestIntroState extends State<QuestIntro>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  bool _started = false;

  /// Motion tokens resolve through `MediaQuery`, so they can only be read
  /// from `didChangeDependencies` — reading them in `initState` throws.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final tokens = MotionTokens.of(context);
    _controller = AnimationController(
      vsync: this,
      duration:
          tokens.reduced ? Duration.zero : const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Staggered entrance: each beat fades/slides in after the previous one,
  /// so the intro reads top-to-bottom instead of arriving all at once.
  double _beat(int index) {
    final controller = _controller;
    if (controller == null) return 1.0;
    final start = 0.08 * index;
    final raw = ((controller.value - start) / 0.5).clamp(0.0, 1.0);
    return MotionTokens.of(context).enterCurve.transform(raw);
  }

  String get _challengeLabel {
    switch (widget.difficulty ?? 3) {
      case 1:
      case 2:
        return 'Gentle';
      case 3:
        return 'Just right';
      case 4:
      case 5:
        return 'Tricky';
      default:
        return 'Just right';
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>();
    final shape =
        Theme.of(context).extension<ShapeTokens>() ?? ShapeTokens.standard;
    final scheme = Theme.of(context).colorScheme;
    final accent = widget.accent ?? scheme.primary;

    return AnimatedBuilder(
      animation: _controller ?? const AlwaysStoppedAnimation(0.0),
      builder: (context, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _fadeSlide(
                  _beat(0),
                  Row(
                    children: [
                      if (widget.onBack != null)
                        IconButton(
                          tooltip: 'Back',
                          onPressed: widget.onBack,
                          icon: const Icon(Icons.arrow_back_rounded),
                          constraints:
                              const BoxConstraints(minWidth: 48, minHeight: 48),
                        ),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color: accent.withValues(alpha: 0.35)),
                              ),
                              child: Text(
                                widget.zoneLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: accent,
                                    ),
                              ),
                            ),
                            if (widget.naplanLabel != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: (semantic?.reward ?? scheme.tertiary)
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: (semantic?.reward ?? scheme.tertiary)
                                        .withValues(alpha: 0.45),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.school_rounded,
                                      size: 15,
                                      color:
                                          semantic?.reward ?? scheme.tertiary,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        'NAPLAN · ${widget.naplanLabel}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: semantic?.reward ??
                                                  scheme.tertiary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _fadeSlide(
                  _beat(1),
                  Semantics(
                    header: true,
                    child: Text(
                      widget.title,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _fadeSlide(
                  _beat(2),
                  Text(
                    widget.objective,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: semantic?.textSecondary,
                          height: 1.4,
                        ),
                  ),
                ),
                const SizedBox(height: 18),
                _fadeSlide(
                  _beat(3),
                  _infoCard(
                    context,
                    shape: shape,
                    semantic: semantic,
                    accent: accent,
                    icon: Icons.flag_rounded,
                    title: 'Your quest',
                    body: widget.reason,
                  ),
                ),
                if (widget.companionLine != null) ...[
                  const SizedBox(height: 12),
                  _fadeSlide(
                    _beat(4),
                    _companionLine(context, semantic: semantic, accent: accent),
                  ),
                ],
                const SizedBox(height: 12),
                _fadeSlide(
                  _beat(5),
                  _rewardPreview(context,
                      shape: shape, semantic: semantic, accent: accent),
                ),
                const SizedBox(height: 28),
                _fadeSlide(
                  _beat(6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      JuicyButton(
                        label: 'Start quest',
                        emoji: '🗺️',
                        onPressed: widget.onStart,
                        shimmer: true,
                        gradient: LinearGradient(
                          colors: [accent, accent.withValues(alpha: 0.82)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        textColor: scheme.onPrimary,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: widget.onBack,
                        child: Text(
                          'Back to zone',
                          style: TextStyle(
                            color: semantic?.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _fadeSlide(double t, Widget child) {
    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, (1 - t) * 14),
        child: child,
      ),
    );
  }

  Widget _infoCard(
    BuildContext context, {
    required ShapeTokens shape,
    required SemanticColors? semantic,
    required Color accent,
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(shape.radiusLg),
        border: Border.all(
            color: semantic?.divider ?? Theme.of(context).dividerColor),
        boxShadow: AppShadows.sm(accent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: accent,
                        letterSpacing: 0.4,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _companionLine(
    BuildContext context, {
    required SemanticColors? semantic,
    required Color accent,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.companionEmoji ?? '✨',
            style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            widget.companionLine!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: semantic?.textSecondary,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }

  Widget _rewardPreview(
    BuildContext context, {
    required ShapeTokens shape,
    required SemanticColors? semantic,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (semantic?.reward ?? accent).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(shape.radiusLg),
        border: Border.all(
            color: (semantic?.reward ?? accent).withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quest rewards',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _pill(
                context,
                icon: Icons.bolt_rounded,
                label: 'Up to ${widget.rewardXp} XP',
                accent: accent,
              ),
              _pill(
                context,
                icon: Icons.star_rounded,
                label: '${widget.rewardStars} stars',
                accent: accent,
              ),
              _pill(
                context,
                icon: Icons.help_outline_rounded,
                label: '${widget.questionCount} challenges',
                accent: accent,
              ),
              _pill(
                context,
                icon: Icons.local_fire_department_outlined,
                label: _challengeLabel,
                accent: accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
