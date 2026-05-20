import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Memory Match Card Game
/// Match pairs of cards with emojis, words, or images
class MemoryMatchGame extends StatefulWidget {
  final String difficulty; // 'easy', 'medium', 'hard'
  final String category; // 'emojis', 'numbers', 'words'

  const MemoryMatchGame({
    super.key,
    this.difficulty = 'easy',
    this.category = 'emojis',
  });

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame>
    with SingleTickerProviderStateMixin {
  late List<MemoryCard> _cards;
  final List<int> _flippedIndices = [];
  int _moves = 0;
  int _matches = 0;
  bool _isChecking = false;
  late AnimationController _controller;
  int _score = 0;
  int _timeRemaining = 60;
  bool _gameOver = false;
  Timer? _timer;
  final FocusNode _gameFocusNode = FocusNode(debugLabel: 'memory_match_game');
  int _focusedCardIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _initializeGame();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _gameFocusNode.dispose();
    super.dispose();
  }

  void _initializeGame() {
    final pairCount = _getPairCount();
    final items = _getItems(pairCount);

    // Create pairs
    final List<MemoryCard> cards = [];
    for (int i = 0; i < items.length; i++) {
      cards.add(MemoryCard(
          id: i * 2, content: items[i], isFlipped: false, isMatched: false));
      cards.add(MemoryCard(
          id: i * 2 + 1,
          content: items[i],
          isFlipped: false,
          isMatched: false));
    }

    // Shuffle
    cards.shuffle(Random());
    setState(() {
      _cards = cards;
      _focusedCardIndex = 0;
    });
  }

  int _getPairCount() {
    switch (widget.difficulty) {
      case 'easy':
        return 6; // 6 pairs = 12 cards
      case 'medium':
        return 8; // 8 pairs = 16 cards
      case 'hard':
        return 12; // 12 pairs = 24 cards
      default:
        return 6;
    }
  }

  List<String> _getItems(int count) {
    final Map<String, List<String>> categoryItems = {
      'emojis': [
        '🐶',
        '🐱',
        '🐭',
        '🐹',
        '🐰',
        '🦊',
        '🐻',
        '🐼',
        '🐨',
        '🐯',
        '🦁',
        '🐮',
        '🐷',
        '🐸',
        '🐵',
        '🐔'
      ],
      'numbers': [
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '10',
        '11',
        '12',
        '13',
        '14',
        '15',
        '16'
      ],
      'words': [
        'cat',
        'dog',
        'sun',
        'moon',
        'star',
        'tree',
        'fish',
        'bird',
        'apple',
        'ball',
        'car',
        'book',
        'shoe',
        'hat',
        'cup',
        'pen'
      ],
    };

    final items = categoryItems[widget.category] ?? categoryItems['emojis']!;
    return items.take(count).toList();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _gameOver) {
        timer.cancel();
        return;
      }
      setState(() {
        _timeRemaining--;
        if (_timeRemaining <= 0) {
          _gameOver = true;
          timer.cancel();
          _showGameOverDialog(false);
        }
      });
    });
  }

  void _onCardTap(int index) {
    if (_isChecking) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;
    if (_flippedIndices.length >= 2) return;

    setState(() {
      _cards[index].isFlipped = true;
      _flippedIndices.add(index);
    });

    _controller.forward(from: 0);

    if (_flippedIndices.length == 2) {
      _moves++;
      _checkMatch();
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent || _cards.isEmpty || _gameOver) return;

    final columns = _getGridSize().$1;
    final key = event.logicalKey;
    var nextIndex = _focusedCardIndex;

    if (key == LogicalKeyboardKey.arrowLeft) {
      nextIndex = max(0, _focusedCardIndex - 1);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      nextIndex = min(_cards.length - 1, _focusedCardIndex + 1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      nextIndex = max(0, _focusedCardIndex - columns);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      nextIndex = min(_cards.length - 1, _focusedCardIndex + columns);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      _onCardTap(_focusedCardIndex);
      return;
    } else {
      return;
    }

    if (nextIndex != _focusedCardIndex) {
      setState(() => _focusedCardIndex = nextIndex);
    }
  }

  void _checkMatch() {
    _isChecking = true;
    final index1 = _flippedIndices[0];
    final index2 = _flippedIndices[1];

    if (_cards[index1].content == _cards[index2].content) {
      // Match found!
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _cards[index1].isMatched = true;
          _cards[index2].isMatched = true;
          _matches++;
          _score += 10;
          _flippedIndices.clear();
          _isChecking = false;

          // Check if game is won
          if (_matches == _cards.length / 2) {
            _gameOver = true;
            _timer?.cancel();
            _showGameOverDialog(true);
          }
        });
      });
    } else {
      // No match
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _cards[index1].isFlipped = false;
          _cards[index2].isFlipped = false;
          _flippedIndices.clear();
          _isChecking = false;
        });
      });
    }
  }

  void _showGameOverDialog(bool won) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          won ? '🎉 You Won!' : '⏰ Time\'s Up!',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              won
                  ? 'Congratulations! You matched all pairs!'
                  : 'Better luck next time!',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildStatRow('⭐ Score', _score.toString()),
            _buildStatRow('🎯 Moves', _moves.toString()),
            _buildStatRow('✅ Matches', '$_matches/${_cards.length ~/ 2}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _moves = 0;
                _matches = 0;
                _score = 0;
                _timeRemaining = 60;
                _gameOver = false;
                _flippedIndices.clear();
                _initializeGame();
                _startTimer();
              });
            },
            child: const Text('Play Again', style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridSize = _getGridSize();

    return KeyboardListener(
      focusNode: _gameFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Memory Match 🧠'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            // Stats bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.purple.withValues(alpha: 0.1),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatChip('⏱️ ${_timeRemaining}s', Colors.red),
                  _buildStatChip('🎯 Moves: $_moves', Colors.blue),
                  _buildStatChip(
                      '✅ Pairs: $_matches/${_cards.length ~/ 2}', Colors.green),
                  _buildStatChip('⭐ Score: $_score', Colors.amber),
                ],
              ),
            ),

            // Game grid
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize.$1,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      return _buildCard(_cards[index], index);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (int, int) _getGridSize() {
    // Returns (columns, rows)
    switch (_cards.length) {
      case 12:
        return (4, 3);
      case 16:
        return (4, 4);
      case 24:
        return (6, 4);
      default:
        return (4, 3);
    }
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCard(MemoryCard card, int index) {
    final visible = card.isFlipped || card.isMatched;
    final isFocused = index == _focusedCardIndex;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        selected: visible,
        enabled: !card.isMatched && !_isChecking,
        label: visible
            ? 'Memory card showing ${card.content}'
            : 'Hidden memory card ${index + 1}',
        hint: 'Use arrow keys to move and Enter or Space to flip.',
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() => _focusedCardIndex = index);
            _onCardTap(index);
          },
          splashColor: Colors.purple.withValues(alpha: 0.3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: card.isMatched
                  ? Colors.green.withValues(alpha: 0.3)
                  : card.isFlipped
                      ? Colors.white
                      : Colors.purple,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFocused
                    ? Colors.amber
                    : (card.isMatched ? Colors.green : Colors.purple[700]!),
                width: isFocused ? 5 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: card.isFlipped || card.isMatched
                  ? Text(
                      card.content,
                      style: TextStyle(
                        fontSize: widget.category == 'emojis' ? 48 : 32,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const Icon(
                      Icons.question_mark,
                      size: 48,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class MemoryCard {
  final int id;
  final String content;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.content,
    required this.isFlipped,
    required this.isMatched,
  });
}
