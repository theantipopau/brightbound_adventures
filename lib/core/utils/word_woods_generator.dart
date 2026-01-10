import 'dart:math';
import 'package:brightbound_adventures/features/literacy/models/question.dart';
import 'package:brightbound_adventures/core/utils/enhanced_question_generator.dart';

/// Enhanced question generator for Word Woods (Literacy) - 10x more variety!
class WordWoodsQuestionGenerator {
  static final Random _random = Random();

  /// Generate questions for different literacy skills and difficulty levels
  static List<LiteracyQuestion> generate({
    required String skill,
    required int difficulty,
    int count = 10,
  }) {
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
    final questionTypes = [
      // Phonics - beginning sounds (expanded from 8 to 50+ words)
      () {
        final word = EnhancedQuestionGenerator.getUnusedValue(
            'phonics_word', WordBanks.simpleWords);
        final correct = word[0].toUpperCase();
        final letters = [
          'A',
          'B',
          'C',
          'D',
          'F',
          'G',
          'H',
          'M',
          'P',
          'R',
          'S',
          'T'
        ];
        letters.removeWhere((l) => l == correct);
        letters.shuffle(_random);
        final options = EnhancedQuestionGenerator.smartShuffle(
          [correct, ...letters.take(3)],
          correct,
        );

        return LiteracyQuestion(
          id: 'easy_phonics_${word}_$index',
          skillId: 'phonics',
          question: 'What letter does "$word" start with?',
          options: options,
          correctIndex: options.indexOf(correct),
          hint: 'Say the word slowly: $word',
          explanation: '"$word" starts with the letter $correct!',
          difficulty: 1,
        );
      },
      // Rhyming words (NEW!)
      () {
        final family = WordBanks.rhymeFamilies.entries.elementAt(
          _random.nextInt(WordBanks.rhymeFamilies.length),
        );
        final rhymeWords = family.value;
        final word1 = rhymeWords[_random.nextInt(rhymeWords.length)];
        final word2 = rhymeWords.where((w) => w != word1).elementAt(
              _random.nextInt(rhymeWords.length - 1),
            );

        final nonRhymingWords = WordBanks.simpleWords
            .where((w) => !rhymeWords.contains(w))
            .toList();
        nonRhymingWords.shuffle(_random);

        final options = EnhancedQuestionGenerator.smartShuffle(
          [word2, ...nonRhymingWords.take(3)],
          word2,
        );

        return LiteracyQuestion(
          id: 'easy_rhyme_${word1}_$index',
          skillId: 'rhyming',
          question: 'Which word rhymes with "$word1"?',
          options: options,
          correctIndex: options.indexOf(word2),
          hint: 'Say both words out loud and listen to the endings.',
          explanation:
              '"$word1" and "$word2" rhyme! They both end with "-${family.key}".',
          difficulty: 1,
        );
      },
      // Sight words with context - more challenging
      () {
        final sightWordQuestions = {
          'the': 'Complete: "___ cat sat down.',
          'and': 'Complete: "I like apples ___ oranges.',
          'is': 'Complete: "She ___ very clever.',
          'you': 'Complete: "Hello, how are ___?"',
          'said': 'Complete: "She ___ goodbye.',
          'was': 'Complete: "It ___ a sunny day.',
          'are': 'Complete: "We ___ happy.",',
          'his': 'Complete: "This is ___ ball."',
          'have': 'Complete: "I ___ a pet dog."',
          'from': 'Complete: "I come ___ Australia."',
        };
        
        final word = sightWordQuestions.keys.toList()[_random.nextInt(sightWordQuestions.length)];
        final question = sightWordQuestions[word]!;
        final wrongWords = sightWordQuestions.keys.where((w) => w != word).toList();
        wrongWords.shuffle(_random);
        final options = EnhancedQuestionGenerator.smartShuffle(
          [word, ...wrongWords.take(3)],
          word,
        );

        return LiteracyQuestion(
          id: 'easy_sight_${word}_$index',
          skillId: 'sight_words',
          question: question,
          options: options,
          correctIndex: options.indexOf(word),
          hint: 'Read the sentence carefully. Which word makes sense?',
          explanation: '"$word" completes the sentence correctly!',
          difficulty: 1,
        );
      },
      // Simple spelling - improved with actual misspellings
      () {
        final words = {
          'cat': ['cat', 'kat', 'catt', 'cet'],
          'dog': ['dog', 'dag', 'dug', 'dug'],
          'sun': ['sun', 'son', 'sun', 'sunn'],
          'bat': ['bat', 'batt', 'bet', 'baht'],
          'pig': ['pig', 'peg', 'pyg', 'piq'],
          'run': ['run', 'runn', 'ren', 'ruen'],
          'fun': ['fun', 'funn', 'fon', 'fune'],
          'cup': ['cup', 'cupp', 'cop', 'kup'],
          'sit': ['sit', 'sitt', 'set', 'syt'],
          'hat': ['hat', 'hatt', 'het', 'hatt'],
          'rat': ['rat', 'ratt', 'ret', 'raht'],
          'mat': ['mat', 'mitt', 'met', 'maht'],
        };
        final entry = words.entries.elementAt(_random.nextInt(words.length));
        // Remove duplicates from misspellings
        final uniqueOptions = entry.value.toSet().toList();
        // Ensure we have exactly 4 options
        final finalOptions = uniqueOptions.length >= 4 
          ? uniqueOptions.take(4).toList()
          : [...uniqueOptions, '${entry.key}x', '${entry.key}h', '${entry.key}z'].take(4).toList();
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(finalOptions, entry.key);

        return LiteracyQuestion(
          id: 'easy_spell_${entry.key}_$index',
          skillId: 'spelling',
          question: 'Which is spelled correctly?',
          options: shuffled,
          correctIndex: shuffled.indexOf(entry.key),
          hint: 'Sound it out letter by letter.',
          explanation: '"${entry.key}" is spelled correctly!',
          difficulty: 1,
        );
      },
    ];

    return questionTypes[_random.nextInt(questionTypes.length)]();
  }

