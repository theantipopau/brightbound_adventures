import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:brightbound_adventures/ui/themes/app_theme.dart';

/// Mini Games Screen with 4 quick skill-building games
class MiniGamesScreen extends StatefulWidget {
  const MiniGamesScreen({super.key});

  @override
  State<MiniGamesScreen> createState() => _MiniGamesScreenState();
}

class _MiniGamesScreenState extends State<MiniGamesScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: Colors.purple.shade700,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.purple.shade700,
                      Colors.purple.shade900,
                    ],
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text('🎮', style: TextStyle(fontSize: 40)),
                          SizedBox(width: 12),
                          Text(
                            'Mini Games',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Quick games to boost your skills!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: const Text(
                'Mini Games',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          // Games Grid
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildListDelegate([
                _buildGameCard(
                  emoji: '🎯',
                  title: 'Target\nPractice',
                  description: 'Quick aim\nchallenge',
                  color: Colors.red,
                  game: () => _launchGame(context, 'target_practice'),
                ),
                _buildGameCard(
                  emoji: '🧠',
                  title: 'Memory\nMatch',
                  description: 'Test your\nmemory',
                  color: Colors.deepPurple,
                  game: () => _launchGame(context, 'memory_match'),
                ),
                _buildGameCard(
                  emoji: '⏱️',
                  title: 'Speed\nRound',
                  description: 'Beat the\nclock',
                  color: Colors.orange,
                  game: () => _launchGame(context, 'speed_round'),
                ),
                _buildGameCard(
                  emoji: '🎨',
                  title: 'Color\nSplash',
                  description: 'Match the\ncolors',
                  color: Colors.blue,
                  game: () => _launchGame(context, 'color_splash'),
                ),
              ]),
            ),
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Stats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Games Played', '0', Colors.purple),
                        _buildStatItem('High Score', '0', Colors.orange),
                        _buildStatItem('Achievements', '0', Colors.green),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String emoji,
    required String title,
    required String description,
    required Color color,
    required VoidCallback game,
  }) {
    return GestureDetector(
      onTap: game,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.8),
              color,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: game,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _launchGame(BuildContext context, String gameType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(gameType: gameType),
      ),
    );
  }
}

/// Generic Game Screen with game-specific logic
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
  int score = 0;
  int timeRemaining = 30;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _gameController.addListener(_updateTimer);
    _gameController.forward().then((_) {
      setState(() => gameOver = true);
    });
  }

  void _updateTimer() {
    setState(() {
      timeRemaining = (30 * (1 - _gameController.value)).ceil();
    });
  }

  @override
  void dispose() {
    _gameController.dispose();
    super.dispose();
  }

  String get _gameTitle {
    switch (widget.gameType) {
      case 'target_practice':
        return '🎯 Target Practice';
      case 'memory_match':
        return '🧠 Memory Match';
      case 'speed_round':
        return '⏱️ Speed Round';
      case 'color_splash':
        return '🎨 Color Splash';
      default:
        return 'Mini Game';
    }
  }

  void _addScore() {
    setState(() => score += 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with timer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _gameTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: timeRemaining < 10
                          ? Colors.red
                          : Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$timeRemaining"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Game content
          Expanded(
            child: gameOver
                ? _buildGameOver()
                : _buildGameContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Score display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Score',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Game-specific content
          _buildGameSpecificContent(),

          const SizedBox(height: 40),

          // Action button
          ElevatedButton.icon(
            onPressed: _addScore,
            icon: const Icon(Icons.touch_app),
            label: const Text('Tap to Score!'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              backgroundColor: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSpecificContent() {
    switch (widget.gameType) {
      case 'target_practice':
        return _buildTargetPractice();
      case 'memory_match':
        return _buildMemoryMatch();
      case 'speed_round':
        return _buildSpeedRound();
      case 'color_splash':
        return _buildColorSplash();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTargetPractice() {
    return Column(
      children: [
        const Text(
          'Hit the Target!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Colors.red.shade300, Colors.red.shade700],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Center(
            child: Text('🎯', style: TextStyle(fontSize: 60)),
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryMatch() {
    return Column(
      children: [
        const Text(
          'Find the Pair!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          childAspectRatio: 1,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: List.generate(8, (index) {
            final emojis = ['🐱', '🐶', '🐱', '🐶', '🐭', '🐹', '🐭', '🐹'];
            return Container(
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  emojis[index],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSpeedRound() {
    return Column(
      children: [
        const Text(
          'Answer Quickly!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Text(
                '7 + 5 = ?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceButton(label: '10'),
                  ChoiceButton(label: '12'),
                  ChoiceButton(label: '13'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorSplash() {
    return Column(
      children: [
        const Text(
          'Match the Color!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Find the matching color below'),
      ],
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🎉 Game Over!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  'Final Score',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '⭐ Great job!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Exit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _launchGame(context, widget.gameType);
                },
                icon: const Icon(Icons.replay),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _launchGame(BuildContext context, String gameType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(gameType: gameType),
      ),
    );
  }
}

/// Simple choice button for speed round
class ChoiceButton extends StatefulWidget {
  final String label;

  const ChoiceButton({
    super.key,
    required this.label,
  });

  @override
  State<ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<ChoiceButton> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => isSelected = true);
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) Navigator.pop(context);
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
