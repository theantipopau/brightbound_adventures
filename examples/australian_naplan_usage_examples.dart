// EXAMPLE: How to integrate Australian NAPLAN questions into existing games

import 'package:brightbound_adventures/core/utils/australian_naplan_questions.dart';
import 'package:brightbound_adventures/core/utils/literacy_word_bank.dart';

/// Example 1: Using NAPLAN questions in Number Nebula
class NumberNebulaWithNAPLAN {
  void generateQuestion(int difficulty, int yearLevel) {
    if (yearLevel <= 2) {
      // Year 1-2 content
      // _ = AustralianNAPLANQuestions.generateYear1Numeracy('addition', difficulty);
    } else {
      // Year 3-4 content
      // _ = AustralianNAPLANQuestions.generateYear3Numeracy('multiplication', difficulty);
    }
    
    // Question data is now available for display
    // Example usage: question['question'], question['answer'], question['theme']
  }
}

/// Example 2: Using Australian words in Word Woods
class WordWoodsWithAustralian {
  void generateSpellingQuestion() {
    // Get a random Australian animal word
    // final animalWord = LiteracyWordBank.getRandomAustralianWord('animals');
    // Returns: 'kangaroo', 'koala', 'wombat', etc.
    // Display to user: "Spell this Australian animal: $animalWord"
  }
  
  void checkSpelling(String userInput) {
    // Verify Australian spelling
    final correctSpelling = LiteracyWordBank.australianSpelling[userInput.toLowerCase()];
    
    if (correctSpelling != null) {
      // Australian spelling found: $correctSpelling
    }
  }
}

/// Example 3: Comprehensive NAPLAN practice mode
class NAPLANPracticeMode {
  List<Map<String, dynamic>> questions = [];
  int currentQuestion = 0;
  int score = 0;
  
  void generatePracticeTest(int yearLevel, int questionCount) {
    questions.clear();
    
    if (yearLevel <= 2) {
      // Year 1-2 test
      for (int i = 0; i < questionCount; i++) {
        final topics = ['addition', 'subtraction', 'counting', 'money'];
        final topic = topics[i % topics.length];
        questions.add(AustralianNAPLANQuestions.generateYear1Numeracy(topic, 1 + (i ~/ 5)));
      }
    } else {
      // Year 3-4 test
      for (int i = 0; i < questionCount; i++) {
        final topics = ['multiplication', 'division', 'fractions', 'measurement'];
        final topic = topics[i % topics.length];
        questions.add(AustralianNAPLANQuestions.generateYear3Numeracy(topic, 1 + (i ~/ 5)));
      }
    }
  }
  
  Map<String, dynamic>? getNextQuestion() {
    if (currentQuestion < questions.length) {
      return questions[currentQuestion++];
    }
    return null;
  }
  
  void checkAnswer(dynamic userAnswer) {
    final question = questions[currentQuestion - 1];
    if (userAnswer.toString() == question['answer'].toString()) {
      score += 10;
      // Correct answer - update score
    } else {
      // Incorrect - expected answer: ${question['answer']}
    }
  }
  
  Map<String, dynamic> getResults() {
    return {
      'score': score,
      'total': questions.length * 10,
      'percentage': (score / (questions.length * 10) * 100).round(),
      'questionsAnswered': currentQuestion,
    };
  }
}

/// Example 4: Australian vocabulary quiz
class AustralianVocabularyQuiz {
  void generateQuiz() {
    const categories = ['animals', 'food', 'places', 'sports', 'slang', 'school'];
    
    // Example: iterate through categories and generate vocabulary quiz
    // for each category (e.g., getRandomAustralianWord(category))
    for (final _ in categories) {
      // Each category would generate a random word for the quiz
    }
  }
  
  List<String> getAustralianAnimals() {
    return LiteracyWordBank.australianVocabulary['animals']!;
    // Returns: ['kangaroo', 'koala', 'wombat', 'platypus', ...]
  }
  
