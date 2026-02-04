import 'dart:math';
import 'package:brightbound_adventures/features/science/models/question.dart';
import 'package:brightbound_adventures/core/utils/enhanced_question_generator.dart';

class ScienceQuestGenerator {
  static final Random _random = Random();
  
  static List<ScienceQuestion> generate({
    required String theme,
    required int difficulty,
    int count = 10,
  }) {
     final questions = <ScienceQuestion>[];
     
     for (int i = 0; i < count; i++) {
        questions.add(_generateSingleQuestion(theme, difficulty, i));
     }
     
     return questions;
  }
  
  static ScienceQuestion _generateSingleQuestion(String theme, int difficulty, int index) {
      if (theme.toLowerCase().contains('animal') || theme.toLowerCase().contains('living')) {
          return _generateLivingThingsQuestion(difficulty, index);
      } else if (theme.toLowerCase().contains('material')) {
          return _generateMaterialsQuestion(difficulty, index);
      } else if (theme.toLowerCase().contains('season') || theme.toLowerCase().contains('weather')) {
          return _generateSeasonsQuestion(difficulty, index);
      } else {
          // Mixed bag
          int r = _random.nextInt(3);
          if (r == 0) return _generateLivingThingsQuestion(difficulty, index);
          if (r == 1) return _generateMaterialsQuestion(difficulty, index);
          return _generateSeasonsQuestion(difficulty, index);
      }
  }
  
  static ScienceQuestion _generateLivingThingsQuestion(int difficulty, int index) {
      // Classification
      final groups = {
          'Mammal': ['Dog', 'Cat', 'Human', 'Whale', 'Lion'],
          'Bird': ['Eagle', 'Penguin', 'Parrot', 'Duck', 'Owl'],
          'Reptile': ['Snake', 'Lizard', 'Turtle', 'Crocodile'],
          'Insect': ['Bee', 'Ant', 'Butterfly', 'Beetle']
      };
      
      final targetGroup = groups.keys.elementAt(_random.nextInt(groups.length));
      final correct = groups[targetGroup]![_random.nextInt(groups[targetGroup]!.length)];
      
      // Distractors from other groups
      final otherGroups = groups.keys.where((k) => k != targetGroup).toList();
      final distractors = <String>[];
      for (var i = 0; i < 3; i++) {
          final g = otherGroups[_random.nextInt(otherGroups.length)];
          distractors.add(groups[g]![_random.nextInt(groups[g]!.length)]);
      }
      
      final options = EnhancedQuestionGenerator.smartShuffle([correct, ...distractors], correct);
      
      return ScienceQuestion(
          id: 'sci_living_$index',
          question: 'Which of these is a $targetGroup?',
          options: options,
          correctIndex: options.indexOf(correct),
          difficulty: difficulty,
          topic: 'Living Things',
          explanation: '$correct is a $targetGroup.'
      );
  }
  
  static ScienceQuestion _generateMaterialsQuestion(int difficulty, int index) {
      final materials = {
          'Glass': {'prop': 'transparent', 'items': ['Window', 'Jar', 'Screen']},
          'Wood': {'prop': 'from trees', 'items': ['Table', 'Pencil', 'Log']},
          'Metal': {'prop': 'shiny and hard', 'items': ['Coin', 'Key', 'Spoon']},
          'Wool': {'prop': 'soft and warm', 'items': ['Jumper', 'Scarf', 'Blanket']}
      };
      
      final m = materials.keys.elementAt(_random.nextInt(materials.length));
      final data = materials[m]!;
      final items = data['items'] as List<String>;
      final correct = items[_random.nextInt(items.length)];
      
      // Question: "Which object is made of [Material]?"
      final otherMaterials = materials.keys.where((k) => k != m).toList();
      final distractors = <String>[];
      for (var i = 0; i < 3; i++) {
           final om = otherMaterials[_random.nextInt(otherMaterials.length)];
           final oItems = materials[om]!['items'] as List<String>;
           distractors.add(oItems[_random.nextInt(oItems.length)]);
      }
      
      final options = EnhancedQuestionGenerator.smartShuffle([correct, ...distractors], correct);
      
      return ScienceQuestion(
          id: 'sci_mat_$index',
          question: 'Which object is made of $m?',
          options: options,
          correctIndex: options.indexOf(correct),
          difficulty: difficulty,
          topic: 'Materials',
          explanation: '$correct is usually made of $m.'
      );
  }
  
  static ScienceQuestion _generateSeasonsQuestion(int difficulty, int index) {
       final seasons = [
           {'name': 'Summer', 'desc': 'hottest', 'clothes': 'T-shirt and shorts'},
           {'name': 'Winter', 'desc': 'coldest', 'clothes': 'Coat and scarf'},
           {'name': 'Autumn', 'desc': 'leaves falling', 'clothes': 'Jumper'},
           {'name': 'Spring', 'desc': 'flowers blooming', 'clothes': 'Light jacket'}
       ];
       
       final s = seasons[_random.nextInt(seasons.length)];
       final isDesc = _random.nextBool();
       
       String qText;
       String correct = s['name']!;
       List<String> options = ['Summer', 'Winter', 'Autumn', 'Spring']; // Always fixed options usually
       
        options = EnhancedQuestionGenerator.smartShuffle(options, correct);

       if (isDesc) {
           qText = "Which season is the ${s['desc']}?";
       } else {
           qText = "In which season would you wear: ${s['clothes']}?";
       }
       
       return ScienceQuestion(
          id: 'sci_season_$index',
          question: qText,
          options: options,
          correctIndex: options.indexOf(correct),
          difficulty: difficulty,
          topic: 'Earth and Space',
          explanation: '${s['name']} is the season of ${s['desc']}.'
       );
  }
}
