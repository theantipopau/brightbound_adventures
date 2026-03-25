import 'dart:math';
import 'package:flutter/material.dart';

class ScreenShaker extends StatefulWidget {
  final Widget child;
  final ScreenShakeController controller;

  const ScreenShaker({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  State<ScreenShaker> createState() => _ScreenShakerState();
}

class _ScreenShakerState extends State<ScreenShaker>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    widget.controller._attach(this);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void shake() {
    _shakeController.forward(from: 0).then((_) => _shakeController.reset());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        if (!_shakeController.isAnimating) return widget.child;
        
        // Random shake offset based on intensity (controller value)
        // We use sine waves for smoother shake
        final dx = sin(_shakeController.value * pi * 8) * (1 - _shakeController.value) * 10;
        final dy = cos(_shakeController.value * pi * 5) * (1 - _shakeController.value) * 5;
        
        return Transform.translate(
          offset: Offset(dx, dy),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

class ScreenShakeController {
  _ScreenShakerState? _state;

  void _attach(_ScreenShakerState state) {
    _state = state;
  }

  void shake() {
    _state?.shake();
  }
}
