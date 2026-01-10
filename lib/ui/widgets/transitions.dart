import 'package:flutter/material.dart';

/// Custom page route with fade and slide transitions
class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Offset beginOffset;

  FadeSlidePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    this.beginOffset = const Offset(0.0, 0.1),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade transition
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            );

            // Slide transition
            final slideAnimation = Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Custom loading widget with animated star
class BrightBoundLoading extends StatefulWidget {
  final String? message;
  final double size;

  const BrightBoundLoading({
    super.key,
    this.message,
    this.size = 80,
  });

  @override
  State<BrightBoundLoading> createState() => _BrightBoundLoadingState();
}

class _BrightBoundLoadingState extends State<BrightBoundLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.8)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 0.3)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.amber.withValues(alpha: _glowAnimation.value),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 3.14159,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: const Text(
                      '⭐',
                      style: TextStyle(fontSize: 64),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 24),
            Text(
              widget.message!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Answer feedback animation - confetti for correct, shake for incorrect
class AnswerFeedbackAnimation extends StatefulWidget {
  final bool isCorrect;
  final Widget child;
  final VoidCallback? onComplete;

  const AnswerFeedbackAnimation({
    super.key,
    required this.isCorrect,
    required this.child,
    this.onComplete,
  });

  @override
  State<AnswerFeedbackAnimation> createState() =>
      _AnswerFeedbackAnimationState();
}

class _AnswerFeedbackAnimationState extends State<AnswerFeedbackAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.isCorrect ? 600 : 400),
      vsync: this,
    );

    if (widget.isCorrect) {
      // Bounce animation for correct
      _animation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 0.95)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.95, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40,
        ),
      ]).animate(_controller);
    } else {
      // Shake animation for incorrect
      _animation = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 10.0),
          weight: 25,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 10.0, end: -10.0),
          weight: 25,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: -10.0, end: 5.0),
          weight: 25,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 5.0, end: 0.0),
          weight: 25,
        ),
      ]).animate(_controller);
    }

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        if (widget.isCorrect) {
          return Transform.scale(
            scale: _animation.value,
            child: child,
          );
        } else {
          return Transform.translate(
            offset: Offset(_animation.value, 0),
            child: child,
          );
        }
      },
      child: widget.child,
    );
  }
}

/// Responsive helper for desktop layouts
class ResponsiveHelper {
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1200;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static double getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) return 48;
    if (isTablet(context)) return 32;
    return 16;
  }

  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    return double.infinity;
  }

  static EdgeInsets getResponsiveInsets(BuildContext context) {
    final padding = getResponsivePadding(context);
    return EdgeInsets.symmetric(horizontal: padding);
  }
}
