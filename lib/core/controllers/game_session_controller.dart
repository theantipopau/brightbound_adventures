import 'dart:async';
import 'package:flutter/foundation.dart';

enum GameState {
  ready,
  playing,
  paused,
  finished,
}

class GameSessionController extends ChangeNotifier {
  // Config
  final int maxLives;
  final int totalQuestions;
  final int maxTimePerQuestion;

  // State
  GameState _state = GameState.ready;
  int _currentScore = 0;
  int _currentStreak = 0;
  int _currentLives = 3;
  int _questionsAnswered = 0;
  int _correctAnswers = 0;
  
  // Timer
  Timer? _timer;
  int _secondsRemaining = 0;
  
  // Multiplier logic
  double get multiplier {
    if (_currentStreak >= 10) return 3.0; // Super Hot!
    if (_currentStreak >= 5) return 2.0;  // Heating up!
    if (_currentStreak >= 3) return 1.5;  // On a roll
    return 1.0;
  }

  // Getters
  GameState get state => _state;
  int get score => _currentScore;
  int get streak => _currentStreak;
  int get lives => _currentLives;
  int get questionsAnswered => _questionsAnswered;
  int get correctAnswers => _correctAnswers;
  int get remainingTime => _secondsRemaining;
  double get progress => _questionsAnswered / (totalQuestions > 0 ? totalQuestions : 1);

  // Events/Callbacks
  final Function(int points)? onScoreChanged;
  final Function()? onGameOver;
  final Function()? onLevelComplete;
  final Function()? onStreakMilestone;
  final Function()? onLifeLost;

  GameSessionController({
    this.maxLives = 3,
    this.totalQuestions = 10,
    this.maxTimePerQuestion = 30,
    this.onScoreChanged,
    this.onGameOver,
    this.onLevelComplete,
    this.onStreakMilestone,
    this.onLifeLost,
  }) {
    _currentLives = maxLives;
  }

  void startGame() {
    _state = GameState.playing;
    _currentScore = 0;
    _currentStreak = 0;
    _currentLives = maxLives;
    _questionsAnswered = 0;
    _correctAnswers = 0;
    notifyListeners();
  }

  void startQuestionTimer({bool reset = true}) {
    _timer?.cancel();
    if (reset) {
      _secondsRemaining = maxTimePerQuestion;
    }
    notifyListeners();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state != GameState.playing) {
        timer.cancel();
        return;
      }
      
      _secondsRemaining--;
      if (_secondsRemaining <= 0) {
        timer.cancel();
        handleTimeOut();
      }
      notifyListeners();
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void submitAnswer(bool isCorrect) {
    stopTimer();
    _questionsAnswered++;
    
    // Calculate time bonus (if answered quickly)
    // E.g. answered in 5 seconds of a 30s timer -> 25s remaining
    int timeBonus = 0;
    if (isCorrect) {
      // 10 points per remaining second, capped
      timeBonus = _secondsRemaining * 10;
    }

    if (isCorrect) {
      _correctAnswers++;
      _currentStreak++;
      
      // Base score 100 * multiplier + time bonus
      int pointsEarned = ((100 * multiplier) + timeBonus).round();
      _currentScore += pointsEarned;
      
      if (_currentStreak % 3 == 0) {
        // Milestone event every 3 streak
        if (onStreakMilestone != null) onStreakMilestone!();
      }
      
    } else {
      _currentStreak = 0;
      _currentLives--;
      if (onLifeLost != null) onLifeLost!();
      
      if (_currentLives <= 0) {
        endGame(false);
        return;
      }
    }
    
    notifyListeners();
    
    if (_questionsAnswered >= totalQuestions && _currentLives > 0) {
      endGame(true);
    }
  }

  void handleTimeOut() {
    // Treat as wrong answer
    submitAnswer(false);
  }

  void endGame(bool isVictory) {
    _state = GameState.finished;
    stopTimer();
    notifyListeners();
    
    if (isVictory) {
      if (onLevelComplete != null) onLevelComplete!();
    } else {
      if (onGameOver != null) onGameOver!();
    }
  }

  void pauseGame() {
    if (_state == GameState.playing) {
      _state = GameState.paused;
      stopTimer();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_state == GameState.paused) {
      _state = GameState.playing;
      startQuestionTimer(reset: false);
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
