import 'dart:math';
import 'package:flutter/material.dart';
import 'package:brightbound_adventures/features/literacy/models/question.dart';
import 'package:brightbound_adventures/core/services/audio_manager.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/responsive_quiz_layout.dart';

/// Multiple choice quiz game for literacy skills
class MultipleChoiceGame extends StatefulWidget {
  final List<LiteracyQuestion> questions;
  final String skillName;
  final Color themeColor;
  final void Function(double accuracy, int correct, int total)? onComplete;
  final VoidCallback? onCancel;

  const MultipleChoiceGame({
    super.key,
    required this.questions,
    required this.skillName,
    this.themeColor = AppColors.wordWoodsColor,
    this.onComplete,
    this.onCancel,
  });

  @override
  State<MultipleChoiceGame> createState() => _MultipleChoiceGameState();
}

class _MultipleChoiceGameState extends State<MultipleChoiceGame>
    with TickerProviderStateMixin {
  late List<LiteracyQuestion> _shuffledQuestions;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _currentStreak = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _showHint = false;
  bool _hintUsed = false;
  int _hintsUsedTotal = 0;
  final AudioManager _audioManager = AudioManager();

  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;
  late AnimationController _progressController;
  late AnimationController _sparkleController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _shuffledQuestions = List.from(widget.questions)..shuffle(Random());

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ),
    );
    _feedbackAnimation = CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _progressController.dispose();
    _sparkleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  LiteracyQuestion get _currentQuestion => _shuffledQuestions[_currentIndex];

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
        _hintsUsedTotal++;
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
        title: Text(widget.skillName),
        leading: Tooltip(
          message: '🚪 Go Back',
          textStyle: const TextStyle(fontSize: 16, color: Colors.white),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _showExitConfirmation();
            },
          ),
        ),
        actions: [
          // Hint button
          if (_currentQuestion.hint != null && !_answered)
            Tooltip(
              message:
                  _hintUsed ? '💡 Hint Used!' : '💡 Need Help? Tap for a Hint!',
              textStyle: const TextStyle(fontSize: 16, color: Colors.white),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ScaleTransition(
                scale: _hintUsed
                    ? const AlwaysStoppedAnimation(1.0)
                    : _bounceAnimation,
                child: IconButton(
                  icon: Icon(
                    _showHint ? Icons.lightbulb : Icons.lightbulb_outline,
                    color: _showHint ? Colors.yellow : Colors.white,
                  ),
                  onPressed: _hintUsed
                      ? null
                      : () {
                          _bounceController.forward(from: 0);
                          _showHintDialog();
                        },
                ),
              ),
            ),
          // Progress indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${_shuffledQuestions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
                  vertical: 12,
                ),
                child: ResponsiveQuizLayout(
                  scoreCard: _buildScoreCard(false),
                  questionCard: _buildQuestionCard(false),
                  optionsArea: _buildOptionsArea(),
                  feedbackWidget: _answered ? _buildFeedback(false) : null,
                  maxWidth: ScreenBreakpoints.getMaxContentWidth(context),
                ),
              ),
            ),

            // Next button
            if (_answered) _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(bool isCompact) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 16,
            vertical: isCompact ? 6 : 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                widget.themeColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.themeColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: widget.themeColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                icon: Icons.check_circle,
                color: AppColors.success,
                value: '$_correctCount',
                label: 'Correct',
                isCompact: isCompact,
              ),
              Container(
                width: 1,
                height: isCompact ? 30 : 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.grey.shade300,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              _buildStatColumn(
                icon: Icons.lightbulb,
                color: Colors.amber,
                value: '$_hintsUsedTotal',
                label: 'Hints',
                isCompact: isCompact,
              ),
              Container(
                width: 1,
                height: isCompact ? 30 : 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.grey.shade300,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              _buildStatColumn(
                icon: Icons.star,
                color: widget.themeColor,
                value:
                    '${((_correctCount / max(1, _currentIndex + (_answered ? 1 : 0))) * 100).toStringAsFixed(0)}%',
                label: 'Accuracy',
                isCompact: isCompact,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    bool isCompact = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: isCompact ? 18 : 24),
        SizedBox(height: isCompact ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isCompact ? 14 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isCompact ? 9 : 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(bool isCompact) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(
            opacity: value,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -30,
                  top: -30,
                  child: AnimatedBuilder(
                    animation: _sparkleController,
                    builder: (context, child) {
                      final scale = 0.85 + _sparkleController.value * 0.2;
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: 0.35 + _sparkleController.value * 0.25,
                          child: child,
                        ),
                      );
                    },
                    child: _buildGlowCircle(
                        widget.themeColor.withValues(alpha: 0.25), 90),
                  ),
                ),
                Positioned(
                  right: -25,
                  bottom: -20,
                  child: AnimatedBuilder(
                    animation: _sparkleController,
                    builder: (context, child) {
                      final offset = sin(_sparkleController.value * pi * 2) * 6;
                      return Transform.translate(
                        offset: Offset(offset, offset / 2),
                        child: Opacity(
                          opacity: 0.2 + _sparkleController.value * 0.3,
                          child: child,
                        ),
                      );
                    },
                    child: _buildGlowCircle(
                        widget.themeColor.withValues(alpha: 0.2), 50),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(isCompact ? 16 : 24),
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
                      color: widget.themeColor.withValues(alpha: 0.2),
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
                      // Question icon with animation
                      AnimatedBuilder(
                        animation: _sparkleController,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  widget.themeColor.withValues(
                                      alpha: 0.2 +
                                          _sparkleController.value * 0.15),
                                  widget.themeColor.withValues(alpha: 0.05),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      widget.themeColor.withValues(alpha: 0.4),
                                  blurRadius:
                                      25 + _sparkleController.value * 10,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Text(
                              '📚',
                              style: TextStyle(fontSize: 44),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      // Question text
                      Flexible(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              _currentQuestion.question,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isCompact ? 20 : 26,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                                color: Colors.grey[900],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          _buildStatusChip(
                              '${_currentIndex + 1}/${_shuffledQuestions.length}'),
                          _buildStatusChip('Streak x$_currentStreak'),
                          if (_hintUsed)
                            _buildStatusChip('Hint used',
                                color: Colors.orangeAccent),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHintCard() {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        final bounce = sin(_bounceController.value * 3.14159) * 6;
        final scale = 1.0 + (sin(_bounceController.value * 3.14159) * 0.06);
        return Transform.translate(
          offset: Offset(0, bounce),
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.shade50,
                    Colors.orange.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.amber.shade400,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated icon
                  AnimatedBuilder(
                    animation: _sparkleController,
                    builder: (context, _) {
                      final iconScale = 0.9 + sin(_sparkleController.value * 3.14159) * 0.1;
                      return Transform.scale(
                        scale: iconScale,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.6),
                                blurRadius: 12,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.lightbulb,
                              color: Colors.white, size: 28),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hint for You',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentQuestion.hint!,
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ],
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

  Widget _buildGlowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.8,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, {Color? color}) {
    final chipColor = color ?? widget.themeColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: chipColor,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildOptionsArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showHint && _currentQuestion.hint != null) ...[
          _buildHintCard(),
          const SizedBox(height: 12),
        ],
        ..._buildOptions(false),
      ],
    );
  }

  List<Widget> _buildOptions(bool isCompact) {
    return List.generate(_currentQuestion.options.length, (index) {
      final option = _currentQuestion.options[index];
      final isSelected = _selectedIndex == index;
      final isCorrect = _currentQuestion.correctIndex == index;

      Color backgroundColor;
      Color borderColor;
      Color textColor;
      IconData? trailingIcon;

      if (_answered) {
        if (isCorrect) {
          backgroundColor = AppColors.success.withValues(alpha: 0.15);
          borderColor = AppColors.success;
          textColor = AppColors.success;
          trailingIcon = Icons.check_circle;
        } else if (isSelected) {
          backgroundColor = AppColors.error.withValues(alpha: 0.15);
          borderColor = AppColors.error;
          textColor = AppColors.error;
          trailingIcon = Icons.cancel;
        } else {
          backgroundColor = Colors.grey.shade100;
          borderColor = Colors.grey.shade300;
          textColor = Colors.grey.shade600;
        }
      } else {
        if (isSelected) {
          backgroundColor = widget.themeColor.withValues(alpha: 0.15);
          borderColor = widget.themeColor;
          textColor = widget.themeColor;
        } else {
          backgroundColor = Colors.white;
          borderColor = Colors.grey.shade300;
          textColor = Colors.black87;
        }
      }

      return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: HoverCard(
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          enabled: !_answered,
          onTap: _answered ? null : () => _selectAnswer(index),
          child: Row(
            children: [
              // Option letter
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _answered
                            ? (isCorrect
                                ? AppColors.success
                                : isSelected
                                    ? AppColors.error
                                    : Colors.grey.shade400)
                            : (isSelected
                                ? widget.themeColor
                                : Colors.grey.shade400),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D...
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isCompact ? 14 : 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isCompact ? 12 : 16),
                    // Option text
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: isCompact ? 14 : 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                    // Result icon
                    if (_answered && trailingIcon != null)
                      ScaleTransition(
                        scale: _feedbackAnimation,
                        child: Icon(
                          trailingIcon,
                          color:
                              isCorrect ? AppColors.success : AppColors.error,
                          size: 28,
                        ),
                      ),
                  ],
                ),
            ),
        );
    });
  }

  Widget _buildFeedback(bool isCompact) {
    final isCorrect = _currentQuestion.isCorrect(_selectedIndex!);

    return ScaleTransition(
      scale: _feedbackAnimation,
      child: Container(
        padding: EdgeInsets.all(isCompact ? 12 : 20),
        decoration: BoxDecoration(
          color: isCorrect
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCorrect ? AppColors.success : AppColors.error,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.celebration : Icons.info_outline,
                  color: isCorrect ? AppColors.success : AppColors.error,
                  size: isCompact ? 24 : 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isCorrect ? 'Correct! Great job! 🎉' : 'Not quite right',
                    style: TextStyle(
                      fontSize: isCompact ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            if (_currentQuestion.explanation != null) ...[
              const SizedBox(height: 12),
              Text(
                _currentQuestion.explanation!,
                style: TextStyle(
                  fontSize: isCompact ? 13 : 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final isLastQuestion = _currentIndex >= _shuffledQuestions.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      child: HoverButton(
        backgroundColor: widget.themeColor,
        hoverColor: widget.themeColor.withValues(alpha: 0.9),
        onPressed: _nextQuestion,
        tooltip: isLastQuestion ? 'See Results' : 'Next Question',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLastQuestion ? 'See Results' : 'Next Question',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLastQuestion ? Icons.celebration : Icons.arrow_forward,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Practice?'),
        content: const Text(
          'Your progress in this session will not be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancel?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
}
