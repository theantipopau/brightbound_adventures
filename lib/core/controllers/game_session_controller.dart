import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:brightbound_adventures/core/utils/learning_feedback_helper.dart';

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
  int _lastPointsEarned = 0;
  int _lastTimeBonus = 0;
  bool? _lastAnswerCorrect;

  // Timer
  Timer? _timer;
  int _secondsRemaining = 0;

  // Multiplier logic
  double get multiplier {
    if (_currentStreak >= 10) return 3.0; // Super Hot!
    if (_currentStreak >= 5) return 2.0; // Heating up!
    if (_currentStreak >= 3) return 1.5; // On a roll
    return 1.0;
  }

  // Getters
  GameState get state => _state;
  int get score => _currentScore;
  int get streak => _currentStreak;
  int get lives => _currentLives;
  int get questionsAnswered => _questionsAnswered;
  int get correctAnswers => _correctAnswers;
  int get lastPointsEarned => _lastPointsEarned;
  int get lastTimeBonus => _lastTimeBonus;
  bool? get lastAnswerCorrect => _lastAnswerCorrect;
  int get remainingTime => _secondsRemaining;
  double get progress =>
      _questionsAnswered / (totalQuestions > 0 ? totalQuestions : 1);
  double get accuracy =>
      _questionsAnswered == 0 ? 0.0 : _correctAnswers / _questionsAnswered;
  bool get hasPerfectRun =>
      _questionsAnswered > 0 &&
      _questionsAnswered == _correctAnswers &&
      _currentLives == maxLives;
  bool get isOnFinalQuestion => _questionsAnswered >= totalQuestions - 1;
  String get encouragement => LearningFeedbackHelper.encouragement(
        isCorrect: _lastAnswerCorrect ?? false,
        streak: _currentStreak,
      );
  String get masteryMessage => LearningFeedbackHelper.masteryMessage(
        correct: _correctAnswers,
        answered: _questionsAnswered,
      );
  int get suggestedDifficultyDelta =>
      LearningFeedbackHelper.suggestedDifficultyDelta(
        correct: _correctAnswers,
        answered: _questionsAnswered,
        streak: _currentStreak,
      );
  String get streakLabel {
    if (_currentStreak >= 10) return 'Super streak';
    if (_currentStreak >= 5) return 'Heating up';
    if (_currentStreak >= 3) return 'On a roll';
    if (_currentStreak >= 1) return 'Nice start';
    return 'Ready';
  }

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
    _lastPointsEarned = 0;
    _lastTimeBonus = 0;
    _lastAnswerCorrect = null;
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
    if (_state != GameState.playing) return;

    stopTimer();
    _questionsAnswered++;
    _lastPointsEarned = 0;
    _lastTimeBonus = 0;
    _lastAnswerCorrect = isCorrect;

    // Calculate time bonus (if answered quickly)
    // E.g. answered in 5 seconds of a 30s timer -> 25s remaining
    int timeBonus = 0;
    if (isCorrect) {
      // 10 points per remaining second, capped
      timeBonus = _secondsRemaining * 10;
      _lastTimeBonus = timeBonus;
    }

    if (isCorrect) {
      _correctAnswers++;
      _currentStreak++;

      // Base score 100 * multiplier + time bonus
      int pointsEarned = ((100 * multiplier) + timeBonus).round();
      _currentScore += pointsEarned;
      _lastPointsEarned = pointsEarned;
      if (onScoreChanged != null) onScoreChanged!(_currentScore);

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
    if (_state != GameState.playing) return;

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

  void addBonusScore(int points) {
    if (points <= 0) return;
    _currentScore += points;
    if (onScoreChanged != null) onScoreChanged!(_currentScore);
    notifyListeners();
  }

  void addExtraLife({int amount = 1}) {
    if (amount <= 0) return;
    _currentLives = (_currentLives + amount).clamp(0, maxLives + 2);
    notifyListeners();
  }

  void addTime(int seconds) {
    if (seconds <= 0 || _state != GameState.playing) return;
    _secondsRemaining = (_secondsRemaining + seconds).clamp(
      0,
      maxTimePerQuestion + 20,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