  List<String> getAustralianFood() {
    return LiteracyWordBank.australianVocabulary['food']!;
    // Returns: ['lamington', 'pavlova', 'Vegemite', 'Tim Tam', ...]
  }
}

/// Example 5: Mixed literacy and numeracy NAPLAN test
class ComprehensiveNAPLANTest {
  void generateMixedTest(int yearLevel) {
    // === NAPLAN Practice Test Year $yearLevel ===
    
    // Numeracy section (5 questions)
    for (int i = 0; i < 5; i++) {
      // Example numeracy question:
      // yearLevel <= 2 ? generateYear1Numeracy : generateYear3Numeracy
      // Q${i + 1}: [question] (Answer: [answer])
    }
    
    // Literacy section (5 questions)
    for (int i = 0; i < 5; i++) {
      // Example literacy question:
      // yearLevel <= 2 ? generateYear1Literacy : generateYear3Literacy
      // Q${i + 6}: [question] (Answer: [answer])
    }
  }
}

/// Example 6: Spelling test with Australian English
class AustralianSpellingTest {
  List<String> testWords = [];
  
  void generateSpellingTest(int difficulty) {
    testWords.clear();
    
    // Get Australian spelling words by difficulty
    final wordLists = {
      1: ['colour', 'favourite', 'centre', 'metre', 'neighbour'],
      2: ['honour', 'harbour', 'theatre', 'fibre', 'litre'],
      3: ['organise', 'realise', 'recognise', 'analyse', 'defence'],
    };
    
    testWords = wordLists[difficulty] ?? wordLists[1]!;
  }
  
  bool checkSpelling(String word, String userAttempt) {
    return word.toLowerCase() == userAttempt.toLowerCase();
  }
  
  void showCommonMistakes() {
    // Common Australian spelling mistakes to avoid:
    LiteracyWordBank.australianSpelling.forEach((correct, aussie) {
      // Examples:
      // ❌ colour  →  ✓ color
      // ❌ favourite  →  ✓ favorite
      // ❌ theatre  →  ✓ theater
    });
  }
}

/// Example 7: Word problem generator with Australian contexts
class AustralianWordProblems {
  String generateRandomProblem(int yearLevel, String topic) {
    final question = yearLevel <= 2
        ? AustralianNAPLANQuestions.generateYear1Numeracy(topic, 1)
        : AustralianNAPLANQuestions.generateYear3Numeracy(topic, 2);
    
    return '''
Problem: ${question['question']}

Theme: ${question['theme']}
Type: ${question['type']}
Difficulty: ${question['difficulty']}

Answer: ${question['answer']}
    ''';
  }
}

// ============================================
// USAGE EXAMPLES
// ============================================

void main() {
  // === BrightBound Adventures: Australian NAPLAN Integration Examples ===
  
  // Example 1: Number game with Australian context
  final numberGame = NumberNebulaWithNAPLAN();
  numberGame.generateQuestion(1, 2); // Year 2, difficulty 1
  
  // Example 2: Spelling with Australian words
  final wordGame = WordWoodsWithAustralian();
  wordGame.generateSpellingQuestion();
  
  // Example 3: NAPLAN practice test
  final practice = NAPLANPracticeMode();
  practice.generatePracticeTest(3, 10); // Year 3, 10 questions
  // final question = practice.getNextQuestion();
  
  // Example 4: Australian vocabulary quiz
  final vocabQuiz = AustralianVocabularyQuiz();
  vocabQuiz.generateQuiz();
  
  // Example 5: Comprehensive test
  final comprehensive = ComprehensiveNAPLANTest();
  comprehensive.generateMixedTest(2);
  
  // Example 6: Spelling test
  final spellingTest = AustralianSpellingTest();
  spellingTest.generateSpellingTest(2);
  spellingTest.showCommonMistakes();
  
  // Example 7: Word problems
  final wordProblems = AustralianWordProblems();
  wordProblems.generateRandomProblem(3, 'multiplication');
}
