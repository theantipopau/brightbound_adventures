import 'dart:math';
import 'package:flutter/material.dart';

/// Pattern Puzzle Game
/// Identify and complete patterns with shapes, colors, and sequences
class PatternPuzzleGame extends StatefulWidget {
  final String difficulty;

  const PatternPuzzleGame({
    super.key,
    this.difficulty = 'easy',
  });

  @override
  State<PatternPuzzleGame> createState() => _PatternPuzzleGameState();
}

class _PatternPuzzleGameState extends State<PatternPuzzleGame> {
  late List<PatternPuzzle> _puzzles;
  int _currentPuzzleIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  final int _totalQuestions = 10;
  bool _showingFeedback = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _generatePuzzles();
  }

  void _generatePuzzles() {
    _puzzles = List.generate(_totalQuestions, (index) {
      return _generatePuzzle(widget.difficulty, index);
    });
  }

  PatternPuzzle _generatePuzzle(String difficulty, int index) {
    final random = Random();
    final puzzleTypes = ['emoji', 'shape', 'color', 'number'];
    final type = puzzleTypes[random.nextInt(puzzleTypes.length)];

    if (difficulty == 'easy') {
      return _generateEasyPuzzle(type, index);
    } else if (difficulty == 'medium') {
      return _generateMediumPuzzle(type, index);
    } else {
      return _generateHardPuzzle(type, index);
    }
  }

  PatternPuzzle _generateEasyPuzzle(String type, int index) {
    final random = Random();

    if (type == 'emoji') {
      final patterns = [
        ['🔴', '🔵', '🔴', '🔵', '🔴', '?'],
        ['⭐', '⭐', '🌙', '⭐', '⭐', '?'],
        ['🐶', '🐱', '🐶', '🐱', '🐶', '?'],
        ['🍎', '🍌', '🍎', '🍌', '🍎', '?'],
      ];
      final pattern = patterns[random.nextInt(patterns.length)];
      final answer = pattern[1]; // The second element in the pattern

      return PatternPuzzle(
        id: 'easy_$index',
        pattern: pattern.sublist(0, 5),
        options: [pattern[1], pattern[0], '🟢', '🟡']..shuffle(),
        correctAnswer: answer,
        hint: 'Look for what repeats: AB AB AB',
      );
    } else if (type == 'number') {
      final start = random.nextInt(5) + 1;
      final pattern = [
        start.toString(),
        (start + 1).toString(),
        (start + 2).toString(),
        (start + 3).toString(),
        (start + 4).toString(),
        '?'
      ];
      final answer = (start + 5).toString();

      return PatternPuzzle(
        id: 'easy_$index',
        pattern: pattern.sublist(0, 5),
        options: [
          answer,
          (start + 4).toString(),
          (start + 6).toString(),
          (start + 3).toString()
        ]..shuffle(),
        correctAnswer: answer,
        hint: 'Count up by 1!',
      );
    } else {
      // Color shapes
      final shapes = ['●', '■', '▲'];
      final shape = shapes[random.nextInt(shapes.length)];
      final pattern = [shape, shape, shape, shape, shape, '?'];

      return PatternPuzzle(
        id: 'easy_$index',
        pattern: pattern.sublist(0, 5),
        options: [shape, shapes[(random.nextInt(shapes.length))]],
        correctAnswer: shape,
        hint: 'All the same shape!',
      );
    }
  }

  PatternPuzzle _generateMediumPuzzle(String type, int index) {
    final random = Random();

    if (type == 'emoji') {
      final patterns = [
        ['🔴', '🔵', '🟢', '🔴', '🔵', '🟢', '🔴', '?'],
        ['⭐', '⭐', '🌙', '🌙', '⭐', '⭐', '🌙', '?'],
        ['🐶', '🐱', '🐭', '🐶', '🐱', '🐭', '🐶', '?'],
      ];
      final pattern = patterns[random.nextInt(patterns.length)];
      final answer = pattern[1]; // ABC ABC pattern

      return PatternPuzzle(
        id: 'medium_$index',
        pattern: pattern.sublist(0, 7),
        options: [pattern[1], pattern[0], pattern[2], '🟡']..shuffle(),
        correctAnswer: answer,
        hint: 'Find the ABC ABC ABC pattern!',
      );
    } else if (type == 'number') {
      final start = random.nextInt(5) + 1;
      final step = 2;
      final pattern = List.generate(7, (i) => (start + i * step).toString())
        ..add('?');
      final answer = (start + 7 * step).toString();

      return PatternPuzzle(
        id: 'medium_$index',
        pattern: pattern.sublist(0, 7),
        options: [
          answer,
          (start + 6 * step).toString(),
          (start + 8 * step).toString(),
          (start + 5 * step).toString()
        ]..shuffle(),
        correctAnswer: answer,
        hint: 'Count up by 2s!',
      );
    } else {
      // Growing pattern
      final pattern = ['●', '●●', '●●●', '●●●●', '●●●●●', '?'];
      final answer = '●●●●●●';

      return PatternPuzzle(
        id: 'medium_$index',
        pattern: pattern.sublist(0, 5),
        options: [answer, '●●●●●', '●●●●●●●', '●●●']..shuffle(),
        correctAnswer: answer,
        hint: 'Each group grows by 1!',
      );
    }
  }

  PatternPuzzle _generateHardPuzzle(String type, int index) {
    final random = Random();

    if (type == 'number') {
      // Fibonacci-like or complex sequences
      final patterns = [
        ['2', '4', '6', '8', '10', '?'], // +2
        ['1', '3', '5', '7', '9', '?'], // +2 odd
        ['5', '10', '15', '20', '25', '?'], // +5
        ['3', '6', '9', '12', '15', '?'], // +3
      ];
      final pattern = patterns[random.nextInt(patterns.length)];
      final last = int.parse(pattern[4]);
      final step = int.parse(pattern[1]) - int.parse(pattern[0]);
      final answer = (last + step).toString();

      return PatternPuzzle(
        id: 'hard_$index',
        pattern: pattern.sublist(0, 5),
        options: [
          answer,
          (last + 1).toString(),
          (last + step + 1).toString(),
          (last - 1).toString()
        ]..shuffle(),
        correctAnswer: answer,
        hint: 'Find the number that gets added each time!',
      );
    } else {
      // Complex emoji patterns
      final patterns = [
        ['🔴', '🔴', '🔵', '🔴', '🔴', '🔵', '?'],
        ['⭐', '🌙', '🌙', '⭐', '🌙', '🌙', '?'],
        ['🍎', '🍎', '🍌', '🍌', '🍎', '🍎', '?'],
      ];
      final pattern = patterns[random.nextInt(patterns.length)];
      final answer = pattern[6] == '?' ? pattern[0] : pattern[1];

      return PatternPuzzle(
        id: 'hard_$index',
        pattern: pattern.sublist(0, 6),
        options: [pattern[0], pattern[1], pattern[2], '🟢']..shuffle(),
        correctAnswer: answer,
        hint: 'Look for the AAB AAB pattern!',
      );
    }
  }

  void _checkAnswer(String answer) {
    setState(() {
      _showingFeedback = true;
      _isCorrect = answer == _puzzles[_currentPuzzleIndex].correctAnswer;

      if (_isCorrect) {
        _score += 10;
        _correctAnswers++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentPuzzleIndex < _puzzles.length - 1) {
        setState(() {
          _currentPuzzleIndex++;
          _showingFeedback = false;
        });
      } else {
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 Puzzle Complete!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Great pattern recognition!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '⭐ Score: $_score',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '✅ Correct: $_correctAnswers/$_totalQuestions',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentPuzzleIndex = 0;
                _score = 0;
                _correctAnswers = 0;
                _showingFeedback = false;
                _generatePuzzles();
              });
            },
            child: const Text('Play Again', style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzles[_currentPuzzleIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pattern Puzzle 🧩'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentPuzzleIndex + 1) / _totalQuestions,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            minHeight: 8,
          ),

          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Question ${_currentPuzzleIndex + 1}/$_totalQuestions',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '⭐ Score: $_score',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Pattern display
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'What comes next?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Pattern
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ...puzzle.pattern.map((item) => _buildPatternItem(item)),
                      _buildPatternItem('?', isQuestion: true),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Hint
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            puzzle.hint,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Options
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: puzzle.options.length,
                    itemBuilder: (context, index) {
                      return _buildOptionButton(puzzle.options[index]);
                    },
                  ),

                  // Feedback
                  if (_showingFeedback) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isCorrect
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isCorrect ? Colors.green : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isCorrect ? Icons.check_circle : Icons.cancel,
                            color: _isCorrect ? Colors.green : Colors.red,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isCorrect
                                  ? 'Correct! Great job!'
                                  : 'Not quite. Try the next one!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _isCorrect
                                    ? Colors.green[800]
                                    : Colors.red[800],
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
          ),
        ],
      ),
    );
  }

  Widget _buildPatternItem(String item, {bool isQuestion = false}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isQuestion
            ? Colors.deepPurple.withValues(alpha: 0.2)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isQuestion ? Colors.deepPurple : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          item,
          style: TextStyle(
            fontSize: item.length == 1 && item.codeUnits[0] > 127 ? 32 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    return ElevatedButton(
      onPressed: _showingFeedback ? null : () => _checkAnswer(option),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      child: Text(
        option,
        style: TextStyle(
          fontSize: option.length == 1 && option.codeUnits[0] > 127 ? 32 : 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PatternPuzzle {
  final String id;
  final List<String> pattern;
  final List<String> options;
  final String correctAnswer;
  final String hint;

  PatternPuzzle({
    required this.id,
    required this.pattern,
    required this.options,
    required this.correctAnswer,
    required this.hint,
  });
}
