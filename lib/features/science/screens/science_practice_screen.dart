import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/models/naplan/naplan_question_set.dart';
import 'package:brightbound_adventures/core/services/question_loader_service.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/widgets/streak_milestone_modal.dart';
import 'package:brightbound_adventures/features/science/widgets/science_game.dart';
import 'package:brightbound_adventures/core/utils/science_quest_generator.dart';

class SciencePracticeScreen extends StatefulWidget {
  final String skillId;
  final String? zoneId;
  final String? zoneName;

  const SciencePracticeScreen({
    super.key,
    required this.skillId,
    this.zoneId,
    this.zoneName,
  });

  @override
  State<SciencePracticeScreen> createState() => _SciencePracticeScreenState();
}

class _SciencePracticeScreenState extends State<SciencePracticeScreen> {
  final QuestionLoaderService _loader = QuestionLoaderService();
  Future<NaplanQuestionSet>? _questionsFuture;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadAndGenerateQuestions();
  }

  Future<NaplanQuestionSet> _loadAndGenerateQuestions() async {
    // Get adaptive difficulty level
    final adaptiveDifficulty = context.read<AdaptiveDifficultyService>();
    final difficulty = adaptiveDifficulty.getDifficultyForSkill(widget.skillId);
    
    NaplanQuestionSet loadedSet;
    try {
      // Try loading the static JSON file
      loadedSet = await _loader.loadQuestions('science_explorers_questions.json');
    } catch (e) {
      // If fails, create a dummy empty set
      loadedSet = NaplanQuestionSet(
        meta: Meta(subject: 'Science', yearLevel: 1, source: 'Generated', version: '1.0'),
        questions: [],
      );
    }

    // Generate 10 procedural questions to expand the library
    final procedural = ScienceQuestGenerator.generate(theme: 'mixed', difficulty: difficulty, count: 10);
    
    // Map ScienceQuestion to NaplanQuestionSet's Question model
    final converted = procedural.map((pq) => Question(
       id: pq.id,
       question: pq.question,
       options: pq.options,
       correctIndex: pq.correctIndex,
       difficulty: pq.difficulty,
       topic: pq.topic,
       hint: pq.hint ?? pq.explanation // Use explanation as hint fallback
    )).toList();

    // Combine loaded and generated questions
    final combinedQuestions = [...loadedSet.questions, ...converted];
    combinedQuestions.shuffle();

    return NaplanQuestionSet(
       meta: loadedSet.meta,
       questions: combinedQuestions
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<NaplanQuestionSet>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             // If completely failed, try to just retry or show error
            return Center(
              child: Text(
                'Error loading activity: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.questions.isEmpty) {
            return const Center(child: Text('No questions available.'));
          }

          return ScienceGame(
            questions: snapshot.data!.questions,
            onComplete: (accuracy, correct, total) {
               _checkStreak(context);
               Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  Future<void> _checkStreak(BuildContext ctx) async {
    try {
      final streakService = ctx.read<StreakService>();
      final isNewMilestone = await streakService.recordPlay();
      if (isNewMilestone && ctx.mounted) {
        showStreakMilestoneModal(
          ctx,
          streakDays: streakService.currentStreak,
          bonusStars: streakService.streakBonus,
        );
      }
    } catch (_) {}
  }
}