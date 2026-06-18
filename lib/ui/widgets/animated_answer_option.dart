import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final String optionLetter; // 'A', 'B', 'C', 'D'
  final AnswerState state;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color accentColor;
  final int animationDelay; // ms delay before entrance animation

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
  bool _focused = false;
  bool _reduceMotion = false;

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
      CurvedAnimation(
          parent: _stateCtrl,
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (_reduceMotion) {
      _entranceCtrl.value = 1.0;
      if (widget.state == AnswerState.correct ||
          widget.state == AnswerState.incorrect) {
        _stateCtrl.value = 1.0;
      }
      _shakeCtrl.stop();
    }
  }

  @override
  void didUpdateWidget(AnimatedAnswerOption old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      if (widget.state == AnswerState.correct ||
          widget.state == AnswerState.incorrect) {
        if (_reduceMotion) {
          _stateCtrl.value = 1.0;
        } else {
          _stateCtrl.forward(from: 0);
        }
        if (!_reduceMotion &&
            widget.state == AnswerState.incorrect &&
            widget.isSelected) {
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
        return widget.isSelected ? AppColors.incorrectFeedback : Colors.white;
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
        return widget.accentColor.withValues(alpha: _hovered ? 0.18 : 0.10);
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
        return widget.accentColor;
    }
  }

  List<BoxShadow> _getOptionShadow(bool canTap) {
    if (widget.state == AnswerState.correct) {
      return [
        BoxShadow(
          color: AppColors.correctFeedbackBorder.withValues(alpha: 0.18),
          blurRadius: _reduceMotion ? 8 : 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
    if (widget.state == AnswerState.incorrect && widget.isSelected) {
      return AppShadows.sm(AppColors.incorrectFeedbackBorder);
    }
    if ((_hovered || _focused || widget.isSelected) && canTap) {
      return [
        BoxShadow(
          color: widget.accentColor.withValues(alpha: 0.16),
          blurRadius: _reduceMotion ? 8 : 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.055),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ];
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
    final canTap = widget.state == AnswerState.idle && widget.onTap != null;
    final trailingIcon = _getTrailingIcon();

    return AnimatedBuilder(
      animation: Listenable.merge([_entranceCtrl, _stateCtrl, _shakeCtrl]),
      builder: (context, child) {
        // Shake offset for wrong answers
        final shakeOffset = !_reduceMotion &&
                widget.state == AnswerState.incorrect &&
                widget.isSelected
            ? math.sin(_shakeX.value * math.pi * 5) * (1 - _shakeX.value) * 10
            : 0.0;

        if (_reduceMotion) {
          return child!;
        }

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
      child: FocusableActionDetector(
        enabled: canTap,
        mouseCursor: canTap ? SystemMouseCursors.click : MouseCursor.defer,
        onShowFocusHighlight: (focused) {
          if (mounted) setState(() => _focused = focused);
        },
        onShowHoverHighlight: (hovered) {
          if (mounted) setState(() => _hovered = hovered);
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              if (canTap) widget.onTap?.call();
              return null;
            },
          ),
        },
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: canTap ? widget.onTap : null,
          child: Semantics(
            button: true,
            enabled: canTap,
            selected: widget.isSelected,
            label: 'Answer ${widget.optionLetter}: ${widget.label}',
            child: AnimatedContainer(
              duration: _reduceMotion ? Duration.zero : AppMotion.fast,
              curve: AppMotion.enter,
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              constraints: const BoxConstraints(
                  minHeight: AppInput.preferredTouchTarget),
              decoration: BoxDecoration(
                color: _getFillGradient() == null ? _getFillColor() : null,
                gradient: _getFillGradient(),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _focused ? widget.accentColor : _getBorderColor(),
                  width: _focused
                      ? AppInput.focusRingWidth
                      : (widget.state != AnswerState.idle
                          ? 2.0
                          : (_hovered ? 1.8 : 1.2)),
                ),
                boxShadow: _getOptionShadow(canTap),
              ),
              child: Row(
                children: [
                  // Option letter badge
                  AnimatedContainer(
                    duration: _reduceMotion ? Duration.zero : AppMotion.fast,
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: widget.state == AnswerState.idle
                          ? Colors.white
                          : _getBadgeColor(),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getBadgeColor(),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getBadgeColor().withValues(alpha: 0.20),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.optionLetter,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
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
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.22,
                        fontWeight: widget.isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: widget.state == AnswerState.correct
                            ? const Color(0xFF2E7D32)
                            : (widget.state == AnswerState.incorrect &&
                                    widget.isSelected
                                ? const Color(0xFFC62828)
                                : AppColors.textPrimary),
                        fontFamily: AppTheme.fontBody,
                      ),
                    ),
                  ),

                  // Trailing icon (check/x)
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    trailingIcon,
                  ],
                ],
              ),
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
  bool _reduceMotion = false;

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
      if (_reduceMotion) {
        _ctrl.value = 1.0;
      } else {
        _ctrl.forward(from: 0);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (_reduceMotion) {
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Question ${widget.questionNumber} of ${widget.totalQuestions}. ${widget.question}',
      child: _reduceMotion
          ? _buildCard(context)
          : FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideIn,
                child: _buildCard(context),
              ),
            ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 560;

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isCompact ? 18 : 22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              widget.accentColor.withValues(alpha: 0.075),
              widget.accentColor.withValues(alpha: 0.035),
            ],
            stops: const [0, 0.62, 1],
          ),
          borderRadius: BorderRadius.circular(AppBorders.lg),
          border: Border.all(
            color: widget.accentColor.withValues(alpha: 0.28),
            width: 1.5,
          ),
          boxShadow: AppShadows.sm(widget.accentColor),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              top: -10,
              child: Opacity(
                opacity: 0.10,
                child: SizedBox(
                  width: 86,
                  height: 86,
                  child: Image.asset(
                    'assets/images/scroll.PNG',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.auto_stories_rounded,
                      size: 78,
                      color: widget.accentColor,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppBorders.pill),
                        border: Border.all(
                          color: widget.accentColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flag_rounded,
                              size: 13, color: widget.accentColor),
                          const SizedBox(width: 5),
                          Text(
                            'Question ${widget.questionNumber}/${widget.totalQuestions}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: widget.accentColor,
                              fontFamily: AppTheme.fontPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppBorders.pill),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_rounded,
                              size: 13, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            'Choose one answer',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  widget.question,
                  style: TextStyle(
                    fontSize: isCompact ? 18 : 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.34,
                    fontFamily: AppTheme.fontPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
