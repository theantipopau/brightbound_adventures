import 'dart:math';
import 'package:flutter/material.dart';

/// Word Search Game
/// Find hidden words in a grid of letters
class WordSearchGame extends StatefulWidget {
  final String difficulty;

  const WordSearchGame({
    super.key,
    this.difficulty = 'easy',
  });

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  late List<List<String>> _grid;
  late List<String> _wordsToFind;
  late Set<String> _foundWords;
  late List<GridPosition> _selectedCells;
  int _gridSize = 10;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _foundWords = {};
    _selectedCells = [];
    _initializeGame();
  }

  void _initializeGame() {
    _gridSize = _getGridSize();
    _wordsToFind = _getWords();
    _grid = _generateGrid();
    _placeWords();
    _fillEmptySpaces();
  }

  int _getGridSize() {
    switch (widget.difficulty) {
      case 'easy':
        return 8;
      case 'medium':
        return 10;
      case 'hard':
        return 12;
      default:
        return 8;
    }
  }

  List<String> _getWords() {
    final wordLists = {
      'easy': ['CAT', 'DOG', 'SUN', 'STAR', 'FISH', 'BIRD'],
      'medium': ['APPLE', 'HAPPY', 'WATER', 'LIGHT', 'MUSIC', 'DANCE', 'SMILE'],
      'hard': [
        'RAINBOW',
        'ADVENTURE',
        'BUTTERFLY',
        'TREASURE',
        'MOUNTAIN',
        'ELEPHANT'
      ],
    };

    return wordLists[widget.difficulty] ?? wordLists['easy']!;
  }

  List<List<String>> _generateGrid() {
    return List.generate(
      _gridSize,
      (i) => List.generate(_gridSize, (j) => ''),
    );
  }

  void _placeWords() {
    final random = Random();

    for (final word in _wordsToFind) {
      bool placed = false;
      int attempts = 0;

      while (!placed && attempts < 100) {
        attempts++;

        // Random starting position
        int row = random.nextInt(_gridSize);
        int col = random.nextInt(_gridSize);

        // Random direction: 0=horizontal, 1=vertical, 2=diagonal
        int direction = random.nextInt(3);

        if (_canPlaceWord(word, row, col, direction)) {
          _placeWord(word, row, col, direction);
          placed = true;
        }
      }
    }
  }

  bool _canPlaceWord(String word, int row, int col, int direction) {
    int len = word.length;

    switch (direction) {
      case 0: // Horizontal
        if (col + len > _gridSize) return false;
        for (int i = 0; i < len; i++) {
          if (_grid[row][col + i].isNotEmpty &&
              _grid[row][col + i] != word[i]) {
            return false;
          }
        }
        break;
      case 1: // Vertical
        if (row + len > _gridSize) return false;
        for (int i = 0; i < len; i++) {
          if (_grid[row + i][col].isNotEmpty &&
              _grid[row + i][col] != word[i]) {
            return false;
          }
        }
        break;
      case 2: // Diagonal
        if (row + len > _gridSize || col + len > _gridSize) return false;
        for (int i = 0; i < len; i++) {
          if (_grid[row + i][col + i].isNotEmpty &&
              _grid[row + i][col + i] != word[i]) {
            return false;
          }
        }
        break;
    }

    return true;
  }

  void _placeWord(String word, int row, int col, int direction) {
    int len = word.length;

    switch (direction) {
      case 0: // Horizontal
        for (int i = 0; i < len; i++) {
          _grid[row][col + i] = word[i];
        }
        break;
      case 1: // Vertical
        for (int i = 0; i < len; i++) {
          _grid[row + i][col] = word[i];
        }
        break;
      case 2: // Diagonal
        for (int i = 0; i < len; i++) {
          _grid[row + i][col + i] = word[i];
        }
        break;
    }
  }

  void _fillEmptySpaces() {
    final random = Random();
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    for (int i = 0; i < _gridSize; i++) {
      for (int j = 0; j < _gridSize; j++) {
        if (_grid[i][j].isEmpty) {
          _grid[i][j] = letters[random.nextInt(letters.length)];
        }
      }
    }
  }

  void _onCellTap(int row, int col) {
    setState(() {
      final position = GridPosition(row, col);
      if (_selectedCells.contains(position)) {
        _selectedCells.remove(position);
      } else {
        _selectedCells.add(position);
      }
    });
  }

  void _checkWord() {
    if (_selectedCells.isEmpty) return;

    // Sort cells to form word
    _selectedCells.sort((a, b) {
      if (a.row != b.row) return a.row.compareTo(b.row);
      return a.col.compareTo(b.col);
    });

    final word = _selectedCells.map((pos) => _grid[pos.row][pos.col]).join();

    if (_wordsToFind.contains(word) && !_foundWords.contains(word)) {
      setState(() {
        _foundWords.add(word);
        _score += word.length * 10;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found: $word! 🎉'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );

      if (_foundWords.length == _wordsToFind.length) {
        _showGameOverDialog();
      }
    }

    setState(() {
      _selectedCells.clear();
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 All Words Found!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Congratulations!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '⭐ Score: $_score',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '✅ Words Found: ${_foundWords.length}/${_wordsToFind.length}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _foundWords.clear();
                _selectedCells.clear();
                _score = 0;
                _initializeGame();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Search 🔤'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '✅ ${_foundWords.length}/${_wordsToFind.length} Words',
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

          // Word list
          Container(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _wordsToFind.map((word) {
                final isFound = _foundWords.contains(word);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFound
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isFound ? Colors.green : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    word,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isFound ? Colors.green[800] : Colors.grey[800],
                      decoration: isFound ? TextDecoration.lineThrough : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Grid
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridSize,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    itemCount: _gridSize * _gridSize,
                    itemBuilder: (context, index) {
                      final row = index ~/ _gridSize;
                      final col = index % _gridSize;
                      final position = GridPosition(row, col);
                      final isSelected = _selectedCells.contains(position);

                      return GestureDetector(
                        onTap: () => _onCellTap(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.teal.withValues(alpha: 0.5)
                                : Colors.white,
                            border: Border.all(
                              color: Colors.teal.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _grid[row][col],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Check button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedCells.isEmpty ? null : _checkWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Check Word',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCells.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridPosition {
  final int row;
  final int col;

  GridPosition(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}
