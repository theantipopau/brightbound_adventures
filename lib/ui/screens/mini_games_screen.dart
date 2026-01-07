import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

/// Improved Mini Games Screen with enhanced GUI and better gameplay
class MiniGamesScreen extends StatefulWidget {
  const MiniGamesScreen({super.key});

  @override
  State<MiniGamesScreen> createState() => _MiniGamesScreenState();
}

class _MiniGamesScreenState extends State<MiniGamesScreen> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade700,
              Colors.purple.shade900,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '🎮 Mini Games',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Quick games to boost your skills!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Games Grid
              Expanded(
                child: AnimatedBuilder(
                  animation: _entranceController,
                  builder: (context, child) {
                    return GridView.count(
                      crossAxisCount: 2,
                      padding: const EdgeInsets.all(20),
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.9,
                      children: [
                        _buildGameCard(
                          index: 0,
                          emoji: '🎯',
                          title: 'Target\nPractice',
                          description: 'Tap the targets\nbefore time runs out!',
                          color: Colors.red,
                          game: () => _launchGame(context, 'target_practice'),
                        ),
                        _buildGameCard(
                          index: 1,
                          emoji: '🧠',
                          title: 'Memory\nMatch',
                          description: 'Find matching\npairs quickly!',
                          color: Colors.deepPurple,
                          game: () => _launchGame(context, 'memory_match'),
                        ),
                        _buildGameCard(
                          index: 2,
                          emoji: '⏱️',
                          title: 'Speed\nMath',
                          description: 'Solve problems\nas fast as you can!',
                          color: Colors.orange,
                          game: () => _launchGame(context, 'speed_round'),
                        ),
                        _buildGameCard(
                          index: 3,
                          emoji: '🎨',
                          title: 'Color\nMatch',
                          description: 'Match word color\nwith the name!',
                          color: Colors.cyan,
                          game: () => _launchGame(context, 'color_splash'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required int index,
    required String emoji,
    required String title,
    required String description,
    required Color color,
    required VoidCallback game,
  }) {
    final delay = index * 0.12;
    final animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(delay, 1.0, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([animation, _floatController]),
      builder: (context, child) {
        final float = math.sin(_floatController.value * math.pi + index * 0.5) * 4;
        final scale = animation.value;
        final opacity = animation.value;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, float),
              child: GestureDetector(
                onTap: game,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.95),
                        color.withValues(alpha: 0.75),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: game,
                      borderRadius: BorderRadius.circular(28),
                      splashColor: Colors.white.withValues(alpha: 0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Emoji with enhanced glow effect
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 64),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const Spacer(),
                            // Enhanced play button
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_arrow_rounded, color: color, size: 24),
                                  const SizedBox(width: 6),
                                  Text(
                                    'PLAY',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _launchGame(BuildContext context, String gameType) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameScreen(gameType: gameType),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

/// Game Screen with enhanced gameplay for each mini-game
class GameScreen extends StatefulWidget {
  final String gameType;

  const GameScreen({
    super.key,
    required this.gameType,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _gameController;
  late AnimationController _pulseController;
  int score = 0;
  int timeRemaining = 30;
  bool gameOver = false;
  bool gameStarted = false;

  // Target Practice game state
  List<Offset> targets = [];
  final math.Random random = math.Random();

  // Memory Match game state
  List<String> memoryCards = [];
  List<int> flippedIndices = [];
  List<int> matchedIndices = [];
  
  // Speed Math game state
  int mathAnswer = 0;
  String mathQuestion = '';
  List<int> mathOptions = [];

  // Color Match game state
  String colorWord = '';
  Color wordColor = Colors.black;
  Color correctColor = Colors.black;
  List<Color> colorOptions = [];

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _gameController.addListener(_updateTimer);
    _initializeGame();
  }

  void _initializeGame() {
    switch (widget.gameType) {
      case 'target_practice':
        _generateTargets();
        break;
      case 'memory_match':
        _setupMemoryGame();
        break;
      case 'speed_round':
        _generateMathProblem();
        break;
      case 'color_splash':
        _generateColorChallenge();
        break;
    }
  }

  void _startGame() {
    setState(() {
      gameStarted = true;
    });
    _gameController.forward().then((_) {
      setState(() => gameOver = true);
    });
  }

  void _updateTimer() {
    if (mounted) {
      setState(() {
        timeRemaining = (30 * (1 - _gameController.value)).ceil();
      });
    }
  }

  void _generateTargets() {
    targets.clear();
    for (int i = 0; i < 5; i++) {
      targets.add(Offset(
        random.nextDouble() * 0.8 + 0.1,
        random.nextDouble() * 0.6 + 0.2,
      ));
    }
  }

  void _setupMemoryGame() {
    const emojis = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼'];
    memoryCards = [...emojis, ...emojis]..shuffle();
    flippedIndices.clear();
    matchedIndices.clear();
  }

  void _generateMathProblem() {
    final a = random.nextInt(10) + 1;
    final b = random.nextInt(10) + 1;
    final operations = ['+', '-', '×'];
    final op = operations[random.nextInt(operations.length)];

    switch (op) {
      case '+':
        mathAnswer = a + b;
        mathQuestion = '$a + $b = ?';
        break;
      case '-':
        mathAnswer = a - b;
        mathQuestion = '$a - $b = ?';
        break;
      case '×':
        mathAnswer = a * b;
        mathQuestion = '$a × $b = ?';
        break;
    }

    mathOptions = [
      mathAnswer,
      mathAnswer + random.nextInt(5) + 1,
      mathAnswer - random.nextInt(5) - 1,
    ]..shuffle();
  }

  void _generateColorChallenge() {
    const colors = [
      {'name': 'RED', 'color': Colors.red},
      {'name': 'BLUE', 'color': Colors.blue},
      {'name': 'GREEN', 'color': Colors.green},
      {'name': 'YELLOW', 'color': Colors.yellow},
      {'name': 'PURPLE', 'color': Colors.purple},
      {'name': 'ORANGE', 'color': Colors.orange},
    ];

    final wordData = colors[random.nextInt(colors.length)];
    final colorData = colors[random.nextInt(colors.length)];

    colorWord = wordData['name'] as String;
    wordColor = colorData['color'] as Color;
    correctColor = wordColor; // Match the COLOR not the word

    colorOptions = colors.map((c) => c['color'] as Color).toList()..shuffle();
    colorOptions = colorOptions.take(4).toList();
    if (!colorOptions.contains(correctColor)) {
      colorOptions[random.nextInt(4)] = correctColor;
    }
  }

  @override
  void dispose() {
    _gameController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color get _getGameColor {
    switch (widget.gameType) {
      case 'target_practice':
        return Colors.red;
      case 'memory_match':
        return Colors.deepPurple;
      case 'speed_round':
        return Colors.orange;
      case 'color_splash':
        return Colors.cyan;
      default:
        return Colors.purple;
    }
  }

  String get _gameTitle {
    switch (widget.gameType) {
      case 'target_practice':
        return '🎯 Target Practice';
      case 'memory_match':
        return '🧠 Memory Match';
      case 'speed_round':
        return '⏱️ Speed Math';
      case 'color_splash':
        return '🎨 Color Match';
      default:
        return 'Mini Game';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!gameStarted) {
      return _buildCountdownScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header with timer and score
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_getGameColor, _getGameColor.withValues(alpha: 0.8)],
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => _showExitDialog(),
                  ),
                  Expanded(
                    child: Text(
                      _gameTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Timer
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = timeRemaining < 10
                          ? 1.0 + (_pulseController.value * 0.1)
                          : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: timeRemaining < 10 ? Colors.red : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            '$timeRemaining"',
                            style: TextStyle(
                              color: timeRemaining < 10 ? Colors.white : _getGameColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Score display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Score: ',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _getGameColor,
                  ),
                ),
              ],
            ),
          ),

          // Game content
          Expanded(
            child: gameOver ? _buildGameOver() : _buildGameContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_getGameColor, _getGameColor.withValues(alpha: 0.7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _gameTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getGameInstructions(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _getGameColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow, size: 32),
                            SizedBox(width: 8),
                            Text(
                              'START',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGameInstructions() {
    switch (widget.gameType) {
      case 'target_practice':
        return 'Tap all the targets as fast as you can!\n\nYou have 30 seconds to hit as many targets as possible.';
      case 'memory_match':
        return 'Find all the matching pairs!\n\nTap cards to flip them and remember their positions.';
      case 'speed_round':
        return 'Solve math problems quickly!\n\nChoose the correct answer before time runs out.';
      case 'color_splash':
        return 'Match the COLOR of the word,\nnot the word itself!\n\nPay close attention!';
      default:
        return '';
    }
  }

  Widget _buildGameContent() {
    switch (widget.gameType) {
      case 'target_practice':
        return _buildTargetPractice();
      case 'memory_match':
        return _buildMemoryMatch();
      case 'speed_round':
        return _buildSpeedMath();
      case 'color_splash':
        return _buildColorMatch();
      default:
        return const Center(child: Text('Game not found'));
    }
  }

  Widget _buildTargetPractice() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: targets.asMap().entries.map((entry) {
            final index = entry.key;
            final target = entry.value;
            return Positioned(
              left: target.dx * constraints.maxWidth - 40,
              top: target.dy * constraints.maxHeight - 40,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    score += 10;
                    targets.removeAt(index);
                    if (targets.length < 3) {
                      _generateTargets();
                    }
                  });
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.red.shade400, Colors.red.shade700],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🎯', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMemoryMatch() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: memoryCards.length,
      itemBuilder: (context, index) {
        final isFlipped = flippedIndices.contains(index);
        final isMatched = matchedIndices.contains(index);

        return GestureDetector(
          onTap: () => _handleMemoryCardTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isMatched
                  ? Colors.green.shade400
                  : isFlipped
                      ? Colors.white
                      : Colors.deepPurple,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                isFlipped || isMatched ? memoryCards[index] : '?',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleMemoryCardTap(int index) {
    if (flippedIndices.length >= 2 || matchedIndices.contains(index) || flippedIndices.contains(index)) {
      return;
    }

    setState(() {
      flippedIndices.add(index);
    });

    if (flippedIndices.length == 2) {
      Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          final first = flippedIndices[0];
          final second = flippedIndices[1];

          if (memoryCards[first] == memoryCards[second]) {
            setState(() {
              matchedIndices.addAll([first, second]);
              flippedIndices.clear();
              score += 20;
            });
          } else {
            setState(() {
              flippedIndices.clear();
            });
          }
        }
      });
    }
  }

  Widget _buildSpeedMath() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Text(
              mathQuestion,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _getGameColor,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ...mathOptions.map((option) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                child: ElevatedButton(
                  onPressed: () => _checkMathAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    '$option',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _checkMathAnswer(int answer) {
    if (answer == mathAnswer) {
      setState(() {
        score += 15;
        _generateMathProblem();
      });
    } else {
      setState(() {
        score = math.max(0, score - 5);
      });
    }
  }

  Widget _buildColorMatch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'What COLOR is this word?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Text(
              colorWord,
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: wordColor,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: colorOptions.map((color) => GestureDetector(
                  onTap: () => _checkColorAnswer(color),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                )).toList(),
          ),
        ],
      ),
    );
  }

  void _checkColorAnswer(Color color) {
    if (color == correctColor) {
      setState(() {
        score += 15;
        _generateColorChallenge();
      });
    } else {
      setState(() {
        score = math.max(0, score - 5);
      });
    }
  }

  Widget _buildGameOver() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🎉 Game Over!',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_getGameColor.withValues(alpha: 0.2), _getGameColor.withValues(alpha: 0.1)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text(
                  'Final Score',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: _getGameColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _getScoreMessage(),
                  style: TextStyle(
                    fontSize: 18,
                    color: _getGameColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Exit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(gameType: widget.gameType),
                    ),
                  );
                },
                icon: const Icon(Icons.replay),
                label: const Text('Play Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getGameColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getScoreMessage() {
    if (score >= 200) return '⭐⭐⭐ Amazing!';
    if (score >= 150) return '⭐⭐ Great job!';
    if (score >= 100) return '⭐ Good work!';
    return 'Keep practicing!';
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
