import 'dart:math';
import 'package:brightbound_adventures/features/storytelling/models/question.dart';

/// Comprehensive question generator for Story Springs (Storytelling & Creative Writing)
class StorySpringsQuestionGenerator {
  static final Random _random = Random();
  
  /// Generate questions for different storytelling skills and difficulty levels
  static List<StoryQuestion> generate({
    required String skill,
    required int difficulty,
    int count = 10,
  }) {
    final questions = <StoryQuestion>[];
    
    for (int i = 0; i < count; i++) {
      questions.add(_generateSingleQuestion(difficulty, i));
    }
    
    return questions;
  }
  
  static StoryQuestion _generateSingleQuestion(int difficulty, int index) {
    if (difficulty <= 2) {
      return _generateEasyQuestion(index);
    } else if (difficulty <= 4) {
      return _generateMediumQuestion(index);
    } else {
      return _generateHardQuestion(index);
    }
  }
  
  static StoryQuestion _generateEasyQuestion(int index) {
    final questionTypes = [
      // Story sequencing - simple 3-part
      () {
        final sequences = [
          {
            'question': 'What happens FIRST when making breakfast?',
            'options': ['Wake up', 'Eat breakfast', 'Wash dishes', 'Go to school'],
            'correct': 0,
          },
          {
            'question': 'What happens LAST when getting ready for bed?',
            'options': ['Brush teeth', 'Put on pajamas', 'Go to sleep', 'Read a book'],
            'correct': 2,
          },
          {
            'question': 'What comes FIRST in a story?',
            'options': ['The beginning', 'The middle', 'The end', 'The title page'],
            'correct': 0,
          },
        ];
        
        final seq = sequences[_random.nextInt(sequences.length)];
        return StoryQuestion(
          id: 'easy_$index',
          skillId: 'sequencing',
          question: seq['question'] as String,
          options: seq['options'] as List<String>,
          correctIndex: seq['correct'] as int,
          hint: 'Think about what happens first in time.',
          difficulty: 1,
          type: StoryQuestionType.sequencing,
        );
      },
      // Character emotions
      () {
        final emotions = [
          {
            'situation': 'Maria gets a birthday present she really wanted.',
            'emotion': 'Happy',
            'options': ['Happy', 'Sad', 'Angry', 'Scared'],
          },
          {
            'situation': 'Tom loses his favorite toy.',
            'emotion': 'Sad',
            'options': ['Sad', 'Happy', 'Excited', 'Proud'],
          },
          {
            'situation': 'Sarah sees a big spider.',
            'emotion': 'Scared',
            'options': ['Scared', 'Happy', 'Bored', 'Hungry'],
          },
        ];
        
        final emo = emotions[_random.nextInt(emotions.length)];
        return StoryQuestion(
          id: 'easy_$index',
          skillId: 'emotions',
          question: '${emo['situation']}\n\nHow does the character feel?',
          options: emo['options'] as List<String>,
          correctIndex: 0,
          hint: 'Think about how you would feel.',
          difficulty: 1,
          type: StoryQuestionType.emotionMatch,
        );
      },
      // Simple story completion
      () {
        final stories = [
          {
            'start': 'Once upon a time, there was a little cat. The cat was very...',
            'options': ['hungry', 'purple', 'flying', 'swimming'],
            'correct': 0,
          },
          {
            'start': 'The dog ran to the park. He wanted to...',
            'options': ['play', 'sleep', 'read', 'cook'],
            'correct': 0,
          },
        ];
        
        final story = stories[_random.nextInt(stories.length)];
        return StoryQuestion(
          id: 'easy_$index',
          skillId: 'completion',
          question: story['start'] as String,
          options: story['options'] as List<String>,
          correctIndex: story['correct'] as int,
          hint: 'What makes the most sense?',
          difficulty: 1,
          type: StoryQuestionType.fillInBlank,
        );
      },
    ];
    
    return questionTypes[_random.nextInt(questionTypes.length)]();
  }
  
