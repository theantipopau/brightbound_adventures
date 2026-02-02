import 'dart:math';
import 'package:flutter/material.dart';
import 'package:brightbound_adventures/ui/themes/index.dart'; // Ensure colors available if needed
import 'package:brightbound_adventures/ui/widgets/animated_character.dart';

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
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  String _currentTip = '';
  // Pick a random character for variety each load
  final List<String> _characters = ['warrior', 'mage', 'rogue', 'cleric'];
  late String _randomCharacter;

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
    _randomCharacter = _characters[Random().nextInt(_characters.length)];

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600), // Faster bounce for running
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
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
                // Animated Character Running
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_bounceAnimation.value),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.8),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                    child: AnimatedCharacter(
                       character: _randomCharacter,
                       size: 120,
                       animation: CharacterAnimation.walking, // Looks like running with the bounce
                       showParticles: true,
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
