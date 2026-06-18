class QuestSessionSummary {
  final String id;
  final String zoneId;
  final String skillId;
  final String skillName;
  final String mode;
  final DateTime startedAt;
  final DateTime endedAt;
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final int hintsUsed;
  final int difficulty;
  final bool forced;
  final List<String> questionIds;
  final int freshQuestionCount;
  final int repeatedQuestionCount;

  const QuestSessionSummary({
    required this.id,
    required this.zoneId,
    required this.skillId,
    required this.skillName,
    required this.mode,
    required this.startedAt,
    required this.endedAt,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.hintsUsed,
    required this.difficulty,
    required this.forced,
    required this.questionIds,
    this.freshQuestionCount = 0,
    this.repeatedQuestionCount = 0,
  });

  double get accuracy =>
      totalQuestions <= 0 ? 0.0 : correctAnswers / totalQuestions;

  int get durationSeconds => endedAt.difference(startedAt).inSeconds;

  bool get isPerfect => totalQuestions > 0 && correctAnswers == totalQuestions;

  bool get needsReview => accuracy < 0.7 || forced;

  int get uniqueQuestionCount => questionIds.toSet().length;

  double get noveltyPercentage =>
      totalQuestions <= 0 ? 0.0 : freshQuestionCount / totalQuestions * 100;

  Map<String, dynamic> toJson() => {
        'id': id,
        'zoneId': zoneId,
        'skillId': skillId,
        'skillName': skillName,
        'mode': mode,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'score': score,
        'hintsUsed': hintsUsed,
        'difficulty': difficulty,
        'forced': forced,
        'questionIds': questionIds,
        'freshQuestionCount': freshQuestionCount,
        'repeatedQuestionCount': repeatedQuestionCount,
      };

  factory QuestSessionSummary.fromJson(Map<String, dynamic> json) {
    return QuestSessionSummary(
      id: json['id'] as String,
      zoneId: json['zoneId'] as String? ?? 'unknown',
      skillId: json['skillId'] as String? ?? 'unknown',
      skillName: json['skillName'] as String? ?? 'Practice',
      mode: json['mode'] as String? ?? 'practice',
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      hintsUsed: (json['hintsUsed'] as num?)?.toInt() ?? 0,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
      forced: json['forced'] as bool? ?? false,
      questionIds:
          (json['questionIds'] as List? ?? const []).map((e) => '$e').toList(),
      freshQuestionCount: (json['freshQuestionCount'] as num?)?.toInt() ?? 0,
      repeatedQuestionCount:
          (json['repeatedQuestionCount'] as num?)?.toInt() ?? 0,
    );
  }
}
