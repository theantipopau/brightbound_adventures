import 'package:flutter/material.dart';

/// Mini-games that can be unlocked and played independently
/// These are separate from the zone-based skill practice games

enum MiniGameType {
  memoryMatch, // Match pairs of cards
  patternChallenge, // Repeat patterns
  speedChallenge, // Fast-paced quiz
  puzzleGame, // Block/tile puzzles
  wordSearch, // Find words in grid
  mathRace, // Timed math problems
}

class MiniGame {
  final String id;
  final String name;
  final String emoji;
  final MiniGameType type;
  final String description;
  final int minLevel; // Required level to unlock
  final bool requiresInternet;

  const MiniGame({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    required this.description,
    required this.minLevel,
    this.requiresInternet = false,
  });
}

/// Available mini-games (placeholder definitions)
class MiniGames {
  static final List<MiniGame> availableGames = [
    MiniGame(
      id: 'memory_match',
      name: 'Memory Match',
      emoji: '🧠',
      type: MiniGameType.memoryMatch,
      description: 'Flip cards to find matching pairs!',
      minLevel: 1,
    ),
    MiniGame(
      id: 'pattern_challenge',
      name: 'Pattern Master',
      emoji: '🔄',
      type: MiniGameType.patternChallenge,
      description: 'Watch and repeat increasingly complex patterns',
      minLevel: 2,
    ),
    MiniGame(
      id: 'speed_quiz',
      name: 'Speed Challenge',
      emoji: '⚡',
      type: MiniGameType.speedChallenge,
      description: 'Answer questions as fast as you can!',
      minLevel: 1,
    ),
    MiniGame(
      id: 'puzzle_game',
      name: 'Puzzle Adventure',
      emoji: '🧩',
      type: MiniGameType.puzzleGame,
      description: 'Solve visual puzzles and brain teasers',
      minLevel: 3,
    ),
    MiniGame(
      id: 'word_search',
      name: 'Word Hunter',
      emoji: '🔍',
      type: MiniGameType.wordSearch,
      description: 'Find hidden words in the letter grid',
      minLevel: 2,
    ),
    MiniGame(
      id: 'math_race',
      name: 'Math Race',
      emoji: '🏎️',
      type: MiniGameType.mathRace,
      description: 'Solve math problems to win the race!',
      minLevel: 1,
    ),
  ];

  static List<MiniGame> getUnlockedGames(int playerLevel) {
    return availableGames
        .where((game) => game.minLevel <= playerLevel)
        .toList();
  }

  static MiniGame? getGameById(String id) {
    try {
      return availableGames.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Template for mini-game implementation
abstract class MiniGameWidget extends StatefulWidget {
  final MiniGame gameConfig;
  final Function(int score) onGameComplete;

  const MiniGameWidget({
    super.key,
    required this.gameConfig,
    required this.onGameComplete,
  });
}

abstract class MiniGameState extends State {
  int score = 0;
  bool isGameActive = false;

  Future<void> startGame();
  Future<void> endGame();

  void addScore(int points) {
    setState(() {
      score += points;
    });
  }
}
