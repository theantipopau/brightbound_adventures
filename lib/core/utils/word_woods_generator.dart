import 'dart:math';
import 'package:brightbound_adventures/features/literacy/models/question.dart';
import 'package:brightbound_adventures/core/utils/enhanced_question_generator.dart';
import 'package:brightbound_adventures/core/utils/literacy_skill_questions.dart';
import 'package:brightbound_adventures/core/utils/australian_naplan_questions.dart';
import 'package:brightbound_adventures/core/utils/literacy_word_bank.dart';

/// Enhanced question generator for Word Woods (Literacy)
/// Uses skill-specific question banks with curated, relevant content
class WordWoodsQuestionGenerator {
  static final Random _random = Random();

  /// Generate questions for different literacy skills and difficulty levels
  static List<LiteracyQuestion> generate({
    required String skill,
    required int difficulty,
    int count = 10,
  }) {
    // 1. Try to get curated questions from the bank
    final bankQuestions = LiteracySkillQuestions.getQuestions(
      skill: skill,
      difficulty: difficulty,
      count: count,
    );

    final questions = <LiteracyQuestion>[...bankQuestions];

    // 2. Mix in some NAPLAN questions if appropriate (30% chance)
    if (questions.length < count) {
      final naplanCount = (count - questions.length);
      for (int i = 0; i < naplanCount; i++) {
        if (_random.nextDouble() < 0.4) { // 40% chance for NAPLAN
          final naplan = _fromNAPLAN(skill, difficulty, i);
          if (naplan != null) {
            questions.add(naplan);
          }
        }
      }
    }

    // 3. Fallback to procedural generation if still needed
    if (questions.length < count) {
      final remaining = count - questions.length;
      final offset = questions.length; // Ensure IDs are unique
      for (int i = 0; i < remaining; i++) {
         // Mix procedural types to avoid repetition
         LiteracyQuestion question;
         if (_random.nextDouble() < 0.7 && LiteracyWordBank.storyThemes.isNotEmpty) {
            question = _generateProceduralThemeQuestion(difficulty, offset + i);
         } else {
            question = _generateUniqueQuestion(skill, difficulty, offset + i);
         }
        // Mark used not strictly necessary for procedural but good practice
        // EnhancedQuestionGenerator.markAsUsed(question.id); 
        questions.add(question);
      }
    }

    // Sort to mix curated and procedural
    questions.shuffle(_random);
    return questions.take(count).toList();
  }

  /// Adapt NAPLAN question format to LiteracyQuestion format
  static LiteracyQuestion? _fromNAPLAN(String skill, int difficulty, int index) {
    String topic = 'spelling';
    final s = skill.toLowerCase();
    
    if (s.contains('spell')) {
      topic = 'spelling';
    } else if (s.contains('read') || s.contains('comprehension')) {
      topic = 'reading';
    } else if (s.contains('grammar') || s.contains('sentence')) {
      topic = 'grammar';
    } else if (s.contains('vocab')) {
      topic = 'vocabulary';
      if (_random.nextBool()) topic = 'spelling'; // Mix
    } else if (s.contains('punct')) {
      topic = 'punctuation';
    } else {
      // Default fallback
      topic = ['spelling', 'reading', 'grammar'][_random.nextInt(3)];
    }

    Map<String, dynamic> data;
    if (difficulty >= 3) {
      data = AustralianNAPLANQuestions.generateYear3Literacy(topic, difficulty);
    } else {
      data = AustralianNAPLANQuestions.generateYear1Literacy(topic, difficulty);
    }

    if (!data.containsKey('question') || !data.containsKey('options')) return null;

    final options = List<String>.from(data['options']);
    final answerStr = data['answer']?.toString();
    int correctIdx = 0;
    
    if (answerStr != null) {
      correctIdx = options.indexOf(answerStr);
      if (correctIdx == -1) correctIdx = 0;
    }

    return LiteracyQuestion(
      id: 'naplan_lit_${topic}_${difficulty}_$index',
      skillId: skill,
      question: data['question'] as String,
      options: options,
      correctIndex: correctIdx,
      explanation: data['explanation'] as String?,
      hint: 'This is a NAPLAN-style practice question.',
      difficulty: difficulty,
    );
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

    return questionTypes[_random.nextInt(questionTypes.length)]();
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

    return questionTypes[_random.nextInt(questionTypes.length)]();
  }

