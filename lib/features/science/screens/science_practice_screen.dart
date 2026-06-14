import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/models/naplan/naplan_question_set.dart';
import 'package:brightbound_adventures/core/services/question_loader_service.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/widgets/streak_milestone_modal.dart';
import 'package:brightbound_adventures/features/science/widgets/science_game.dart';
import 'package:brightbound_adventures/features/science/widgets/science_results_screen.dart';
import 'package:brightbound_adventures/core/utils/science_quest_generator.dart';

class SciencePracticeScreen extends StatefulWidget {
  final String skillId;
  final String skillName;
  final String? zoneId;
  final String? zoneName;

  const SciencePracticeScreen({
    super.key,
    required this.skillId,
    required this.skillName,
    this.zoneId,
    this.zoneName,
  });

  @override
  State<SciencePracticeScreen> createState() => _SciencePracticeScreenState();
}

class _SciencePracticeScreenState extends State<SciencePracticeScreen> {
  static const Color _scienceTheme = Color(0xFF4DB6AC);

  final QuestionLoaderService _loader = QuestionLoaderService();
  Future<NaplanQuestionSet>? _questionsFuture;
  bool _showResults = false;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  double _accuracy = 0;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadAndGenerateQuestions();
    // Pre-populate AI cache for next session — fire and forget.
    AiQuestionService.instance.prefetch(
      zone: 'science_explorers',
      skill: widget.skillId,
      difficulty: 3,
      fetchCount: 10,
      ageGroup: '6-12',
    );
  }

  Future<NaplanQuestionSet> _loadAndGenerateQuestions() async {
    // Get adaptive difficulty level
    final adaptiveDifficulty = context.read<AdaptiveDifficultyService>();
    final difficulty = adaptiveDifficulty.getDifficultyForSkill(widget.skillId);

    NaplanQuestionSet loadedSet;
    try {
      // Try loading the static JSON file
      loadedSet =
          await _loader.loadQuestions('science_explorers_questions.json');
    } catch (e) {
      // If fails, create a dummy empty set
      loadedSet = NaplanQuestionSet(
        meta: Meta(
            subject: 'Science',
            yearLevel: 1,
            source: 'Generated',
            version: '1.0'),
        questions: [],
      );
    }

    // Generate 10 procedural questions to expand the library
    final procedural = ScienceQuestGenerator.generate(
        theme: 'mixed', difficulty: difficulty, count: 10);

    // Map ScienceQuestion to NaplanQuestionSet's Question model
    final converted = procedural
        .map((pq) => Question(
            id: pq.id,
            question: pq.question,
            options: pq.options,
            correctIndex: pq.correctIndex,
            difficulty: pq.difficulty,
            topic: pq.topic,
            hint: pq.hint ?? pq.explanation // Use explanation as hint fallback
            ))
        .toList();

    // Combine loaded and generated questions
    final combinedQuestions = [...loadedSet.questions, ...converted];
    combinedQuestions.shuffle();

    return NaplanQuestionSet(
        meta: loadedSet.meta, questions: combinedQuestions);
  }

  void _onGameComplete(double accuracy, int correct, int total) {
    setState(() {
      _showResults = true;
      _accuracy = accuracy;
      _correctAnswers = correct;
      _totalQuestions = total;
    });
    _checkStreak(context);
  }

  void _playAgain() {
    setState(() {
      _showResults = false;
      _correctAnswers = 0;
      _totalQuestions = 0;
      _accuracy = 0;
      _questionsFuture = _loadAndGenerateQuestions();
    });
  }

  void _exitToZone() {
    Navigator.of(context).pop();
  }

  void _retryLoading() {
    setState(() {
      _questionsFuture = _loadAndGenerateQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return ScienceResultsScreen(
        skillName: widget.skillName,
        skillId: widget.skillId,
        correctAnswers: _correctAnswers,
        totalQuestions: _totalQuestions,
        accuracy: _accuracy,
        themeColor: _scienceTheme,
        onPlayAgain: _playAgain,
        onExit: _exitToZone,
        zoneId: widget.zoneId,
        zoneName: widget.zoneName,
      );
    }

    return Scaffold(
      body: FutureBuilder<NaplanQuestionSet>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildStatusScaffold(
              icon: Icons.science_rounded,
              title: 'Preparing your lab',
              message: 'Mixing science clues for ${widget.skillName}...',
              showProgress: true,
            );
          }

          if (snapshot.hasError) {
            return _buildStatusScaffold(
              icon: Icons.error_outline_rounded,
              title: 'Lab setup paused',
              message:
                  'The activity could not load yet. Try again when you are ready.',
              actionLabel: 'Try Again',
              onAction: _retryLoading,
            );
          }

          if (!snapshot.hasData || snapshot.data!.questions.isEmpty) {
            return _buildStatusScaffold(
              icon: Icons.inventory_2_outlined,
              title: 'No experiments ready',
              message:
                  'We could not find questions for ${widget.skillName} right now.',
              actionLabel: 'Back to Zone',
              onAction: _exitToZone,
            );
          }

          return ScienceGame(
            questions: snapshot.data!.questions,
            skillName: widget.skillName,
            themeColor: _scienceTheme,
            onComplete: _onGameComplete,
            onCancel: _exitToZone,
          );
        },
      ),
    );
  }

  Widget _buildStatusScaffold({
    required IconData icon,
    required String title,
    required String message,
    bool showProgress = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _scienceTheme.withValues(alpha: 0.18),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 440),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _scienceTheme.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: _scienceTheme.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: _scienceTheme.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: _scienceTheme, size: 42),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF173F3B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.blueGrey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showProgress) ...[
                const SizedBox(height: 22),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    backgroundColor: _scienceTheme.withValues(alpha: 0.12),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_scienceTheme),
                  ),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAction,
                    icon: Icon(actionLabel == 'Back to Zone'
                        ? Icons.arrow_back_rounded
                        : Icons.refresh_rounded),
                    label: Text(actionLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _scienceTheme,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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
