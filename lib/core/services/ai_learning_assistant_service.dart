import 'package:flutter/foundation.dart';

/// Lightweight AI assistant facade for hints/explanations.
///
/// This service is intentionally provider/backend-agnostic:
/// - In local mode, it returns deterministic fallback hints.
/// - In cloud mode, a backend endpoint can be plugged in later.
class AiLearningAssistantService extends ChangeNotifier {
  bool _enabled = false;
  bool _cloudMode = false;

  bool get enabled => _enabled;
  bool get cloudMode => _cloudMode;

  void setEnabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
  }

  void setCloudMode(bool value) {
    if (_cloudMode == value) return;
    _cloudMode = value;
    notifyListeners();
  }

  /// Generate an age-appropriate hint that nudges without giving away answers.
  Future<String> generateHint({
    required String question,
    required List<String> options,
    int? age,
  }) async {
    if (!_enabled) {
      return 'Try reading the question again and look for clue words.';
    }

    if (_cloudMode) {
      // Placeholder for backend integration:
      // Send question/options/age to secure server and return moderated response.
      return _localHint(question: question, options: options, age: age);
    }

    return _localHint(question: question, options: options, age: age);
  }

  /// Explain a result in simple language with encouragement.
  Future<String> explainAnswer({
    required String question,
    required String selectedAnswer,
    required String correctAnswer,
    int? age,
  }) async {
    if (!_enabled) {
      return 'Great effort! Keep practicing to build your skills.';
    }

    if (_cloudMode) {
      // Placeholder for backend integration.
      return _localExplanation(
        question: question,
        selectedAnswer: selectedAnswer,
        correctAnswer: correctAnswer,
        age: age,
      );
    }

    return _localExplanation(
      question: question,
      selectedAnswer: selectedAnswer,
      correctAnswer: correctAnswer,
      age: age,
    );
  }

  String _localHint({
    required String question,
    required List<String> options,
    int? age,
  }) {
    final questionLower = question.toLowerCase();

    if (questionLower.contains('not ') || questionLower.contains("n't")) {
      return 'Watch out for the word "not". It changes what the question is asking.';
    }

    if (questionLower.contains('best') || questionLower.contains('most')) {
      return 'Compare all options before choosing. One should fit the question better than the others.';
    }

    if (options.length >= 3) {
      return 'Try removing one option that is clearly wrong first, then choose from what remains.';
    }

    return age != null && age <= 7
        ? 'Take your time and say each option out loud.'
        : 'Look for key words in the question and match them to the best option.';
  }

  String _localExplanation({
    required String question,
    required String selectedAnswer,
    required String correctAnswer,
    int? age,
  }) {
    if (selectedAnswer == correctAnswer) {
      return age != null && age <= 7
          ? 'Awesome! You picked the right answer. Keep going!'
          : 'Nice work. You chose the correct answer based on the clues in the question.';
    }

    return age != null && age <= 7
        ? 'Good try! The best answer was "$correctAnswer". Let us look for clues together next time.'
        : 'Good attempt. "$correctAnswer" is correct for this question. Review the key clue words and try a similar one again.';
  }
}