  static LiteracyQuestion _generateHardQuestion(int index) {
    final questionTypes = [
      () {
        final vocab = {
          'magnificent': ['amazing', 'boring', 'ugly', 'small'],
          'peculiar': ['strange', 'normal', 'happy', 'fast'],
          'ancient': ['very old', 'new', 'happy', 'large'],
          'enthusiastic': ['excited', 'bored', 'sleepy', 'angry'],
        };

        final entry = vocab.entries.elementAt(_random.nextInt(vocab.length));
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

    return questionTypes[_random.nextInt(questionTypes.length)]();
  }
  
  /// Procedurally generates questions based on Story Themes (Space, Ocean, etc)
  /// This creates infinite variety by mixing themes, categories, and word choices.
  static LiteracyQuestion _generateProceduralThemeQuestion(int difficulty, int index) {
     // Pick a random theme
     final themes = LiteracyWordBank.storyThemes.keys.toList();
     final theme = themes[_random.nextInt(themes.length)];
     final data = LiteracyWordBank.storyThemes[theme]!;
     
     final nouns = List<String>.from(data['nouns'] as List);
     final verbs = List<String>.from(data['verbs'] as List);
     final adjs = List<String>.from(data['adjectives'] as List);
     final emoji = data['emoji'] as String;

     // 1. Identification Question (Easy/Medium)
     // "Which word is a NOUN/VERB from the [Theme] theme?"
     if (difficulty <= 2 || (difficulty == 3 && _random.nextBool())) {
        String typeTarget;
        List<String> correctList;
        List<String> distractors;
        String typeName;
        
        int r = _random.nextInt(3);
        if (r == 0) {
           typeTarget = 'noun'; typeName = 'Naming Word (Noun)'; correctList = nouns; distractors = [...verbs, ...adjs];
        } else if (r == 1) {
           typeTarget = 'verb'; typeName = 'Action Word (Verb)'; correctList = verbs; distractors = [...nouns, ...adjs];
        } else {
           typeTarget = 'adj'; typeName = 'Describing Word (Adjective)'; correctList = adjs; distractors = [...nouns, ...verbs];
        }
        
        final correct = correctList[_random.nextInt(correctList.length)];
        distractors.shuffle();
        final options = [correct, ...distractors.take(3)].toList()..shuffle();

        return LiteracyQuestion(
           id: 'theme_${theme}_${typeTarget}_$index',
           skillId: 'vocabulary',
           question: '$emoji Theme: $theme\nWhich word is a $typeName?',
           options: options,
           correctIndex: options.indexOf(correct),
           hint: 'Think about words related to $theme.',
           explanation: '"$correct" is a $typeName related to $theme.',
           difficulty: difficulty
        );
     }
     
     // 2. Context Sentence Question (Medium/Hard)
     // "The [noun] will [verb]..."
     // "The [adj] [noun]..."
     else {
        final noun = nouns[_random.nextInt(nouns.length)];
        final verb = verbs[_random.nextInt(verbs.length)];
        
        // 50% chance missing Verb, 50% missing Noun
        bool missingVerb = _random.nextBool();
        
        String qText;
        String correct;
        List<String> options;
        
        if (missingVerb) {
           qText = 'Complete the sentence:\nThe $noun will _____ into $theme.';
           correct = verb;
           
           // Distractors: Random verbs from OTHER themes or basic verbs
           final otherVerbs = ['sleep', 'eat', 'read', 'run'];
           options = [correct, ...otherVerbs.take(3)].toList()..shuffle();
           
           return LiteracyQuestion(
             id: 'sent_comp_verb_${theme}_$index',
             skillId: 'grammar',
             question: qText,
             options: options,
             correctIndex: options.indexOf(correct),
             hint: 'What action would a $noun do in $theme?',
             explanation: 'In $theme, a $noun might $correct.',
             difficulty: difficulty
           );
        } else {
           qText = 'Complete the sentence:\nThe _____ will $verb through the $theme.';
           correct = noun;
           
           // Distractors: Random nouns
           final otherNouns = ['apple', 'chair', 'spoon', 'shoe'];
           options = [correct, ...otherNouns.take(3)].toList()..shuffle();
           
            return LiteracyQuestion(
             id: 'sent_comp_noun_${theme}_$index',
             skillId: 'grammar',
             question: qText,
             options: options,
             correctIndex: options.indexOf(correct),
             hint: 'What object or person belongs in $theme?',
             explanation: 'A $noun belongs in $theme.',
             difficulty: difficulty
           );
        }
     }
  }
}
