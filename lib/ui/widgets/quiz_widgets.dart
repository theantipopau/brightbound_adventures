import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brightbound_adventures/core/services/tts_service.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// A small speaker button that reads text aloud via TTS.
/// Drop into any quiz header — pass the text to speak on tap.
class TtsSpeakerButton extends StatefulWidget {
  final String text;
  final double size;
  final Color? color;

  const TtsSpeakerButton({
    super.key,
    required this.text,
    this.size = 40,
    this.color,
  });

  @override
  State<TtsSpeakerButton> createState() => _TtsSpeakerButtonState();
}

class _TtsSpeakerButtonState extends State<TtsSpeakerButton>
    with SingleTickerProviderStateMixin {
  bool _isSpeaking = false;
  bool _isHovered = false;
  bool _isFocused = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.stop();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    TtsService().stop();
    super.dispose();
  }

  Future<void> _speak() async {
    setState(() => _isSpeaking = true);
    _pulseController.repeat(reverse: true);
    await TtsService().speak(widget.text);
    if (mounted) {
      setState(() => _isSpeaking = false);
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _toggleSpeak() {
    if (_isSpeaking) {
      TtsService().stop();
      if (mounted) {
        setState(() => _isSpeaking = false);
        _pulseController.stop();
        _pulseController.reset();
      }
      return;
    }
    _speak();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? Colors.blueAccent;
    final targetSize = widget.size < AppInput.minTouchTarget
        ? AppInput.minTouchTarget
        : widget.size;
    return Tooltip(
      message: _isSpeaking ? 'Stop reading' : 'Read question aloud',
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (hovered) {
          if (mounted) setState(() => _isHovered = hovered);
        },
        onShowFocusHighlight: (focused) {
          if (mounted) setState(() => _isFocused = focused);
        },
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _toggleSpeak();
              return null;
            },
          ),
        },
        child: Semantics(
          button: true,
          toggled: _isSpeaking,
          label: _isSpeaking ? 'Stop reading aloud' : 'Read question aloud',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleSpeak,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isSpeaking
                      ? _pulseAnimation.value
                      : ((_isHovered || _isFocused) ? 1.06 : 1.0),
                  child: child,
                );
              },
              child: AnimatedContainer(
                duration: AppMotion.fast,
                width: targetSize,
                height: targetSize,
                decoration: BoxDecoration(
                  color: _isSpeaking
                      ? effectiveColor
                      : effectiveColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isFocused
                        ? effectiveColor
                        : effectiveColor.withValues(alpha: 0.35),
                    width: _isFocused ? AppInput.focusRingWidth : 1.5,
                  ),
                  boxShadow: (_isSpeaking || _isHovered || _isFocused)
                      ? AppShadows.sm(effectiveColor)
                      : null,
                ),
                child: Icon(
                  _isSpeaking ? Icons.stop : Icons.volume_up_rounded,
                  size: targetSize * 0.46,
                  color: _isSpeaking ? Colors.white : effectiveColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

/// Floating reward text that animates upward and fades — e.g. "+5 ⭐" or "+10 XP".
/// Wrap the game body in a Stack and overlay this widget at the desired position.
class FloatingRewardText extends StatefulWidget {
  final String text;
  final Color color;
  final double fontSize;
  final VoidCallback? onComplete;

  const FloatingRewardText({
    super.key,
    required this.text,
    this.color = const Color(0xFFFFD700),
    this.fontSize = 28,
    this.onComplete,
  });

  @override
  State<FloatingRewardText> createState() => _FloatingRewardTextState();
}

class _FloatingRewardTextState extends State<FloatingRewardText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _slide;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _slide = Tween<double>(begin: 0.0, end: -80.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.5, end: 1.25)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 30),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slide.value),
          child: Transform.scale(
            scale: _scale.value,
            child: Opacity(
              opacity: _opacity.value,
              child: child,
            ),
          ),
        );
      },
      child: Text(
        widget.text,
        style: TextStyle(
          color: widget.color,
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              blurRadius: 8,
              color: widget.color.withValues(alpha: 0.5),
              offset: const Offset(0, 2),
            ),
            const Shadow(
              blurRadius: 12,
              color: Colors.black38,
              offset: Offset(1, 3),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a floating reward text overlay that animates upward and fades.
/// Call from any game's correct-answer handler — no state or layout changes needed.
void showFloatingReward(
  BuildContext context,
  String text, {
  Color color = const Color(0xFFFFD700),
  double fontSize = 30,
}) {
  if (!context.mounted) return;
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Center(
      child: IgnorePointer(
        child: FloatingRewardText(
          text: text,
          color: color,
          fontSize: fontSize,
          onComplete: () {
            if (entry.mounted) entry.remove();
          },
        ),
      ),
    ),
  );
  overlay.insert(entry);
}

/// Compact, reusable answer feedback panel for quiz screens.
///
/// Keeps result feedback visually consistent across learning worlds while
/// exposing the scoring breakdown kids care about: points, time bonus, and
/// streak momentum.
class AnswerFeedbackPanel extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final int pointsEarned;
  final int timeBonus;
  final int streak;
  final Color accentColor;
  final VoidCallback? onContinue;

  const AnswerFeedbackPanel({
    super.key,
    required this.isCorrect,
    required this.explanation,
    required this.pointsEarned,
    required this.timeBonus,
    required this.streak,
    this.accentColor = AppColors.primary,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final feedbackColor = isCorrect
        ? AppColors.correctFeedbackBorder
        : AppColors.incorrectFeedbackBorder;
    final title = isCorrect ? 'Correct' : 'Try the next one';

    return Semantics(
      container: true,
      liveRegion: true,
      label: '$title. $explanation',
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.enter,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              feedbackColor.withValues(alpha: 0.14),
              Colors.white.withValues(alpha: 0.96),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppBorders.lg),
          border: Border.all(
            color: feedbackColor.withValues(alpha: 0.42),
            width: 2,
          ),
          boxShadow: AppShadows.sm(feedbackColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: feedbackColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCorrect ? Icons.check_rounded : Icons.refresh_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: feedbackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            if (explanation.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                explanation,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (pointsEarned > 0)
                  _FeedbackChip(
                    icon: Icons.star_rounded,
                    label: '+$pointsEarned',
                    color: AppColors.reward,
                  ),
                if (timeBonus > 0)
                  _FeedbackChip(
                    icon: Icons.bolt_rounded,
                    label: '+$timeBonus speed',
                    color: Colors.orange,
                  ),
                if (streak > 1)
                  _FeedbackChip(
                    icon: Icons.local_fire_department_rounded,
                    label: 'x$streak streak',
                    color: Colors.deepOrange,
                  ),
              ],
            ),
            if (onContinue != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Continue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    minimumSize:
                        const Size.fromHeight(AppInput.preferredTouchTarget),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeedbackChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeedbackChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppBorders.pill),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small progress summary strip for quiz/game headers.
///
/// This keeps timer/progress/lives/streak information visually consistent
/// without forcing every subject game to rebuild the same dense row.
class QuizStatusStrip extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int score;
  final int lives;
  final int streak;
  final int remainingSeconds;
  final int maxSeconds;
  final Color accentColor;

  const QuizStatusStrip({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.score,
    required this.lives,
    required this.streak,
    required this.remainingSeconds,
    required this.maxSeconds,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final safeTotal = totalQuestions <= 0 ? 1 : totalQuestions;
    final progress = (currentQuestion / safeTotal).clamp(0.0, 1.0).toDouble();
    final timeProgress = maxSeconds <= 0
        ? 0.0
        : (remainingSeconds / maxSeconds).clamp(0.0, 1.0).toDouble();
    final timeColor = remainingSeconds <= 10 ? Colors.redAccent : accentColor;

    return Semantics(
      container: true,
      label:
          'Question $currentQuestion of $totalQuestions. Score $score. $lives lives. $remainingSeconds seconds left.',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppBorders.lg),
          border: Border.all(color: accentColor.withValues(alpha: 0.18)),
          boxShadow: AppShadows.sm(accentColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppBorders.pill),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: progress,
                      backgroundColor: Colors.blueGrey.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$currentQuestion/$totalQuestions',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _FeedbackChip(
                  icon: Icons.star_rounded,
                  label: '$score',
                  color: AppColors.reward,
                ),
                _FeedbackChip(
                  icon: Icons.favorite_rounded,
                  label: '$lives',
                  color: Colors.redAccent,
                ),
                if (streak > 0)
                  _FeedbackChip(
                    icon: Icons.local_fire_department_rounded,
                    label: '$streak',
                    color: Colors.deepOrange,
                  ),
                _FeedbackChip(
                  icon: Icons.timer_rounded,
                  label: '${remainingSeconds}s',
                  color: timeColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppBorders.pill),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: timeProgress,
                backgroundColor: Colors.blueGrey.withValues(alpha: 0.10),
                valueColor: AlwaysStoppedAnimation<Color>(timeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
