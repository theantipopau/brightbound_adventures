import 'dart:math';
import 'package:brightbound_adventures/features/literacy/models/question.dart';

/// Comprehensive question generator for Word Woods (Literacy)
class WordWoodsQuestionGenerator {
  static final Random _random = Random();
  
  /// Generate questions for different literacy skills and difficulty levels
  static List<LiteracyQuestion> generate({
    required String skill,
    required int difficulty,
    int count = 10,
  }) {
    // Generate based on difficulty level with varied questions
    final questions = <LiteracyQuestion>[];
    
    for (int i = 0; i < count; i++) {
      questions.add(_generateSingleQuestion(difficulty, i));
    }
    
    return questions;
  }
  
  static LiteracyQuestion _generateSingleQuestion(int difficulty, int index) {
    if (difficulty <= 2) {
      return _generateEasyQuestion(index);
    } else if (difficulty <= 4) {
      return _generateMediumQuestion(index);
    } else {
      return _generateHardQuestion(index);
    }
  }
  
  static LiteracyQuestion _generateEasyQuestion(int index) {
    final questionTypes = [
      // Phonics - beginning sounds
      () {
        final words = ['cat', 'dog', 'sun', 'bat', 'pig', 'hen', 'fox', 'cup'];
        final word = words[_random.nextInt(words.length)];
        final correct = word[0].toUpperCase();
        final options = [correct, 'B', 'D', 'M']..shuffle(_random);
        return LiteracyQuestion(
          id: 'easy_$index',
          skillId: 'phonics',
          question: 'What letter does "$word" start with?',
          options: options,
          correctIndex: options.indexOf(correct),
          hint: 'Say the word slowly.',
          difficulty: 1,
        );
      },
      // Simple spelling
      () {
        final words = {'cat': ['cat', 'kat', 'cot', 'bat'],
                      'dog': ['dog', 'dag', 'dig', 'log'],
                      'sun': ['sun', 'son', 'san', 'bun']};
        final entry = words.entries.elementAt(_random.nextInt(words.length));
        return LiteracyQuestion(
          id: 'easy_$index',
          skillId: 'spelling',
          question: 'Which is spelled correctly?',
          options: entry.value,
          correctIndex: 0,
          hint: 'Sound it out letter by letter.',
          difficulty: 1,
        );
      },
    ];
    
    return questionTypes[_random.nextInt(questionTypes.length)]();
  }
  
  static LiteracyQuestion _generateMediumQuestion(int index) {
    final questionTypes = [
      // Vocabulary
      () {
        final vocab = {
          'happy': ['joyful', 'sad', 'angry', 'sleepy'],
          'big': ['large', 'tiny', 'short', 'thin'],
          'fast': ['quick', 'slow', 'heavy', 'tall'],
        };
        final entry = vocab.entries.elementAt(_random.nextInt(vocab.length));
        return LiteracyQuestion(
          id: 'med_$index',
          skillId: 'vocabulary',
          question: 'What word means the same as "${entry.key}"?',
          options: entry.value,
          correctIndex: 0,
          hint: 'Think of another word with the same meaning.',
          difficulty: 3,
        );
      },
      // Grammar
      () {
        final sentences = [
          ('The cat runs fast.', 'runs', ['verb', 'noun', 'adjective', 'adverb']),
          ('The blue sky.', 'blue', ['adjective', 'noun', 'verb', 'adverb']),
        ];
        final sent = sentences[_random.nextInt(sentences.length)];
        return LiteracyQuestion(
          id: 'med_$index',
          skillId: 'grammar',
          question: 'In "${sent.$1}", what type of word is "${sent.$2}"?',
          options: sent.$3,
          correctIndex: 0,
          hint: 'What does the word do in the sentence?',
          difficulty: 3,
        );
      },
    ];
    
    return questionTypes[_random.nextInt(questionTypes.length)]();
  }
  
  static LiteracyQuestion _generateHardQuestion(int index) {
    // Complex vocabulary and comprehension
    final vocab = {
      'magnificent': ['amazing', 'boring', 'ugly', 'small'],
      'peculiar': ['strange', 'normal', 'happy', 'fast'],
      'ancient': ['very old', 'new', 'happy', 'large'],
    };
    
    final entry = vocab.entries.elementAt(_random.nextInt(vocab.length));
    return LiteracyQuestion(
      id: 'hard_$index',
      skillId: 'vocabulary',
      question: 'What does "${entry.key}" mean?',
      options: entry.value,
      correctIndex: 0,
      hint: 'Think about the context where you\'ve seen this word.',
      difficulty: 5,
    );
  }
}
