import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../core/services/stats_service.dart';

class LevelUpDialog extends StatefulWidget {
  final LevelUpResult result;

  const LevelUpDialog({
    super.key,
    required this.result,
  });

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ConfettiController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.amber,
              Colors.orange,
              Colors.yellow,
              Colors.red,
              Colors.pink,
              Colors.purple,
            ],
          ),
        ),
        
        // Dialog
        Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.shade700,
                    Colors.blue.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trophy Icon
                  const Text(
                    '🏆',
                    style: TextStyle(fontSize: 80),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Title
                  const Text(
                    'LEVEL UP!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Level display
                  Text(
                    'Level ${widget.result.oldLevel} ➜ Level ${widget.result.newLevel}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade300,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // XP gained
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '⭐',
                          style: TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+${widget.result.xpGained} XP',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Encouraging message
                  Text(
                    _getEncouragingMessage(widget.result.newLevel),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Continue button
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'Continue Adventure!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getEncouragingMessage(int level) {
    if (level == 3) return "Number Nebula is now unlocked!";
    if (level == 5) return "Story Springs is now unlocked!";
    if (level == 7) return "Puzzle Peaks is now unlocked!";
    if (level == 10) return "Adventure Arena is now unlocked!";
    
    final messages = [
      "You're doing amazing!",
      "Keep up the great work!",
      "Your skills are growing!",
      "What an achievement!",
      "You're unstoppable!",
      "Brilliant progress!",
      "You're a star learner!",
      "Keep reaching for the stars!",
    ];
    
    return messages[level % messages.length];
  }
}

/// Show level up dialog and return when dismissed
Future<void> showLevelUpDialog(BuildContext context, LevelUpResult result) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => LevelUpDialog(result: result),
  );
}
