import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// The state of an answer option button
enum AnswerState { idle, selected, correct, incorrect }

/// A polished, animated multiple-choice answer option button.
///
/// Transitions:
///   idle → selected  : scale pop + border highlight (instant, waiting for reveal)
///   selected → correct  : green fill + checkmark burst + scale up
///   selected → incorrect : red fill + X + horizontal shake
///   unselected → correct : gentle green outline (shows the right answer)
///
/// Usage:
///   AnimatedAnswerOption(
///     label: 'Option A',
///     state: AnswerState.correct,
///     isSelected: true,
///     onTap: () => _selectAnswer(0),
///     accentColor: world.primaryColor,
///   )
class AnimatedAnswerOption extends StatefulWidget {
  final String label;
  final String optionLetter;   // 'A', 'B', 'C', 'D'
  final AnswerState state;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color accentColor;
  final int animationDelay;    // ms delay before entrance animation

  const AnimatedAnswerOption({
    super.key,
    required this.label,
    required this.optionLetter,
    required this.state,
    required this.isSelected,
    this.onTap,
    this.accentColor = AppColors.primary,
    this.animationDelay = 0,
  });

  @override
  State<AnimatedAnswerOption> createState() => _AnimatedAnswerOptionState();
}

class _AnimatedAnswerOptionState extends State<AnimatedAnswerOption>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late AnimationController _stateCtrl;
  late AnimationController _shakeCtrl;

  late Animation<double> _entranceScale;
  late Animation<double> _entranceFade;
  late Animation<double> _stateScale;
  late Animation<double> _checkmarkDraw;
  late Animation<double> _shakeX;

  bool _hovered = false;

  @override
  void initState() {
    super.initState();

    // Entrance – slides in from bottom with a pop
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: AppMotion.smooth,
    );
    _entranceScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: AppMotion.pop),
    );
    _entranceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut),
    );

    if (widget.animationDelay > 0) {
      Future.delayed(Duration(milliseconds: widget.animationDelay), () {
        if (mounted) _entranceCtrl.forward();
      });
    } else {
      _entranceCtrl.forward();
    }

    // State transition (correct/incorrect reveal)
    _stateCtrl = AnimationController(
      vsync: this,
      duration: AppMotion.smooth,
    );
    _stateScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _stateCtrl, curve: AppMotion.pop),
    );
    _checkmarkDraw = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stateCtrl,
          curve: const Interval(0.2, 1.0, curve: Curves.easeOut)),
    );

    // Shake for incorrect
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeX = Tween<double>(begin: 0.0, end: 1.0).animate(_shakeCtrl);
  }

  @override
  void didUpdateWidget(AnimatedAnswerOption old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      if (widget.state == AnswerState.correct ||
          widget.state == AnswerState.incorrect) {
        _stateCtrl.forward(from: 0);
        if (widget.state == AnswerState.incorrect && widget.isSelected) {
          _shakeCtrl.forward(from: 0);
        }
      }
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _stateCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  // ── Colour logic ──────────────────────────────────────────────

  Color _getFillColor() {
    switch (widget.state) {
      case AnswerState.correct:
        return AppColors.correctFeedback;
      case AnswerState.incorrect:
        return widget.isSelected
            ? AppColors.incorrectFeedback
            : Colors.white;
      case AnswerState.selected:
        return widget.accentColor.withValues(alpha: 0.1);
      case AnswerState.idle:
        return Colors.white;
    }
  }

  Color _getBorderColor() {
    switch (widget.state) {
      case AnswerState.correct:
        return AppColors.correctFeedbackBorder;
      case AnswerState.incorrect:
        return widget.isSelected
            ? AppColors.incorrectFeedbackBorder
            : AppColors.surfaceDisabled;
      case AnswerState.selected:
        return widget.accentColor;
      case AnswerState.idle:
        return AppColors.surfaceDisabled;
    }
  }

  Color _getBadgeColor() {
    switch (widget.state) {
      case AnswerState.correct:
        return AppColors.correctFeedbackBorder;
      case AnswerState.incorrect:
        return widget.isSelected
            ? AppColors.incorrectFeedbackBorder
            : AppColors.divider;
      case AnswerState.selected:
        return widget.accentColor;
      case AnswerState.idle:
        return AppColors.surfaceDisabled;
    }
  }

  Color _getBadgeTextColor() {
    switch (widget.state) {
      case AnswerState.correct:
      case AnswerState.incorrect:
        return widget.isSelected ? Colors.white : AppColors.textSecondary;
      case AnswerState.selected:
        return Colors.white;
      case AnswerState.idle:
        return AppColors.textSecondary;
    }
  }

  Gradient? _getFillGradient() {
    switch (widget.state) {
      case AnswerState.correct:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFEAFBEF),
            AppColors.correctFeedback.withValues(alpha: 0.95),
          ],
        );
      case AnswerState.incorrect:
        if (!widget.isSelected) return null;
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFEFEF),
            AppColors.incorrectFeedback.withValues(alpha: 0.95),
          ],
        );
      case AnswerState.selected:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.accentColor.withValues(alpha: 0.12),
            widget.accentColor.withValues(alpha: 0.04),
          ],
        );
      case AnswerState.idle:
        return null;
    }
  }

  // ── Icon / symbol ────────────────────────────────────────────

  Widget? _getTrailingIcon() {
    if (widget.state == AnswerState.correct && (widget.isSelected || true)) {
      return AnimatedBuilder(
        animation: _checkmarkDraw,
        builder: (_, __) => Opacity(
          opacity: _checkmarkDraw.value,
          child: Transform.scale(
            scale: 0.6 + _checkmarkDraw.value * 0.4,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.correctFeedbackBorder,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            ),
          ),
        ),
      );
    }
    if (widget.state == AnswerState.incorrect && widget.isSelected) {
      return AnimatedBuilder(
        animation: _checkmarkDraw,
        builder: (_, __) => Opacity(
          opacity: _checkmarkDraw.value,
          child: Transform.scale(
            scale: 0.6 + _checkmarkDraw.value * 0.4,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.incorrectFeedbackBorder,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final canTap =
        widget.state == AnswerState.idle && widget.onTap != null;

    return AnimatedBuilder(
      animation: Listenable.merge(
          [_entranceCtrl, _stateCtrl, _shakeCtrl]),
      builder: (context, child) {
        // Shake offset for wrong answers
        final shakeOffset = widget.state == AnswerState.incorrect && widget.isSelected
            ? math.sin(_shakeX.value * math.pi * 5) *
                (1 - _shakeX.value) * 10
            : 0.0;

        return FadeTransition(
          opacity: _entranceFade,
          child: Transform.scale(
            scale: _entranceScale.value * _stateScale.value,
            child: Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: child,
            ),
          ),
        );
      },
      child: MouseRegion(
        cursor: canTap ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: canTap ? widget.onTap : null,
          child: AnimatedContainer(
            duration: AppMotion.standard,
            curve: AppMotion.enter,
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _getFillGradient() == null ? _getFillColor() : null,
              gradient: _getFillGradient(),
              borderRadius: BorderRadius.circular(AppBorders.lg),
              border: Border.all(
                color: _getBorderColor(),
                width: widget.state != AnswerState.idle ? 2.0 : (_hovered ? 1.8 : 1.2),
              ),
              boxShadow: widget.state == AnswerState.correct
                  ? AppShadows.glow(AppColors.correctFeedbackBorder, intensity: 0.3)
                  : (widget.state == AnswerState.incorrect && widget.isSelected
                      ? AppShadows.sm(AppColors.incorrectFeedbackBorder)
                      : (_hovered && canTap
                          ? AppShadows.md(widget.accentColor)
                          : AppShadows.neutral)),
            ),
            child: Row(
              children: [
                // Option letter badge
                AnimatedContainer(
                  duration: AppMotion.standard,
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _getBadgeColor(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      widget.optionLetter,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _getBadgeTextColor(),
                        fontFamily: AppTheme.fontPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Label
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: widget.isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: widget.state == AnswerState.correct
                          ? const Color(0xFF2E7D32)
                          : (widget.state == AnswerState.incorrect && widget.isSelected
                              ? const Color(0xFFC62828)
                              : AppColors.textPrimary),
                      fontFamily: AppTheme.fontBody,
                    ),
                  ),
                ),

                // Trailing icon (check/x)
                if (_getTrailingIcon() != null) ...[
                  const SizedBox(width: 8),
                  _getTrailingIcon()!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUESTION CARD — displays the question text with world-themed styling
// ─────────────────────────────────────────────────────────────────────────────

class QuestionCard extends StatefulWidget {
  final String question;
  final Color accentColor;
  final int questionNumber;
  final int totalQuestions;

  const QuestionCard({
    super.key,
    required this.question,
    required this.accentColor,
    this.questionNumber = 1,
    this.totalQuestions = 1,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppMotion.smooth);
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: AppMotion.enter));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(QuestionCard old) {
    super.didUpdateWidget(old);
    if (old.question != widget.question) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideIn,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                widget.accentColor.withValues(alpha: 0.07),
              ],
            ),
            borderRadius: BorderRadius.circular(AppBorders.xl),
            border: Border.all(
              color: widget.accentColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: AppShadows.md(widget.accentColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Q number chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppBorders.pill),
                ),
                child: Text(
                  'Q${widget.questionNumber} of ${widget.totalQuestions}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.question,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