  static StoryQuestion _generateMediumQuestion(int index) {
    final questionTypes = [
      // Character development
      () {
        final scenarios = [
          {
            'question': 'Sarah always helps her friends with homework. What character trait does Sarah show?',
            'options': ['Helpful', 'Selfish', 'Lazy', 'Mean'],
            'correct': 0,
          },
          {
            'question': 'Tom practices soccer every day, even when it\'s hard. What trait does Tom show?',
            'options': ['Determined', 'Careless', 'Afraid', 'Bored'],
            'correct': 0,
          },
          {
            'question': 'Emma shares her snacks with everyone. What trait does Emma show?',
            'options': ['Generous', 'Greedy', 'Shy', 'Angry'],
            'correct': 0,
          },
        ];
        
        final scenario = scenarios[_random.nextInt(scenarios.length)];
        return StoryQuestion(
          id: 'med_$index',
          skillId: 'characters',
          question: scenario['question'] as String,
          options: scenario['options'] as List<String>,
          correctIndex: scenario['correct'] as int,
          hint: 'Think about their actions and what they show.',
          difficulty: 3,
          type: StoryQuestionType.multipleChoice,
        );
      },
      // Story elements
      () {
        final elements = [
          {
            'question': 'In the story "The Three Little Pigs," what is the main problem?',
            'options': ['The wolf wants to blow down the houses', 'The pigs are hungry', 'The pigs can\'t count', 'The houses are too big'],
            'correct': 0,
          },
          {
            'question': 'What is the setting of a story?',
            'options': ['Where and when it happens', 'Who is in it', 'What happens', 'Why it happens'],
            'correct': 0,
          },
        ];
        
        final element = elements[_random.nextInt(elements.length)];
        return StoryQuestion(
          id: 'med_$index',
          skillId: 'elements',
          question: element['question'] as String,
          options: element['options'] as List<String>,
          correctIndex: element['correct'] as int,
          hint: 'Think about the important parts of a story.',
          difficulty: 3,
          type: StoryQuestionType.multipleChoice,
        );
      },
      // Cause and effect
      () {
        final causeEffect = [
          {
            'question': 'It started raining, so Sarah...',
            'options': ['opened her umbrella', 'went swimming', 'wore sunglasses', 'had a picnic'],
            'correct': 0,
          },
          {
            'question': 'The cake burned because Tom...',
            'options': ['forgot to set a timer', 'used flour', 'read the recipe', 'washed his hands'],
            'correct': 0,
          },
        ];
        
        final ce = causeEffect[_random.nextInt(causeEffect.length)];
        return StoryQuestion(
          id: 'med_$index',
          skillId: 'cause_effect',
          question: ce['question'] as String,
          options: ce['options'] as List<String>,
          correctIndex: ce['correct'] as int,
          hint: 'What would make sense to happen next?',
          difficulty: 3,
          type: StoryQuestionType.multipleChoice,
        );
      },
    ];
    
    return questionTypes[_random.nextInt(questionTypes.length)]();
  }
  
  static StoryQuestion _generateHardQuestion(int index) {
    final questionTypes = [
      // Theme identification
      () {
        final themes = [
          {
            'story': 'A girl works hard all summer to save money. She finally buys the bike she wanted.',
            'theme': 'Hard work pays off',
            'options': ['Hard work pays off', 'Always buy bikes', 'Summer is fun', 'Money is easy'],
          },
          {
            'story': 'Two friends argue but then apologize and make up. They realize friendship is more important.',
            'theme': 'Friendship is valuable',
            'options': ['Friendship is valuable', 'Arguments are good', 'Never apologize', 'Friends are perfect'],
          },
        ];
        
        final theme = themes[_random.nextInt(themes.length)];
        return StoryQuestion(
          id: 'hard_$index',
          skillId: 'theme',
          question: '${theme['story']}\n\nWhat is the theme (lesson) of this story?',
          options: theme['options'] as List<String>,
          correctIndex: 0,
          hint: 'What is the story teaching us?',
          difficulty: 5,
          type: StoryQuestionType.multipleChoice,
        );
      },
      // Point of view
      () {
        final pov = [
          {
            'question': '"I walked to the store and bought milk." What point of view is this?',
            'options': ['First person (I/me)', 'Second person (you)', 'Third person (he/she)', 'Fourth person'],
            'correct': 0,
          },
          {
            'question': '"She opened the door carefully." What point of view is this?',
            'options': ['Third person (he/she)', 'First person (I/me)', 'Second person (you)', 'No point of view'],
            'correct': 0,
          },
        ];
        
        final p = pov[_random.nextInt(pov.length)];
        return StoryQuestion(
          id: 'hard_$index',
          skillId: 'pov',
          question: p['question'] as String,
          options: p['options'] as List<String>,
          correctIndex: p['correct'] as int,
          hint: 'Who is telling the story?',
          difficulty: 5,
          type: StoryQuestionType.multipleChoice,
        );
      },
      // Creative story building
      () {
        final prompts = [
          {
            'question': 'You\'re writing a mystery story. What should happen to keep readers interested?',
            'options': ['Add clues slowly', 'Tell everything at start', 'Make it confusing', 'Have no ending'],
            'correct': 0,
          },
          {
            'question': 'Your character faces a big challenge. What makes a good solution?',
            'options': ['The character uses their skills', 'Magic fixes everything instantly', 'Someone else solves it', 'It never gets solved'],
            'correct': 0,
          },
        ];
        
        final prompt = prompts[_random.nextInt(prompts.length)];
        return StoryQuestion(
          id: 'hard_$index',
          skillId: 'creative',
          question: prompt['question'] as String,
          options: prompt['options'] as List<String>,
          correctIndex: prompt['correct'] as int,
          hint: 'Think about what makes stories engaging.',
          difficulty: 5,
          type: StoryQuestionType.storyBuilder,
        );
      },
    ];
    
    return questionTypes[_random.nextInt(questionTypes.length)]();
  }
}
