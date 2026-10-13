import 'package:flutter/material.dart';

import 'package:brightbound_adventures/ui/components/reward_reveal.dart';
import 'package:brightbound_adventures/ui/components/session_completion.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/branded_back_button.dart';

/// Completion summary for Science Explorers sessions.
///
/// This is the single place a science quest applies its rewards: it runs
/// the shared `completeSession` orchestration (evidence updates + exactly
/// one `RewardTransactionService.apply()` per [sessionId]), then the earned
/// [SessionCompletion] is presented by [RewardReveal]. Rebuilding, resuming,
/// or revisiting this screen replays the same result instead of re-awarding
/// it.
class ScienceResultsScreen extends StatefulWidget {
  final String skillName;
  final String skillId;

  /// Stable identity for this completion; the reward transaction is keyed
  /// on it, so one session awards exactly once.
  final String sessionId;

  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final int hintsUsed;
  final Color themeColor;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;
  final String? zoneId;
  final String? zoneName;

  const ScienceResultsScreen({
    super.key,
    required this.skillName,
    required this.skillId,
    required this.sessionId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    this.hintsUsed = 0,
    this.themeColor = const Color(0xFF4DB6AC),
    required this.onPlayAgain,
    required this.onExit,
    this.zoneId,
    this.zoneName,
  });

  @override
  State<ScienceResultsScreen> createState() => _ScienceResultsScreenState();
}

