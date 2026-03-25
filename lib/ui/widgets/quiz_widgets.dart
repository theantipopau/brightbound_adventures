import 'dart:async';
import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/services/tts_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? Colors.blueAccent;
    return Tooltip(
      message: 'Read question aloud',
      child: Semantics(
        button: true,
        label: 'Read question aloud',
        child: GestureDetector(
          onTap: _isSpeaking ? TtsService().stop : _speak,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isSpeaking ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: _isSpeaking
                    ? effectiveColor
                    : effectiveColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: effectiveColor.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Icon(
                _isSpeaking ? Icons.stop : Icons.volume_up_rounded,
                size: widget.size * 0.48,
                color: _isSpeaking ? Colors.white : effectiveColor,
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
