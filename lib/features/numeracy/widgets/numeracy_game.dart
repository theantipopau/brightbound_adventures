import 'dart:math';
import 'package:flutter/material.dart';
import 'package:brightbound_adventures/features/numeracy/models/question.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

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
  int? _selectedIndex;
  bool _answered = false;
  bool _showHint = false;
  bool _hintUsed = false;
  
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
      if (_currentQuestion.isCorrect(index)) {
        _correctCount++;
        _starController.forward(from: 0);
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
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
              backgroundColor: widget.themeColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(widget.themeColor),
              minHeight: 8,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Score display
                    _buildScoreCard(),
                    const SizedBox(height: 20),

                    // Question card
                    _buildQuestionCard(),
                    const SizedBox(height: 20),

                    // Hint display
                    if (_showHint && _currentQuestion.hint != null)
                      _buildHintCard(),
                    if (_showHint) const SizedBox(height: 16),

                    // Options
                    ..._buildOptions(),

                    // Feedback and explanation
                    if (_answered) ...[
                      const SizedBox(height: 20),
                      _buildFeedback(),
                    ],
                  ],
                ),
              ),
            ),

            // Next button
            if (_answered)
              Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentIndex < _shuffledQuestions.length - 1
                            ? Icons.arrow_forward
                            : Icons.celebration,
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
            widget.themeColor.withOpacity(0.1),
            widget.themeColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.themeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem('⭐', 'Score', '$_correctCount'),
          Container(
            width: 1,
            height: 40,
            color: widget.themeColor.withOpacity(0.3),
          ),
          _buildScoreItem('🎯', 'Questions', '${_currentIndex + 1}/${_shuffledQuestions.length}'),
          Container(
            width: 1,
            height: 40,
            color: widget.themeColor.withOpacity(0.3),
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
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    widget.themeColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.themeColor.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.themeColor.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 15,
                    offset: const Offset(-5, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Animated icon with glow
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          widget.themeColor.withOpacity(0.25),
                          widget.themeColor.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.themeColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      _getQuestionTypeEmoji(),
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _currentQuestion.question,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      color: Colors.grey[900],
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentQuestion.hint!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.amber[900],
              ),
            ),
          ),
        ],
      ),
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
            ? widget.themeColor.withOpacity(0.1)
            : Colors.white;
        borderColor = isSelected 
            ? widget.themeColor 
            : Colors.grey[300]!;
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _answered ? null : () => _selectAnswer(index),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: isSelected || (_answered && isCorrect) ? 3 : 2,
                ),
                boxShadow: isSelected && !_answered
                    ? [
                        BoxShadow(
                          color: widget.themeColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Option letter badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _answered
                          ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.grey[300]))
                          : widget.themeColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _answered
                              ? (isCorrect || isSelected ? Colors.white : Colors.grey[600])
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
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: _answered 
                            ? (isCorrect ? Colors.green[800] : (isSelected ? Colors.red[800] : Colors.grey[600]))
                            : Colors.black87,
                      ),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCorrect ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCorrect ? Colors.green : Colors.red,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCorrect)
                  ScaleTransition(
                    scale: _starAnimation,
                    child: const Text('⭐', style: TextStyle(fontSize: 32)),
                  ),
                const SizedBox(width: 8),
                Text(
                  isCorrect ? 'Stellar Work! 🚀' : 'Not quite! 🌙',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green[700] : Colors.red[700],
                  ),
                ),
                const SizedBox(width: 8),
                if (isCorrect)
                  ScaleTransition(
                    scale: _starAnimation,
                    child: const Text('⭐', style: TextStyle(fontSize: 32)),
                  ),
              ],
            ),
            if (_currentQuestion.explanation != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📚', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentQuestion.explanation!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
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