class _ScienceResultsScreenState extends State<ScienceResultsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scoreController;
  late final AnimationController _pulseController;
  late final Animation<double> _scoreAnimation;

  SessionCompletion? _completion;
  bool _applying = true;
  Object? _error;
  bool _reduceMotion = false;
  bool _motionSynced = false;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0, end: widget.accuracy).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    _scoreController.forward();

    // Kick off after the first frame so reward work never runs during build,
    // and so the child sees an honest "packing your reward" beat rather than
    // a frozen screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _processResults();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_motionSynced && _reduceMotion == reduceMotion) return;
    _motionSynced = true;
    _reduceMotion = reduceMotion;
    if (_reduceMotion) {
      _pulseController.stop();
      _scoreController.value = 1;
    } else {
      _pulseController.repeat(reverse: true);
      if (_scoreController.value == 0) {
        _scoreController.forward();
      }
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _processResults() async {
    setState(() {
      _applying = true;
      _error = null;
    });

    try {
      // The single shared orchestration path: evidence updates, then the
      // one idempotent reward transaction, then presentation data.
      final completion = await completeSession(
        context,
        sessionId: widget.sessionId,
        skillId: widget.skillId,
        skillName: widget.skillName,
        accuracy: widget.accuracy,
        correctAnswers: widget.correctAnswers,
        totalQuestions: widget.totalQuestions,
        hintsUsed: widget.hintsUsed,
        accent: widget.themeColor,
        zoneId: widget.zoneId,
        zoneName: widget.zoneName,
      );

      if (!mounted) return;
      setState(() {
        _completion = completion;
        _applying = false;
      });
    } catch (error) {
      // Never pretend the reward landed: show a real error with a retry,
      // which is safe because the transaction is idempotent.
      if (!mounted) return;
      setState(() {
        _error = error;
        _applying = false;
      });
    }
  }

  String get _headline {
    if (widget.accuracy >= 0.95) return 'Discovery confirmed!';
    if (widget.accuracy >= 0.8) return 'Brilliant investigation!';
    if (widget.accuracy >= 0.6) return 'Good science thinking!';
    return 'Keep experimenting!';
  }

  String get _subhead {
    if (_completion?.reward.leveledUp == true) {
      return 'Level up! Your explorer skills are growing.';
    }
    if (widget.accuracy >= 0.8) {
      return 'You observed carefully and connected the clues.';
    }
    return 'Every result teaches you something for the next experiment.';
  }

  int get _starsEarned {
    if (widget.accuracy >= 0.9) return 3;
    if (widget.accuracy >= 0.7) return 2;
    if (widget.accuracy >= 0.5) return 1;
    return 0;
  }

  Color _scoreColor(double value) {
    if (value >= 0.9) return Colors.green;
    if (value >= 0.7) return Colors.lightGreen;
    if (value >= 0.5) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 560;
    final completion = _completion;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.themeColor.withValues(alpha: 0.9),
              widget.themeColor.withValues(alpha: 0.42),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(isCompact ? 18 : 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _reduceMotion
                                ? 1.0
                                : 1.0 + (_pulseController.value * 0.06),
                            child: child,
                          );
                        },
                        child: Container(
                          width: isCompact ? 108 : 128,
                          height: isCompact ? 108 : 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.38),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.science_rounded,
                            color: Colors.white,
                            size: 72,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _headline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 30 : 38,
                          fontWeight: FontWeight.w900,
                          shadows: const [
                            Shadow(color: Colors.black26, blurRadius: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _subhead,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: isCompact ? 15 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildResultsCard(isCompact, completion),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard(bool isCompact, SessionCompletion? completion) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 760),
      padding: EdgeInsets.all(isCompact ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withValues(alpha: 0.26),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.skillName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.themeColor,
              fontSize: isCompact ? 19 : 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: isCompact ? 118 : 136,
                    height: isCompact ? 118 : 136,
                    child: CircularProgressIndicator(
                      value: _scoreAnimation.value,
                      strokeWidth: 12,
                      backgroundColor: Colors.blueGrey.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _scoreColor(_scoreAnimation.value),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_scoreAnimation.value * 100).round()}%',
                        style: TextStyle(
                          color: widget.themeColor,
                          fontSize: isCompact ? 30 : 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'Accuracy',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final earned = index < _starsEarned;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Icon(
                  earned ? Icons.star_rounded : Icons.star_border_rounded,
                  color: earned
                      ? AppColors.reward
                      : Colors.blueGrey.withValues(alpha: 0.28),
                  size: isCompact ? 36 : 44,
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              _ResultChip(
                icon: Icons.check_circle_rounded,
                label:
                    '${widget.correctAnswers}/${widget.totalQuestions} correct',
                color: Colors.green,
              ),
              _ResultChip(
                icon: Icons.lightbulb_rounded,
                label: '${widget.hintsUsed} hints',
                color: Colors.amber.shade700,
              ),
              _ResultChip(
                icon: Icons.bolt_rounded,
                label: '+${completion?.breakdown.totalXp ?? 0} XP',
                color: widget.themeColor,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_applying)
            RewardApplyingCard(accent: widget.themeColor)
          else if (_error != null)
            RewardErrorCard(onRetry: _processResults)
          else if (completion != null)
            RewardReveal(
              result: completion.reward,
              breakdown: completion.breakdown,
              starBalance: completion.starBalance,
              levelProgressBefore: completion.levelProgressBefore,
              levelProgressAfter: completion.levelProgressAfter,
              accent: widget.themeColor,
              skillName: widget.skillName,
              skillAccuracyBefore: completion.skillAccuracyBefore,
              skillAccuracyAfter: completion.skillAccuracyAfter,
              recommendation: completion.recommendation,
              unlockNames: completion.unlockNames,
              onBackToMap: () => backToWorldMap(context),
            ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: isCompact ? double.infinity : 220,
                child: BrandedBackButton(
                  label: 'Back to Zone',
                  onPressed: widget.onExit,
                  // Solid themeColor + derived ink: the old white-bg/
                  // themeColor-fg pairing measured 2.44:1 for the teal
                  // science theme on white.
                  backgroundColor: widget.themeColor,
                  foregroundColor: InkTokens.on(widget.themeColor),
                  borderColor: widget.themeColor,
                  tokenBackgroundColor:
                      widget.themeColor.withValues(alpha: 0.12),
                ),
              ),
              SizedBox(
                width: isCompact ? double.infinity : 220,
                child: ElevatedButton.icon(
                  onPressed: widget.onPlayAgain,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    foregroundColor: InkTokens.on(widget.themeColor),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ResultChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: InkTokens.onTint(color), size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                // Ink on the 12% chip tint, not the raw accent: teal labels
                // measured 2.44:1 on the near-white pill.
                color: InkTokens.onTint(color),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
