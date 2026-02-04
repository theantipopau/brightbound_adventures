import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:brightbound_adventures/ui/themes/index.dart'; 
import 'package:brightbound_adventures/ui/widgets/animated_character.dart';

/// Fun loading screen with educational tips and animated background
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
  late AnimationController _backgroundController;
  
  String _currentTip = '';
  // Pick a random character for variety each load
  final List<String> _characters = ['warrior', 'mage', 'rogue', 'cleric'];
  late String _randomCharacter;
  
  Timer? _tipTimer;
  int _dotCount = 0;
  Timer? _dotTimer;

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
    '🪐 The Number Nebula is infinite!',
    '📝 Writers Realm is full of stories waiting to be told.',
    '🐨 Kangaroos can jump up to 30 feet in a single hop!',
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
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    // Cycle tips every 4 seconds
    _tipTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentTip = tips[Random().nextInt(tips.length)];
        });
      }
    });

    // Animate "..." dots
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4; 
        });
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _backgroundController.dispose();
    _tipTimer?.cancel();
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate some random shapes for the background
    final random = Random(42); 
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _BackgroundPainter(_backgroundController.value),
                );
              },
            ),
          ),
          
          SafeArea(
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
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                           // Add a shadow below
                           Positioned(
                             bottom: 20,
                             child: Container(
                               width: 60,
                               height: 10,
                               decoration: BoxDecoration(
                                 color: Colors.black.withOpacity(0.2),
                                 borderRadius: BorderRadius.circular(50),
                               ),
                             ),
                           ),
                           AnimatedCharacter(
                             character: _randomCharacter,
                             size: 120,
                             animation: CharacterAnimation.walking, // Looks like running with the bounce
                             showParticles: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Loading message with animated dots
                  Text(
                    '${widget.message ?? 'Loading'}${"." * _dotCount}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(2,2))
                      ]
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Educational tip card
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
                        child: child,
                      ));
                    },
                    child: Container(
                      key: ValueKey<String>(_currentTip), // AnimatedSwitcher needs unique key
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 2)
                      ),
                      child: Column(
                        children: [
                          const Text("DID YOU KNOW?", style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.5
                          )),
                          const SizedBox(height: 8),
                          Text(
                            _currentTip,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              height: 1.4,
                              fontFamily: 'Comic Sans MS', // Fallback fun font
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animationValue;
  final Random _random = Random(123); // Seeded for consistency

  _BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Gradient Background
    final Rect rect = Offset.zero & size;
    final Paint gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
           Colors.blue.shade100,
           Colors.purple.shade100,
           Colors.orange.shade50,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, gradientPaint);

    // Moving shapes
    for(int i=0; i<10; i++) {
       final double speed = 0.2 + (_random.nextDouble() * 0.5);
       final double x = (_random.nextDouble() * size.width + (animationValue * size.width * speed)) % (size.width + 100) - 50;
       final double y = _random.nextDouble() * size.height;
       final double radius = 20 + _random.nextDouble() * 40;
       
       final paint = Paint()
         ..color = Colors.white.withOpacity(0.3)
         ..style = PaintingStyle.fill;
         
       canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
     return oldDelegate.animationValue != animationValue;
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
