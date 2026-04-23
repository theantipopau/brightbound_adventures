import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents a specific instance of a question asked to a user
/// Used for tracking question freshness and preventing repetition
class QuestionInstance extends Equatable {
  /// Unique ID for this question instance
  final String instanceId;
  
  /// ID of the skill this question tests
  final String skillId;
  
  /// Hash of question text (used to prevent exact repetitions)
  final String questionHash;
  
  /// When this question was shown to the user
  final DateTime askedAt;
  
  /// User's answer (or null if skipped)
  final dynamic userAnswer;
  
  /// Correct answer
  final dynamic correctAnswer;
  
  /// Whether the user got it correct
  final bool isCorrect;
  
  /// Time spent on question (milliseconds)
  final int timeSpentMs;
  
  /// Confidence level of answer (1-5 if available)
  final int? confidenceLevel;
  
  /// Context of question (e.g., "shopping", "sports", "cooking")
  final String? context;
  
  /// Bloom's taxonomy level
  final String? bloomLevel;

  const QuestionInstance({
    required this.instanceId,
    required this.skillId,
    required this.questionHash,
    required this.askedAt,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.timeSpentMs,
    this.confidenceLevel,
    this.context,
    this.bloomLevel,
  });

  /// Create a new instance with generated ID
  factory QuestionInstance.create({
    required String skillId,
    required String questionHash,
    required dynamic userAnswer,
    required dynamic correctAnswer,
    required int timeSpentMs,
    int? confidenceLevel,
    String? context,
    String? bloomLevel,
  }) {
    return QuestionInstance(
      instanceId: const Uuid().v4(),
      skillId: skillId,
      questionHash: questionHash,
      askedAt: DateTime.now(),
      userAnswer: userAnswer,
      correctAnswer: correctAnswer,
      isCorrect: userAnswer == correctAnswer,
      timeSpentMs: timeSpentMs,
      confidenceLevel: confidenceLevel,
      context: context,
      bloomLevel: bloomLevel,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'instanceId': instanceId,
    'skillId': skillId,
    'questionHash': questionHash,
    'askedAt': askedAt.toIso8601String(),
    'userAnswer': userAnswer.toString(),
    'correctAnswer': correctAnswer.toString(),
    'isCorrect': isCorrect,
    'timeSpentMs': timeSpentMs,
    'confidenceLevel': confidenceLevel,
    'context': context,
    'bloomLevel': bloomLevel,
  };

  /// Create from JSON
  factory QuestionInstance.fromJson(Map<String, dynamic> json) {
    return QuestionInstance(
      instanceId: json['instanceId'] as String,
      skillId: json['skillId'] as String,
      questionHash: json['questionHash'] as String,
      askedAt: DateTime.parse(json['askedAt'] as String),
      userAnswer: json['userAnswer'],
      correctAnswer: json['correctAnswer'],
      isCorrect: json['isCorrect'] as bool,
      timeSpentMs: json['timeSpentMs'] as int,
      confidenceLevel: json['confidenceLevel'] as int?,
      context: json['context'] as String?,
      bloomLevel: json['bloomLevel'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    instanceId,
    skillId,
    questionHash,
    askedAt,
    userAnswer,
    correctAnswer,
    isCorrect,
    timeSpentMs,
    confidenceLevel,
    context,
    bloomLevel,
  ];
}

/// Statistics about a specific question hash (used to avoid repetition)
class QuestionStatistics extends Equatable {
  /// Hash of the question
  final String questionHash;
  
  /// How many times this exact question has been shown
  final int timesShown;
  
  /// How many times answered correctly
  final int correctCount;
  
  /// Average time spent (milliseconds)
  final int avgTimeMs;
  
  /// When this question was last shown
  final DateTime? lastShownAt;
  
  /// Days since last shown (null if never shown)
  int? get daysSinceLastShown {
    if (lastShownAt == null) return null;
    return DateTime.now().difference(lastShownAt!).inDays;
  }

  /// Success rate (0.0 to 1.0)
  double get successRate {
    if (timesShown == 0) return 0.0;
    return correctCount / timesShown;
  }

  const QuestionStatistics({
    required this.questionHash,
    required this.timesShown,
    required this.correctCount,
    required this.avgTimeMs,
    this.lastShownAt,
  });

  /// Record a new attempt
  QuestionStatistics recordAttempt({
    required bool isCorrect,
    required int timeSpentMs,
  }) {
    return QuestionStatistics(
      questionHash: questionHash,
      timesShown: timesShown + 1,
      correctCount: isCorrect ? correctCount + 1 : correctCount,
      avgTimeMs: ((avgTimeMs * timesShown) + timeSpentMs) ~/ (timesShown + 1),
      lastShownAt: DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'questionHash': questionHash,
    'timesShown': timesShown,
    'correctCount': correctCount,
    'avgTimeMs': avgTimeMs,
    'lastShownAt': lastShownAt?.toIso8601String(),
  };

  /// Create from JSON
  factory QuestionStatistics.fromJson(Map<String, dynamic> json) {
    return QuestionStatistics(
      questionHash: json['questionHash'] as String,
      timesShown: json['timesShown'] as int,
      correctCount: json['correctCount'] as int,
      avgTimeMs: json['avgTimeMs'] as int,
      lastShownAt: json['lastShownAt'] != null
          ? DateTime.parse(json['lastShownAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    questionHash,
    timesShown,
    correctCount,
    avgTimeMs,
    lastShownAt,
  ];
}
