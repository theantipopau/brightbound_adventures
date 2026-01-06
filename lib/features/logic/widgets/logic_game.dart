import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/question.dart';

/// Interactive logic puzzle game with mountain/peaks theme
class LogicGame extends StatefulWidget {
  final List<LogicQuestion> questions;
  final String skillName;
  final VoidCallback onComplete;
  final Function(int correct, int total, int xpEarned) onFinish;

  const LogicGame({
    super.key,
    required this.questions,
    required this.skillName,
    required this.onComplete,
    required this.onFinish,
  });

  @override
  State<LogicGame> createState() => _LogicGameState();
}

class _LogicGameState extends State<LogicGame> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int? _selectedAnswer;
  bool _showFeedback = false;
  bool _isCorrect = false;

  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _celebrationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  LogicQuestion get _currentQuestion => widget.questions[_currentIndex];

  void _selectAnswer(int index) {
    if (_showFeedback) return;

    setState(() {
      _selectedAnswer = index;
      _showFeedback = true;
      _isCorrect = index == _currentQuestion.correctIndex;

      if (_isCorrect) {
        _correctAnswers++;
        _celebrationController.forward(from: 0);
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
      _slideController.reverse().then((_) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _showFeedback = false;
        });
        _slideController.forward();
      });
    } else {
      final xpEarned = _correctAnswers * 18 +
          (_correctAnswers == widget.questions.length ? 30 : 0);
      widget.onFinish(_correctAnswers, widget.questions.length, xpEarned);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C3E50), // Dark slate
              Color(0xFF34495E), // Wet asphalt
              Color(0xFF5D6D7E), // Grey blue
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Mountain background
              _buildMountainBackground(),

              // Main content
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildQuestionCard(),
                    ),
                  ),
                  _buildProgressBar(),
                ],
              ),

              // Celebration effect
              if (_showFeedback && _isCorrect) _buildCelebration(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMountainBackground() {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height),
      painter: _MountainPainter(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon:
                const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏔️', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      widget.skillName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Puzzle ${_currentIndex + 1} of ${widget.questions.length}',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ),
          ),
          // Score display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.teal.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology, color: Colors.tealAccent, size: 20),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueGrey.shade800.withValues(alpha: 0.9),
              Colors.blueGrey.shade900.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: Colors.teal.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Question emoji
              if (_currentQuestion.imageEmoji != null) ...[
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _showFeedback ? 1.0 : _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.teal.withValues(alpha: 0.2),
                    ),
                    child: Text(
                      _currentQuestion.imageEmoji!,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Question text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _currentQuestion.question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 24),

              // Answer options
              ..._currentQuestion.options.asMap().entries.map((entry) {
                return _buildAnswerOption(entry.key, entry.value);
              }),

              // Feedback
              if (_showFeedback) ...[
                const SizedBox(height: 16),
                _buildFeedback(),
              ],

              // Hint button
              if (!_showFeedback && _currentQuestion.hint != null) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => _showHint(),
                  icon: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                  label: const Text('Need a hint?',
                      style: TextStyle(color: Colors.amber)),
                ),
              ],
            ],
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
    IconData? icon;

    if (_showFeedback) {
      if (isCorrectAnswer) {
        bgColor = Colors.green.withValues(alpha: 0.3);
        borderColor = Colors.green;
        textColor = Colors.greenAccent;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrectAnswer) {
        bgColor = Colors.red.withValues(alpha: 0.3);
        borderColor = Colors.red;
        textColor = Colors.redAccent;
        icon = Icons.cancel;
      }
    } else if (isSelected) {
      bgColor = Colors.teal.withValues(alpha: 0.3);
      borderColor = Colors.tealAccent;
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: borderColor.withValues(alpha: 0.3),
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                      fontSize: MediaQuery.of(context).size.width < 600 ? 13 : 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      height: 1.3,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null)
                  Icon(icon, color: textColor, size: 24),
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
                _isCorrect ? Icons.emoji_events : Icons.psychology,
                color: _isCorrect ? Colors.greenAccent : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                _isCorrect ? 'Brilliant! 🎯' : 'Good thinking!',
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

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Mountain climb progress visualization
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.questions.length, (index) {
              final isCompleted = index < _currentIndex;
              final isCurrent = index == _currentIndex;

              return Row(
                children: [
                  Container(
                    width: isCurrent ? 40 : 24,
                    height: isCurrent ? 40 : 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? Colors.tealAccent
                          : (isCurrent
                              ? Colors.teal
                              : Colors.white.withValues(alpha: 0.2)),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: Colors.teal.withValues(alpha: 0.5),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.black, size: 16)
                          : (isCurrent
                              ? const Icon(Icons.landscape,
                                  color: Colors.white, size: 20)
                              : null),
                    ),
                  ),
                  if (index < widget.questions.length - 1)
                    Container(
                      width: 20,
                      height: 3,
                      color: isCompleted
                          ? Colors.tealAccent
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '${((_currentIndex + 1) / widget.questions.length * 100).round()}% complete',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebration() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _StarBurstPainter(_celebrationController.value),
            ),
          ),
        );
      },
    );
  }

  void _showHint() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('💡 '),
            Expanded(child: Text(_currentQuestion.hint!)),
          ],
        ),
        backgroundColor: Colors.teal.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Back mountains (darker)
    final backPaint = Paint()
      ..color = const Color(0xFF1A2634)
      ..style = PaintingStyle.fill;

    final backPath = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.15, size.height * 0.5)
      ..lineTo(size.width * 0.35, size.height * 0.65)
      ..lineTo(size.width * 0.5, size.height * 0.4)
      ..lineTo(size.width * 0.7, size.height * 0.55)
      ..lineTo(size.width * 0.85, size.height * 0.35)
      ..lineTo(size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(backPath, backPaint);

    // Front mountains (slightly lighter)
    final frontPaint = Paint()
      ..color = const Color(0xFF243447)
      ..style = PaintingStyle.fill;

    final frontPath = Path()
      ..moveTo(0, size.height * 0.85)
      ..lineTo(size.width * 0.2, size.height * 0.7)
      ..lineTo(size.width * 0.4, size.height * 0.8)
      ..lineTo(size.width * 0.6, size.height * 0.65)
      ..lineTo(size.width * 0.8, size.height * 0.75)
      ..lineTo(size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(frontPath, frontPaint);

    // Snow caps
    final snowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final snow1 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.4)
      ..lineTo(size.width * 0.45, size.height * 0.45)
      ..lineTo(size.width * 0.55, size.height * 0.45)
      ..close();
    canvas.drawPath(snow1, snowPaint);

    final snow2 = Path()
      ..moveTo(size.width * 0.85, size.height * 0.35)
      ..lineTo(size.width * 0.8, size.height * 0.4)
      ..lineTo(size.width * 0.9, size.height * 0.4)
      ..close();
    canvas.drawPath(snow2, snowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarBurstPainter extends CustomPainter {
  final double progress;

  _StarBurstPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(42);

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final distance = progress * 200;
      final starSize = 8 * (1 - progress);

      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      final paint = Paint()
        ..color = Colors.tealAccent.withValues(alpha: 1 - progress)
        ..style = PaintingStyle.fill;

      // Draw star
      final starPath = _createStarPath(x, y, starSize, 5 + random.nextInt(3));
      canvas.drawPath(starPath, paint);
    }
  }

  Path _createStarPath(double cx, double cy, double size, int points) {
    final path = Path();
    final step = math.pi / points;

    for (int i = 0; i < 2 * points; i++) {
      final r = (i % 2 == 0) ? size : size / 2;
      final angle = i * step - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
