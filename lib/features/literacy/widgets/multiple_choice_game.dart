import 'dart:math';
import 'package:flutter/material.dart';
import 'package:brightbound_adventures/features/literacy/models/question.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

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
  int? _selectedIndex;
  bool _answered = false;
  bool _showHint = false;
  bool _hintUsed = false;
  int _hintsUsedTotal = 0;
  
  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;
  late AnimationController _progressController;

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
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  LiteracyQuestion get _currentQuestion => _shuffledQuestions[_currentIndex];

  double get _progress => (_currentIndex + 1) / _shuffledQuestions.length;

  void _selectAnswer(int index) {
    if (_answered) return;
    
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (_currentQuestion.isCorrect(index)) {
        _correctCount++;
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
      backgroundColor: widget.themeColor.withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        title: Text(widget.skillName),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 600;
            final spacing = isCompact ? 8.0 : 16.0;
            
            return Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: widget.themeColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(widget.themeColor),
                  minHeight: 6,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isCompact ? 12 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Score display
                        _buildScoreCard(isCompact),
                        SizedBox(height: spacing),

                        // Question card
                        _buildQuestionCard(isCompact),
                        SizedBox(height: spacing),

                        // Hint display
                        if (_showHint && _currentQuestion.hint != null)
                          _buildHintCard(),
                        if (_showHint) SizedBox(height: spacing),

                        // Options
                        ..._buildOptions(isCompact),

                        // Feedback and explanation
                        if (_answered) ...[
                          SizedBox(height: spacing),
                          _buildFeedback(isCompact),
                        ],
                      ],
                    ),
                  ),
                ),

                // Next button
                if (_answered) _buildNextButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreCard(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16,
        vertical: isCompact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
            color: Colors.grey.shade300,
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
            color: Colors.grey.shade300,
          ),
          _buildStatColumn(
            icon: Icons.star,
            color: widget.themeColor,
            value: '${((_correctCount / max(1, _currentIndex + (_answered ? 1 : 0))) * 100).toStringAsFixed(0)}%',
            label: 'Accuracy',
            isCompact: isCompact,
          ),
        ],
      ),
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
        Icon(icon, color: color, size: isCompact ? 20 : 24),
        SizedBox(height: isCompact ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isCompact ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isCompact ? 10 : 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.themeColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline,
              size: 32,
              color: widget.themeColor,
            ),
          ),
          const SizedBox(height: 16),
          // Question text
          Text(
            _currentQuestion.question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentQuestion.hint!,
              style: TextStyle(
                color: Colors.amber.shade900,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
          backgroundColor = AppColors.success.withOpacity(0.15);
          borderColor = AppColors.success;
          textColor = AppColors.success;
          trailingIcon = Icons.check_circle;
        } else if (isSelected) {
          backgroundColor = AppColors.error.withOpacity(0.15);
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
          backgroundColor = widget.themeColor.withOpacity(0.15);
          borderColor = widget.themeColor;
          textColor = widget.themeColor;
        } else {
          backgroundColor = Colors.white;
          borderColor = Colors.grey.shade300;
          textColor = Colors.black87;
        }
      }

      return Padding(
        padding: EdgeInsets.only(bottom: isCompact ? 8 : 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: _answered ? null : () => _selectAnswer(index),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 16 : 20,
                  vertical: isCompact ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 2),
                ),
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
                            : (isSelected ? widget.themeColor : Colors.grey.shade400),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D...
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Option text
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
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
                          color: isCorrect ? AppColors.success : AppColors.error,
                          size: 28,
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
              ? AppColors.success.withOpacity(0.1)
              : AppColors.error.withOpacity(0.1),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.themeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastQuestion ? 'See Results' : 'Next Question',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isLastQuestion ? Icons.emoji_events : Icons.arrow_forward,
                ),
              ],
            ),
          ),
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