  static LiteracyQuestion _generateMediumQuestion(int index) {
    final questionTypes = [
      // Homophones (expanded)
      () {
        final homoSet = EnhancedQuestionGenerator.getUnusedValue(
          'homophones_med',
          WordBanks.homophones,
        );
        final correct = homoSet.keys.first;
        final meaning = homoSet[correct]!;
        final allWords = homoSet.keys.toList();
        allWords.shuffle(_random);

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
          hint: 'Think about what each word means, not how it sounds.',
          explanation: '"$correct" means $meaning!',
          difficulty: 3,
        );
      },
      // Vocabulary - improved with more variety
      () {
        final vocab = {
          'happy': ['joyful', 'sad', 'angry', 'sleepy'],
          'big': ['large', 'tiny', 'short', 'thin'],
          'fast': ['quick', 'slow', 'heavy', 'tall'],
          'smart': ['clever', 'foolish', 'tired', 'hungry'],
          'brave': ['courageous', 'scared', 'weak', 'silly'],
        };
        final entry = vocab.entries.elementAt(_random.nextInt(vocab.length));
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(entry.value, entry.value[0]);

        return LiteracyQuestion(
          id: 'med_vocab_${entry.key}_$index',
          skillId: 'vocabulary',
          question: 'What word means the same as "${entry.key}"?',
          options: shuffled,
          correctIndex: shuffled.indexOf(entry.value[0]),
          hint: 'A synonym is a word with the same meaning.',
          explanation: '"${entry.value[0]}" is a synonym of "${entry.key}"!',
          difficulty: 3,
        );
      },
      // Grammar - parts of speech
      () {
        final sentences = [
          (
            'The cat runs fast.',
            'runs',
            'verb',
            ['verb', 'noun', 'adjective', 'adverb']
          ),
          (
            'The blue sky.',
            'blue',
            'adjective',
            ['adjective', 'noun', 'verb', 'adverb']
          ),
          (
            'The happy dog barks.',
            'dog',
            'noun',
            ['noun', 'verb', 'adjective', 'adverb']
          ),
        ];
        final sent = sentences[_random.nextInt(sentences.length)];

        return LiteracyQuestion(
          id: 'med_grammar_${sent.$2}_$index',
          skillId: 'grammar',
          question: 'In "${sent.$1}", what type of word is "${sent.$2}"?',
          options: sent.$4,
          correctIndex: sent.$4.indexOf(sent.$3),
          hint:
              'A noun is a thing, a verb is an action, an adjective describes.',
          explanation: '"${sent.$2}" is a ${sent.$3}!',
          difficulty: 3,
        );
      },
    ];

    return questionTypes[_random.nextInt(questionTypes.length)]();
  }

  static LiteracyQuestion _generateHardQuestion(int index) {
    final questionTypes = [
      // Complex vocabulary
      () {
        final vocab = {
          'magnificent': ['amazing', 'boring', 'ugly', 'small'],
          'peculiar': ['strange', 'normal', 'happy', 'fast'],
          'ancient': ['very old', 'new', 'happy', 'large'],
          'enthusiastic': ['excited', 'bored', 'sleepy', 'angry'],
          'cautious': ['careful', 'careless', 'fast', 'loud'],
        };

        final entry = vocab.entries.elementAt(_random.nextInt(vocab.length));
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(entry.value, entry.value[0]);

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
      },
      // Context clues (NEW!)
      () {
        final contexts = [
          {
            'text':
                'The enormous elephant was so large it barely fit through the gate.',
            'word': 'enormous',
            'meaning': 'very big',
            'options': ['very big', 'very small', 'very fast', 'very slow'],
          },
          {
            'text': 'She felt famished after not eating all day.',
            'word': 'famished',
            'meaning': 'very hungry',
            'options': ['very hungry', 'very full', 'very happy', 'very tired'],
          },
        ];

        final ctx = contexts[_random.nextInt(contexts.length)];
        return LiteracyQuestion(
          id: 'hard_context_${ctx['word']}_$index',
          skillId: 'context_clues',
          question: '${ctx['text']}\n\nWhat does "${ctx['word']}" mean?',
          options: ctx['options'] as List<String>,
          correctIndex: 0,
          hint: 'Use clues from the rest of the sentence.',
          explanation:
              'From the context, "${ctx['word']}" means ${ctx['meaning']}!',
          difficulty: 5,
        );
      },
    ];

    return questionTypes[_random.nextInt(questionTypes.length)]();
  }
}
