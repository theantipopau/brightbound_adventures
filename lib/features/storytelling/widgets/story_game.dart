import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'package:brightbound_adventures/core/services/audio_manager.dart';
import 'package:brightbound_adventures/core/services/adaptive_difficulty_service.dart';
import 'package:brightbound_adventures/core/services/tts_service.dart';
import 'package:brightbound_adventures/core/services/ai_learning_assistant_service.dart';
import 'package:brightbound_adventures/ui/widgets/animated_answer_option.dart';
import 'package:brightbound_adventures/ui/widgets/quiz_widgets.dart';
import 'package:brightbound_adventures/ui/widgets/difficulty_indicator.dart';
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
  late FocusNode _focusNode;
  int _correctAnswers = 0;
  int _currentStreak = 0;
  int? _selectedAnswer;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _autoReadQuestions = false;
  bool _aiHintsEnabled = false;
  bool _aiExplanationsEnabled = false;
  bool _aiCloudMode = false;
  String? _aiExplanationText;
  final AudioManager _audioManager = AudioManager();
  final AiLearningAssistantService _aiAssistant = AiLearningAssistantService();

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
    _loadAutoReadPreference();
    _loadAiPreferences();

    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
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
    _focusNode.dispose();
    _pageController.dispose();
    _sparkleController.dispose();
    _characterController.dispose();
    super.dispose();
  }

  StoryQuestion get _currentQuestion => widget.questions[_currentIndex];

  Future<void> _loadAutoReadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final autoRead = prefs.getBool('autoReadQuestions') ?? false;
    if (!mounted) return;

    setState(() => _autoReadQuestions = autoRead);

    if (autoRead) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _readCurrentQuestionAloud();
      });
    }
  }

  Future<void> _readCurrentQuestionAloud() async {
    if (!_autoReadQuestions || _showFeedback) return;
    final questionText = _currentQuestion.question.trim();
    if (questionText.isEmpty) return;
    await TtsService().speak(questionText);
  }

  Future<void> _loadAiPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final hintsEnabled = prefs.getBool('aiHintsEnabled') ?? false;
    final explanationsEnabled = prefs.getBool('aiExplanationsEnabled') ?? false;
    final cloudMode = prefs.getBool('aiCloudMode') ?? false;
    if (!mounted) return;
    setState(() {
      _aiHintsEnabled = hintsEnabled;
      _aiExplanationsEnabled = explanationsEnabled;
      _aiCloudMode = cloudMode;
    });
    _aiAssistant.setEnabled(_aiHintsEnabled || _aiExplanationsEnabled);
    _aiAssistant.setCloudMode(_aiCloudMode);
  }

  Future<void> _prepareAiExplanation() async {
    if (!_aiExplanationsEnabled || _currentIndex >= widget.questions.length) {
      return;
    }
    try {
      final explanation = await _aiAssistant.explainAnswer(
        question: _currentQuestion.question,
        correctAnswer: _currentQuestion.options[_currentQuestion.correctIndex],
        selectedAnswer: _selectedAnswer != null ? _currentQuestion.options[_selectedAnswer!] : '',
      );
      if (mounted) {
        setState(() => _aiExplanationText = explanation);
      }
    } catch (e) {
      debugPrint('AI explanation error: $e');
    }
  }

  static const List<String> _optionLetters = ['A', 'B', 'C', 'D', 'E'];

  AnswerState _getOptionState(int index) {
    if (!_showFeedback) {
      return _selectedAnswer == index ? AnswerState.selected : AnswerState.idle;
    }
    if (_currentQuestion.correctIndex == index) return AnswerState.correct;
    if (_selectedAnswer == index) return AnswerState.incorrect;
    return AnswerState.idle;
  }

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

    if (_isCorrect) showFloatingReward(context, '+10 ⭐', color: Colors.cyanAccent);
    _prepareAiExplanation();

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
        _readCurrentQuestionAloud();
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

  Future<void> _goHome() async {
    final shouldExit = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Exit to Home?'),
            content: const Text(
                'Your progress in this story challenge will not be saved.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text('Exit Home',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldExit && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
          if (_selectedAnswer != null && _selectedAnswer! > 0) {
            setState(() => _selectedAnswer = _selectedAnswer! - 1);
          } else if (_selectedAnswer == null) {
            setState(() => _selectedAnswer = 0);
          }
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
          if (_selectedAnswer != null &&
              _selectedAnswer! < _currentQuestion.options.length - 1) {
            setState(() => _selectedAnswer = _selectedAnswer! + 1);
          } else if (_selectedAnswer == null) {
            setState(() => _selectedAnswer = 0);
          }
        } else if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
            !_showFeedback) {
          _selectAnswer(_selectedAnswer ?? -1);
        }
      },
      child: Scaffold(
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
      ),
    );
  }

  List<Widget> _buildFloatingElements() {
    return _floatingElements.map((element) {
      return AnimatedBuilder(
        animation: _characterController,
        builder: (context, child) {
          final offset = math.sin(DateTime.now().millisecondsSinceEpoch /
                  1000 *
                  element.speed) *
              20;
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
          Tooltip(
            message: 'Go home',
            child: GestureDetector(
              onTap: _goHome,
              child: Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                ),
                child: Image.asset('assets/images/scroll.PNG', fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(width: 4),
          TtsSpeakerButton(
            text: _currentQuestion.question,
            color: Colors.white,
            size: 44,
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
                // Difficulty indicator
                Consumer<AdaptiveDifficultyService>(
                  builder: (context, difficultySvc, _) {
                    final difficulty = widget.questions.isNotEmpty
                        ? difficultySvc
                            .getDifficultyForSkill(widget.questions[0].skillId)
                        : 1;
                    return Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: DifficultyIndicator(
                        difficulty: difficulty,
                        color: Colors.white,
                        compact: true,
                      ),
                    );
                  },
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
                Colors.purple.shade900.withValues(alpha: 0.85),
                Colors.indigo.shade900.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 2.5,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                // Question emoji - animated with bounce
                if (_currentQuestion.imageEmoji != null) ...[
                  AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, _) {
                      final bounce =
                          math.sin(_pageController.value * 3.14159 * 2) * 12;
                      final scale = 0.92 +
                          math.sin(_pageController.value * 3.14159) * 0.1;
                      return Transform.translate(
                        offset: Offset(0, bounce),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.purple.withValues(alpha: 0.3),
                                  Colors.purple.withValues(alpha: 0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Text(
                              _currentQuestion.imageEmoji!,
                              style: const TextStyle(fontSize: 72),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // Question text with better styling
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black26.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _currentQuestion.question,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              MediaQuery.of(context).size.width < 600 ? 20 : 24,
                          fontWeight: FontWeight.w700,
                          height: 1.6,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Question counter
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Question ${_currentIndex + 1} of ${widget.questions.length}',
                          style: const TextStyle(
                            color: Colors.purpleAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Answer options
                ..._currentQuestion.options.asMap().entries.map((entry) {
                  return AnimatedAnswerOption(
                    key: ValueKey('${_currentIndex}_${entry.key}'),
                    label: entry.value,
                    optionLetter:
                        _optionLetters[entry.key % _optionLetters.length],
                    state: _getOptionState(entry.key),
                    isSelected: _selectedAnswer == entry.key,
                    onTap:
                        _showFeedback ? null : () => _selectAnswer(entry.key),
                    accentColor: Colors.purpleAccent,
                    animationDelay: entry.key * 60,
                  );
                }),

                // Feedback section
                if (_showFeedback) ...[
                  const SizedBox(height: 20),
                  _buildFeedback(),
                ],
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
          if (_aiExplanationText != null) ...[
            const SizedBox(height: 12),
            Text(
              _aiExplanationText!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ] else if (_currentQuestion.explanation != null) ...[
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
                      ? [
                          BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.5),
                              blurRadius: 8)
                        ]
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          if (!_showFeedback && ((_currentQuestion.hint?.isNotEmpty ?? false) || _aiHintsEnabled))
            TextButton.icon(
              onPressed: () => _showHint(),
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

  Future<void> _showHint() async {
    String hintText = _currentQuestion.hint ?? '';
    if (_aiHintsEnabled && hintText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Text('⏳ '),
                Expanded(child: Text('Generating hint with AI...')),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
      try {
        hintText = await _aiAssistant.generateHint(
          question: _currentQuestion.question,
          options: _currentQuestion.options,
        );
      } catch (e) {
        hintText = _currentQuestion.hint ?? 'Could not generate hint';
        debugPrint('AI hint error: $e');
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('💡 '),
              Expanded(child: Text(hintText)),
            ],
          ),
          backgroundColor: Colors.purple.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
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
