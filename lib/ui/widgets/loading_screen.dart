import 'dart:math';
import 'package:flutter/material.dart';

/// Fun loading screen with educational tips
class LoadingScreen extends StatefulWidget {
  final String? message;
  final List<String>? tips;
  
  const LoadingScreen({
    super.key,
    this.message,
    this.tips,
  });
  
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  String _currentTip = '';
  
  static const List<String> _defaultTips = [
    '💡 Did you know? Your brain is like a muscle - the more you use it, the stronger it gets!',
    '🌟 Keep practicing! Every mistake helps you learn something new.',
    '🚀 Learning is an adventure! Have fun exploring new things.',
    '📚 Reading every day makes you smarter and more creative!',
    '🎯 Set small goals and celebrate when you reach them!',
    '🌈 Everyone learns differently - find what works best for you!',
    '⭐ Practice makes progress! You don\'t have to be perfect.',
    '🎨 Use colors and drawings to help you remember things!',
    '🧠 Your brain loves new challenges - don\'t be afraid to try!',
    '💪 Believe in yourself! You can do amazing things!',
  ];
  
  @override
  void initState() {
    super.initState();
    
    final tips = widget.tips ?? _defaultTips;
    _currentTip = tips[Random().nextInt(tips.length)];
    
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _bounceAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _spinController.dispose();
    _bounceController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated loading icon
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_bounceAnimation.value),
                      child: child,
                    );
                  },
                  child: RotationTransition(
                    turns: _spinController,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade400,
                            Colors.blue.shade400,
                            Colors.pink.shade400,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '✨',
                          style: TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Loading message
                Text(
                  widget.message ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Educational tip
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    _currentTip,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple circular progress indicator widget
class CircularLoadingWidget extends StatelessWidget {
  final Color? color;
  final double size;
  
  const CircularLoadingWidget({
    super.key,
    this.color,
    this.size = 40,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation(
          color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
