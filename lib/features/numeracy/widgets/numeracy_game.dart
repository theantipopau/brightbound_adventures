import 'dart:math';
import 'package:flutter/material.dart';
import 'package:brightbound_adventures/features/numeracy/models/question.dart';
import 'package:brightbound_adventures/core/services/audio_manager.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/responsive_quiz_layout.dart';

/// Multiple choice quiz game for numeracy skills
class NumeracyGame extends StatefulWidget {
  final List<NumeracyQuestion> questions;
  final String skillName;
  final Color themeColor;
  final void Function(double accuracy, int correct, int total)? onComplete;
  final VoidCallback? onCancel;

  const NumeracyGame({
    super.key,
    required this.questions,
    required this.skillName,
    this.themeColor = AppColors.numberNebulaColor,
    this.onComplete,
    this.onCancel,
  });

  @override
  State<NumeracyGame> createState() => _NumeracyGameState();
}

class _NumeracyGameState extends State<NumeracyGame>
    with TickerProviderStateMixin {
  late List<NumeracyQuestion> _shuffledQuestions;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _currentStreak = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _showHint = false;
  bool _hintUsed = false;
  final AudioManager _audioManager = AudioManager();

  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;
  late AnimationController _progressController;
  late AnimationController _starController;
  late Animation<double> _starAnimation;

  @override
  void initState() {
    super.initState();
    _shuffledQuestions = List.from(widget.questions)..shuffle(Random());

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _feedbackAnimation = CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _starController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _starAnimation = CurvedAnimation(
      parent: _starController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _progressController.dispose();
    _starController.dispose();
    super.dispose();
  }

  NumeracyQuestion get _currentQuestion => _shuffledQuestions[_currentIndex];

  double get _progress => (_currentIndex + 1) / _shuffledQuestions.length;

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedIndex = index;
      _answered = true;
      final isCorrect = _currentQuestion.isCorrect(index);

      if (isCorrect) {
        _correctCount++;
        _currentStreak++;
        _starController.forward(from: 0);

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

    _feedbackController.forward(from: 0);
  }

  void _nextQuestion() {
    if (_currentIndex < _shuffledQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
        _showHint = false;
        _hintUsed = false;
      });
      _progressController.forward(from: 0);
    } else {
      _completeGame();
    }
  }

  void _completeGame() {
    final accuracy = _correctCount / _shuffledQuestions.length;

    // Play celebration sound for perfect score
    if (accuracy == 1.0) {
      _audioManager.playPerfectScore();
    }

    widget.onComplete?.call(accuracy, _correctCount, _shuffledQuestions.length);
  }

  void _showHintDialog() {
    if (!_hintUsed && _currentQuestion.hint != null) {
      setState(() {
        _showHint = true;
        _hintUsed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeColor.withValues(alpha: 0.05),
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Text('🌌 '),
            Text(widget.skillName),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showExitConfirmation();
          },
        ),
        actions: [
          // Hint button
          if (_currentQuestion.hint != null && !_answered)
            IconButton(
              icon: Icon(
                _showHint ? Icons.lightbulb : Icons.lightbulb_outline,
                color: _showHint ? Colors.yellow : Colors.white,
              ),
              onPressed: _hintUsed ? null : _showHintDialog,
              tooltip: 'Show Hint',
            ),
          // Progress indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIndex + 1}/${_shuffledQuestions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: widget.themeColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(widget.themeColor),
              minHeight: 8,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenBreakpoints.getHorizontalPadding(context),
                  vertical: 16,
                ),
                child: ResponsiveQuizLayout(
                  scoreCard: _buildScoreCard(),
                  questionCard: _buildQuestionCard(),
                  optionsArea: _buildOptionsArea(),
                  feedbackWidget:
                      _answered ? _buildFeedback() : null,
                  maxWidth: ScreenBreakpoints.getMaxContentWidth(context),
                ),
              ),
            ),

            // Next button
            if (_answered)
              Container(
                padding: const EdgeInsets.all(16),
                child: HoverButton(
                  backgroundColor: widget.themeColor,
                  hoverColor: widget.themeColor.withValues(alpha: 0.9),
                  tooltip: _currentIndex < _shuffledQuestions.length - 1
                      ? "Press 'Enter' or click Next"
                      : "Press 'Enter' or click See Results",
                  onPressed: _nextQuestion,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentIndex < _shuffledQuestions.length - 1
                            ? 'Next Question'
                            : 'See Results',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentIndex < _shuffledQuestions.length - 1
                            ? Icons.arrow_forward
                            : Icons.celebration,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeColor.withValues(alpha: 0.1),
            widget.themeColor.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.themeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem('⭐', 'Score', '$_correctCount'),
          Container(
            width: 1,
            height: 40,
            color: widget.themeColor.withValues(alpha: 0.3),
          ),
          _buildScoreItem('🎯', 'Questions',
              '${_currentIndex + 1}/${_shuffledQuestions.length}'),
          Container(
            width: 1,
            height: 40,
            color: widget.themeColor.withValues(alpha: 0.3),
          ),
          _buildScoreItem(
            '📊',
            'Accuracy',
            _currentIndex > 0
                ? '${((_correctCount / (_currentIndex + (_answered ? 1 : 0))) * 100).round()}%'
                : '-',
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.themeColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 700),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 600 ? 20 : 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    widget.themeColor.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: widget.themeColor.withValues(alpha: 0.25),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.themeColor.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon with enhanced glow and bounce
                  AnimatedBuilder(
                    animation: _feedbackController,
                    builder: (context, _) {
                      final bounce = sin(_feedbackController.value * 3.14159 * 2) * 8;
                      final scale = 0.95 + sin(_feedbackController.value * 3.14159) * 0.08;
                      return Transform.translate(
                        offset: Offset(0, bounce),
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  widget.themeColor.withValues(alpha: 0.25),
                                  widget.themeColor.withValues(alpha: 0.08),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.themeColor.withValues(alpha: 0.5),
                                  blurRadius: 35,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Text(
                              _getQuestionTypeEmoji(),
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width < 600
                                      ? 48
                                      : 56),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      _currentQuestion.question,
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 600 ? 23 : 30,
                        fontWeight: FontWeight.w800,
                        height: 1.5,
                        color: Colors.grey[900],
                        letterSpacing: 0.4,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Question difficulty indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Question ${_currentIndex + 1} of ${_shuffledQuestions.length}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.themeColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getQuestionTypeEmoji() {
    switch (_currentQuestion.type) {
      case NumeracyQuestionType.counting:
        return '🔢';
      case NumeracyQuestionType.numberLine:
        return '📏';
      case NumeracyQuestionType.visualMath:
        return '🎨';
      case NumeracyQuestionType.patternRecognition:
        return '🔮';
      default:
        return '🌟';
    }
  }

  Widget _buildHintCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber[50]!,
            Colors.orange[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber[300]!,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated hint icon
          AnimatedBuilder(
            animation: _feedbackController,
            builder: (context, _) {
              final scale = 0.95 + sin(_feedbackController.value * 3.14159) * 0.05;
              return Transform.scale(
                scale: scale,
                child: const Text('💡', style: TextStyle(fontSize: 28)),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hint',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _currentQuestion.hint!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.amber[900],
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hint display
        if (_showHint && _currentQuestion.hint != null) ...[
          _buildHintCard(),
          const SizedBox(height: 16),
        ],
        // Options
        ..._buildOptions(),
      ],
    );
  }

  List<Widget> _buildOptions() {
    return _currentQuestion.options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final isSelected = _selectedIndex == index;
      final isCorrect = _currentQuestion.correctIndex == index;

      Color backgroundColor;
      Color borderColor;
      IconData? trailingIcon;

      if (_answered) {
        if (isCorrect) {
          backgroundColor = Colors.green[50]!;
          borderColor = Colors.green;
          trailingIcon = Icons.check_circle;
        } else if (isSelected) {
          backgroundColor = Colors.red[50]!;
          borderColor = Colors.red;
          trailingIcon = Icons.cancel;
        } else {
          backgroundColor = Colors.grey[50]!;
          borderColor = Colors.grey[300]!;
        }
      } else {
        backgroundColor = isSelected
            ? widget.themeColor.withValues(alpha: 0.1)
            : Colors.white;
        borderColor = isSelected ? widget.themeColor : Colors.grey[300]!;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: HoverCard(
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          enabled: !_answered,
          onTap: _answered ? null : () => _selectAnswer(index),
          child: Row(
            children: [
              // Option letter badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _answered
                      ? (isCorrect
                          ? Colors.green
                          : (isSelected ? Colors.red : Colors.grey[300]))
                      : widget.themeColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _answered
                          ? (isCorrect || isSelected
                              ? Colors.white
                              : Colors.grey[600])
                          : widget.themeColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width < 600 ? 16 : 18,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: _answered
                        ? (isCorrect
                            ? Colors.green[800]
                            : (isSelected
                                ? Colors.red[800]
                                : Colors.grey[600]))
                        : Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailingIcon != null)
                ScaleTransition(
                  scale: _feedbackAnimation,
                  child: Icon(
                    trailingIcon,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 28,
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildFeedback() {
    final isCorrect = _currentQuestion.isCorrect(_selectedIndex ?? -1);

    return ScaleTransition(
      scale: _feedbackAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isCorrect
                ? [Colors.green[50]!, Colors.green[100]!]
                : [Colors.red[50]!, Colors.orange[50]!],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCorrect ? Colors.green : Colors.red,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (isCorrect ? Colors.green : Colors.red)
                  .withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCorrect)
                  ScaleTransition(
                    scale: _starAnimation,
                    child: const Text('⭐', style: TextStyle(fontSize: 40)),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isCorrect ? 'Excellent! 🎉' : 'Try Again! 💪',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isCorrect ? Colors.green[700] : Colors.red[700],
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                if (isCorrect)
                  ScaleTransition(
                    scale: _starAnimation,
                    child: const Text('⭐', style: TextStyle(fontSize: 40)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress indicator
            if (isCorrect)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.2),
                      Colors.green.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '+1 Star Earned!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                    letterSpacing: 0.3,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withValues(alpha: 0.2),
                      Colors.red.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'The correct answer: ${_currentQuestion.options[_currentQuestion.correctIndex]}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_currentQuestion.explanation != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.8),
                      Colors.blue[50]!.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learn:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _currentQuestion.explanation!,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[800],
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🌌 ', style: TextStyle(fontSize: 24)),
            Text('Leave Practice?'),
          ],
        ),
        content: const Text(
          'Your progress in this session won\'t be saved if you leave now.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Going',
              style: TextStyle(color: widget.themeColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
            ),
            onPressed: () {
              Navigator.pop(context);
              widget.onCancel?.call();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
