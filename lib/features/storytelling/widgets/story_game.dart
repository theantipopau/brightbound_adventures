import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:brightbound_adventures/core/services/audio_manager.dart';
import '../models/question.dart';

/// Interactive storytelling game with book/story theme
class StoryGame extends StatefulWidget {
  final List<StoryQuestion> questions;
  final String skillName;
  final VoidCallback onComplete;
  final Function(int correct, int total, int xpEarned) onFinish;

  const StoryGame({
    super.key,
    required this.questions,
    required this.skillName,
    required this.onComplete,
    required this.onFinish,
  });

  @override
  State<StoryGame> createState() => _StoryGameState();
}

class _StoryGameState extends State<StoryGame> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _currentStreak = 0;
  int? _selectedAnswer;
  bool _showFeedback = false;
  bool _isCorrect = false;
  final AudioManager _audioManager = AudioManager();
  
  late AnimationController _pageController;
  late AnimationController _sparkleController;
  late AnimationController _characterController;
  late Animation<double> _pageAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _characterBounce;
  
  final List<_FloatingElement> _floatingElements = [];

  @override
  void initState() {
    super.initState();
    
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pageAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutBack,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _sparkleAnimation = CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeOut,
    );
    
    _characterController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _characterBounce = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _characterController, curve: Curves.easeInOut),
    );
    
    _pageController.forward();
    _generateFloatingElements();
  }

  void _generateFloatingElements() {
    final random = math.Random();
    final emojis = ['📚', '✨', '🌟', '📖', '✏️', '🎭', '💫', '🦋'];
    
    for (int i = 0; i < 12; i++) {
      _floatingElements.add(_FloatingElement(
        emoji: emojis[random.nextInt(emojis.length)],
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.3 + random.nextDouble() * 0.7,
        size: 20 + random.nextDouble() * 20,
      ));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sparkleController.dispose();
    _characterController.dispose();
    super.dispose();
  }

  StoryQuestion get _currentQuestion => widget.questions[_currentIndex];

  void _selectAnswer(int index) {
    if (_showFeedback) return;
    
    setState(() {
      _selectedAnswer = index;
      _showFeedback = true;
      _isCorrect = index == _currentQuestion.correctIndex;
      
      if (_isCorrect) {
        _correctAnswers++;
        _currentStreak++;
        _sparkleController.forward(from: 0);
        
        // Play appropriate celebration sound based on streak
        if (_currentStreak >= 3) {
          _audioManager.playStreak(_currentStreak);
        } else {
          _audioManager.playCorrectAnswer();
        }
      } else {
        _currentStreak = 0;
        _audioManager.playIncorrectAnswer();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      _pageController.reverse().then((_) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _showFeedback = false;
        });
        _pageController.forward();
      });
    } else {
      // Game complete
      final xpEarned = _correctAnswers * 15 + 
          (_correctAnswers == widget.questions.length ? 25 : 0);
      
      // Play celebration sound for perfect score
      if (_correctAnswers == widget.questions.length) {
        _audioManager.playPerfectScore();
      }
      
      widget.onFinish(_correctAnswers, widget.questions.length, xpEarned);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating background elements
              ..._buildFloatingElements(),
              
              // Main content
              Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildQuestionCard()),
                  _buildProgressIndicator(),
                ],
              ),
              
              // Character guide
              _buildCharacterGuide(),
              
              // Sparkles for correct answer
              if (_showFeedback && _isCorrect) _buildSparkles(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingElements() {
    return _floatingElements.map((element) {
      return AnimatedBuilder(
        animation: _characterController,
        builder: (context, child) {
          final offset = math.sin(DateTime.now().millisecondsSinceEpoch / 1000 * element.speed) * 20;
          return Positioned(
            left: MediaQuery.of(context).size.width * element.x,
            top: MediaQuery.of(context).size.height * element.y + offset,
            child: Opacity(
              opacity: 0.3,
              child: Text(
                element.emoji,
                style: TextStyle(fontSize: element.size),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.skillName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Question ${_currentIndex + 1} of ${widget.questions.length}',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_correctAnswers',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return AnimatedBuilder(
      animation: _pageAnimation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY((1 - _pageAnimation.value) * math.pi / 2),
          alignment: Alignment.center,
          child: Opacity(
            opacity: _pageAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple.shade900.withValues(alpha: 0.8),
                Colors.indigo.shade900.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Question emoji
                if (_currentQuestion.imageEmoji != null) ...[
                  Text(
                    _currentQuestion.imageEmoji!,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Question text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _currentQuestion.question,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width < 600 ? 18 : 20,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Answer options
                ..._currentQuestion.options.asMap().entries.map((entry) {
                  return _buildAnswerOption(entry.key, entry.value);
                }),
                
                // Feedback section
                if (_showFeedback) ...[
                  const SizedBox(height: 16),
                  _buildFeedback(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(int index, String text) {
    final isSelected = _selectedAnswer == index;
    final isCorrectAnswer = index == _currentQuestion.correctIndex;
    
    Color bgColor = Colors.white.withValues(alpha: 0.1);
    Color borderColor = Colors.white.withValues(alpha: 0.3);
    Color textColor = Colors.white;
    
    if (_showFeedback) {
      if (isCorrectAnswer) {
        bgColor = Colors.green.withValues(alpha: 0.3);
        borderColor = Colors.green;
        textColor = Colors.greenAccent;
      } else if (isSelected && !isCorrectAnswer) {
        bgColor = Colors.red.withValues(alpha: 0.3);
        borderColor = Colors.red;
        textColor = Colors.redAccent;
      }
    } else if (isSelected) {
      bgColor = Colors.purple.withValues(alpha: 0.3);
      borderColor = Colors.purple.shade300;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showFeedback ? null : () => _selectAnswer(index),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: borderColor.withValues(alpha: 0.3),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      height: 1.3,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_showFeedback && isCorrectAnswer)
                  const Icon(Icons.check_circle, color: Colors.greenAccent),
                if (_showFeedback && isSelected && !isCorrectAnswer)
                  const Icon(Icons.cancel, color: Colors.redAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect 
            ? Colors.green.withValues(alpha: 0.2) 
            : Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCorrect ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isCorrect ? Icons.celebration : Icons.lightbulb,
                color: _isCorrect ? Colors.greenAccent : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                _isCorrect ? 'Excellent! 🌟' : 'Good try!',
                style: TextStyle(
                  color: _isCorrect ? Colors.greenAccent : Colors.orange,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (_currentQuestion.explanation != null) ...[
            const SizedBox(height: 8),
            Text(
              _currentQuestion.explanation!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.questions.length, (index) {
              Color dotColor;
              if (index < _currentIndex) {
                dotColor = Colors.green;
              } else if (index == _currentIndex) {
                dotColor = Colors.purple;
              } else {
                dotColor = Colors.white24;
              }
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _currentIndex ? 24 : 12,
                height: 12,
                decoration: BoxDecoration(
                  color: dotColor,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: index == _currentIndex
                      ? [BoxShadow(color: Colors.purple.withValues(alpha: 0.5), blurRadius: 8)]
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          if (_currentQuestion.hint != null && !_showFeedback)
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Text('💡 '),
                        Expanded(child: Text(_currentQuestion.hint!)),
                      ],
                    ),
                    backgroundColor: Colors.purple.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              icon: const Icon(Icons.lightbulb_outline, color: Colors.amber),
              label: const Text('Need a hint?', style: TextStyle(color: Colors.amber)),
            ),
        ],
      ),
    );
  }

  Widget _buildCharacterGuide() {
    return AnimatedBuilder(
      animation: _characterBounce,
      builder: (context, child) {
        return Positioned(
          bottom: 100 + _characterBounce.value,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade900.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.purple.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Text('📚', style: TextStyle(fontSize: 32)),
          ),
        );
      },
    );
  }

  Widget _buildSparkles() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _SparklePainter(_sparkleAnimation.value),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingElement {
  final String emoji;
  final double x;
  final double y;
  final double speed;
  final double size;

  _FloatingElement({
    required this.emoji,
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
  });
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final List<_Sparkle> sparkles = [];
  
  _SparklePainter(this.progress) {
    final random = math.Random(42);
    for (int i = 0; i < 20; i++) {
      sparkles.add(_Sparkle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 4 + random.nextDouble() * 8,
        angle: random.nextDouble() * 2 * math.pi,
      ));
    }
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withValues(alpha: 1.0 - progress)
      ..style = PaintingStyle.fill;
    
    for (final sparkle in sparkles) {
      final x = size.width * sparkle.x;
      final y = size.height * sparkle.y - (progress * 100);
      final sparkleSize = sparkle.size * (1 - progress);
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(sparkle.angle + progress * math.pi);
      
      // Draw 4-pointed star
      final path = Path();
      path.moveTo(0, -sparkleSize);
      path.lineTo(sparkleSize * 0.3, -sparkleSize * 0.3);
      path.lineTo(sparkleSize, 0);
      path.lineTo(sparkleSize * 0.3, sparkleSize * 0.3);
      path.lineTo(0, sparkleSize);
      path.lineTo(-sparkleSize * 0.3, sparkleSize * 0.3);
      path.lineTo(-sparkleSize, 0);
      path.lineTo(-sparkleSize * 0.3, -sparkleSize * 0.3);
      path.close();
      
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Sparkle {
  final double x;
  final double y;
  final double size;
  final double angle;
  
  _Sparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.angle,
  });
}
