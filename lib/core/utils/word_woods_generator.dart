import 'dart:math';
import 'package:brightbound_adventures/features/literacy/models/question.dart';
import 'package:brightbound_adventures/core/utils/enhanced_question_generator.dart';
import 'package:brightbound_adventures/core/utils/literacy_skill_questions.dart';

/// Enhanced question generator for Word Woods (Literacy)
/// Uses skill-specific question banks with curated, relevant content
class WordWoodsQuestionGenerator {
  /// Generate questions for different literacy skills and difficulty levels
  static List<LiteracyQuestion> generate({
    required String skill,
    required int difficulty,
    int count = 10,
  }) {
    // Use skill-specific question banks
    final bankQuestions = LiteracySkillQuestions.getQuestions(
      skill: skill,
      difficulty: difficulty,
      count: count,
    );

    if (bankQuestions.isNotEmpty) {
      return bankQuestions;
    }

    // Fallback to legacy generation if skill not found
    final questions = <LiteracyQuestion>[];
    for (int i = 0; i < count; i++) {
      final question = _generateUniqueQuestion(skill, difficulty, i);
      EnhancedQuestionGenerator.markAsUsed(question.id);
      questions.add(question);
    }
    return questions;
  }

  static LiteracyQuestion _generateUniqueQuestion(
      String skill, int difficulty, int index) {
    for (int attempt = 0; attempt < 5; attempt++) {
      final question = _generateSingleQuestion(difficulty, index);
      if (!EnhancedQuestionGenerator.wasRecentlyUsed(question.id)) {
        return question;
      }
    }
    return _generateSingleQuestion(difficulty, index);
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
    // Fallback implementation for skills not in skill-based banks
    final questionTypes = [
      () {
        final word = EnhancedQuestionGenerator.getUnusedValue(
            'phonics_word', WordBanks.simpleWords);
        final correct = word[0].toUpperCase();
        final letters = [
          'A', 'B', 'C', 'D', 'F', 'G', 'H', 'M', 'P', 'R', 'S', 'T'
        ];
        letters.removeWhere((l) => l == correct);
        letters.shuffle(Random());

        return LiteracyQuestion(
          id: 'easy_phonics_${word}_$index',
          skillId: 'phonics',
          question: 'What letter does "$word" start with?',
          options: [correct, ...letters.take(3)],
          correctIndex: 0,
          hint: 'Say the word slowly: $word',
          explanation: '"$word" starts with the letter $correct!',
          difficulty: 1,
        );
      }
    ];

    return questionTypes[Random().nextInt(questionTypes.length)]();
  }

  static LiteracyQuestion _generateMediumQuestion(int index) {
    final questionTypes = [
      () {
        final homoSet = EnhancedQuestionGenerator.getUnusedValue(
          'homophones_med',
          WordBanks.homophones,
        );
        final correct = homoSet.keys.first;
        final meaning = homoSet[correct]!;
        final allWords = homoSet.keys.toList();
        allWords.shuffle(Random());

        final options = EnhancedQuestionGenerator.smartShuffle(
          [...allWords, 'then'].take(4).toList(),
          correct,
        );

        return LiteracyQuestion(
          id: 'med_homo_${correct}_$index',
          skillId: 'homophones',
          question: 'Which word means "$meaning"?',
          options: options,
          correctIndex: options.indexOf(correct),
          hint: 'These words sound the same but mean different things.',
          explanation: '"$correct" means $meaning!',
          difficulty: 3,
        );
      }
    ];

    return questionTypes[Random().nextInt(questionTypes.length)]();
  }

  static LiteracyQuestion _generateHardQuestion(int index) {
    final random = Random();
    final questionTypes = [
      () {
        final vocab = {
          'magnificent': ['amazing', 'boring', 'ugly', 'small'],
          'peculiar': ['strange', 'normal', 'happy', 'fast'],
          'ancient': ['very old', 'new', 'happy', 'large'],
          'enthusiastic': ['excited', 'bored', 'sleepy', 'angry'],
        };

        final entry = vocab.entries.elementAt(random.nextInt(vocab.length));
        final shuffled = EnhancedQuestionGenerator.smartShuffle(
          entry.value,
          entry.value[0],
        );

        return LiteracyQuestion(
          id: 'hard_vocab_${entry.key}_$index',
          skillId: 'vocabulary',
          question: 'What does "${entry.key}" mean?',
          options: shuffled,
          correctIndex: shuffled.indexOf(entry.value[0]),
          hint: 'Think about contexts where you might use this word.',
          explanation: '"${entry.key}" means ${entry.value[0]}!',
          difficulty: 5,
        );
      }
    ];

    return questionTypes[random.nextInt(questionTypes.length)]();
  }
}
