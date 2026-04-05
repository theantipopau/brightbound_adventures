import 'dart:async';
import 'package:flutter/material.dart';

/// A text widget that reveals characters one-by-one with a typewriter effect.
///
/// Usage:
/// ```dart
/// TypewriterText(
///   text: 'Hello adventurer!',
///   style: TextStyle(fontSize: 14),
///   characterDelay: Duration(milliseconds: 28),
/// )
/// ```
///
/// Set [enabled] to false to show the full text immediately (useful for
/// accessibility or replay scenarios).
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Delay between each character appearing.
  final Duration characterDelay;

  /// Delay before typing starts (allows entrance animations to settle first).
  final Duration initialDelay;

  /// When false the full text is shown immediately — no animation.
  final bool enabled;

  /// Called when the full text has been revealed.
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.characterDelay = const Duration(milliseconds: 25),
    this.initialDelay = const Duration(milliseconds: 300),
    this.enabled = true,
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  Timer? _timer;
  int _visibleLength = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) {
      _visibleLength = widget.text.length;
    } else {
      Future.delayed(widget.initialDelay, _startTyping);
    }
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      setState(() => _visibleLength = 0);
      if (widget.enabled) {
        Future.delayed(widget.initialDelay, _startTyping);
      } else {
        setState(() => _visibleLength = widget.text.length);
      }
    }
  }

  void _startTyping() {
    if (!mounted) return;
    _timer?.cancel();
    _timer = Timer.periodic(widget.characterDelay, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_visibleLength >= widget.text.length) {
        t.cancel();
        widget.onComplete?.call();
        return;
      }
      setState(() => _visibleLength++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text.substring(0, _visibleLength),
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
