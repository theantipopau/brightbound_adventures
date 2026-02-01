import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/naplan/naplan_question_set.dart';
import 'package:brightbound_adventures/core/services/question_loader_service.dart';
import 'package:brightbound_adventures/features/science/widgets/science_game.dart';

class SciencePracticeScreen extends StatefulWidget {
  final String skillId;

  const SciencePracticeScreen({super.key, required this.skillId});

  @override
  State<SciencePracticeScreen> createState() => _SciencePracticeScreenState();
}

class _SciencePracticeScreenState extends State<SciencePracticeScreen> {
  final QuestionLoaderService _loader = QuestionLoaderService();
  Future<NaplanQuestionSet>? _questionsFuture;

  @override
  void initState() {
    super.initState();
    // In a real app, we would load based on skillId
    // For now, we load our demo file
    _questionsFuture = _loader.loadQuestions('science_explorers_questions.json');
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
            onComplete: () {
               Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
