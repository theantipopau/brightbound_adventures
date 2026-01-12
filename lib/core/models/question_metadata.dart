import 'package:equatable/equatable.dart';

/// Enhanced question metadata model with ACARA v9 and NAPLAN alignment
/// 
/// This model captures all the metadata needed for curriculum mapping,
/// assessment design, and psychometric analysis.

enum CognitiveLevelBloom {
  remember,    // 1.0 - Recall facts and basic concepts
  understand,  // 2.0 - Explain ideas or concepts
  apply,       // 3.0 - Use information in new situations
  analyze,     // 4.0 - Draw connections among ideas
  evaluate,    // 5.0 - Justify a decision or choice
  create,      // 6.0 - Produce new or original work
}

enum NaplanStrand {
  // Literacy
  reading,
  writing,
  spelling,
  grammar,
  punctuation,
  vocabulary,
  
  // Numeracy
  number,
  fractions,
  measurement,
  geometry,
  statistics,
  patterns,
}

enum QuestionContext {
  // Literacy contexts
  recipes,
  stories,
  advertisements,
  socialMedia,
  instructions,
  emails,
  dialogue,
  newsArticles,
  poetry,
  informational,
  
  // Numeracy contexts
  shopping,
  sports,
  travel,
  cooking,
  money,
  time,
  games,
  building,
  weather,
  calendar,
}

/// ACARA Standard Reference
class AcaraStandard extends Equatable {
  /// Standard code e.g., "ACELA1440"
  final String code;
  
  /// Year level e.g., "Year 3", "Year 5"
  final String yearLevel;
  
  /// Short description
  final String description;
  
  /// Full content descriptor
  final String contentDescriptor;
  
  /// Achievement standard (what students should know/do)
  final String achievementStandard;
  
  /// Which literacy/numeracy domain: "Literacy" or "Numeracy"
  final String domain;
  
  /// Strand within domain: "Reading", "Number and Algebra", etc.
  final String strand;

  const AcaraStandard({
    required this.code,
    required this.yearLevel,
    required this.description,
    required this.contentDescriptor,
    required this.achievementStandard,
    required this.domain,
    required this.strand,
  });

  @override
  List<Object?> get props => [
    code,
    yearLevel,
    description,
    contentDescriptor,
    achievementStandard,
    domain,
    strand,
  ];
}

/// Enhanced Question Metadata
class QuestionMetadata {
  /// Unique question ID
  final String id;
  
  /// Skill ID this question targets
  final String skillId;
  
  /// Skill name (e.g., "Homophones")
  final String skillName;
  
  /// Question type: "multiple_choice", "drag_drop", "fill_blank", "ranking", "true_false", "short_answer"
  final String questionType;
  
  // ACARA ALIGNMENT
  /// Primary ACARA standard this addresses
  final AcaraStandard primaryStandard;
  
  /// Related ACARA standards (secondary alignments)
  final List<AcaraStandard> relatedStandards;
  
  // NAPLAN ALIGNMENT
  /// NAPLAN strand (Reading, Spelling, Numeracy, etc.)
  final NaplanStrand naplanStrand;
  
  /// NAPLAN test item format description
  final String naplanItemFormat;
  
  /// Can this question appear on NAPLAN? (true/false)
  final bool naplanEligible;
  
  /// Which NAPLAN year level? (Years 3, 5, 7, 9)
  final String naplanYearLevel;
  
  // COGNITIVE LEVEL (Bloom's Taxonomy)
  /// Bloom's cognitive level (1-6)
  final CognitiveLevelBloom cognitiveLevel;
  
  /// Cognitive level score (1.0 - 6.0) for finer granularity
  final double cognitiveScore;
  
  // DIFFICULTY & CONTEXT
  /// Difficulty rating (1.0 = easiest, 5.0 = hardest)
  final double difficulty;
  
  /// Real-world context/scenario
  final QuestionContext context;
  
  /// Detailed context description
  final String contextDescription;
  
  /// Learning objective in plain language
  final String learningObjective;
  
  // PSYCHOMETRIC DATA (mutable for tracking)
  /// How many times this question has been attempted
  int totalAttempts = 0;
  
  /// How many times answered correctly
  int correctResponses = 0;
  
  /// Calculated difficulty index: correctResponses / totalAttempts
  /// Ideal: 0.2 - 0.8
  double? difficultyIndex;
  
  /// Discrimination index: how well it separates high/low performers
  /// Ideal: > 0.3
  double? discriminationIndex;
  
  /// Average time spent on this question (milliseconds)
  int? averageTimeMs;
  
  /// Distribution of answer selections (for tracking distractor effectiveness)
  Map<int, int> optionDistribution = {};
  
  /// Common incorrect answers/misconceptions
  List<String> commonMisconceptions = [];
  
  // METADATA
  /// Question author/source
  final String author;
  
  /// When question was created
  final DateTime createdDate;
  
  /// When question was last updated
  DateTime? lastUpdatedDate;
  
  /// Accessibility notes
  final String? accessibilityNotes;
  
  /// Flag for review: true if meets problematic criteria
  bool? flaggedForReview;
  
  /// Reason for flag (if flagged)
  String? flagReason;

  QuestionMetadata({
    required this.id,
    required this.skillId,
    required this.skillName,
    required this.questionType,
    required this.primaryStandard,
    this.relatedStandards = const [],
    required this.naplanStrand,
    required this.naplanItemFormat,
    required this.naplanEligible,
    required this.naplanYearLevel,
    required this.cognitiveLevel,
    required this.cognitiveScore,
    required this.difficulty,
    required this.context,
    required this.contextDescription,
    required this.learningObjective,
    required this.author,
    required this.createdDate,
    this.lastUpdatedDate,
    this.accessibilityNotes,
  });

  /// Calculate and update difficulty index
  void calculateDifficultyIndex() {
    if (totalAttempts > 0) {
      difficultyIndex = correctResponses / totalAttempts;
    }
  }

  /// Flag question if it meets problematic criteria
  void evaluateForFlagging() {
    calculateDifficultyIndex();
    
    if (difficultyIndex != null) {
      if (difficultyIndex! < 0.2) {
        flaggedForReview = true;
        flagReason = "Difficulty too high (${(difficultyIndex! * 100).toStringAsFixed(1)}% correct)";
      } else if (difficultyIndex! > 0.8) {
        flaggedForReview = true;
        flagReason = "Difficulty too low (${(difficultyIndex! * 100).toStringAsFixed(1)}% correct)";
      }
    }
    
    if ((discriminationIndex ?? 0) < 0.2 && totalAttempts > 30) {
      flaggedForReview = true;
      flagReason = "Discrimination too low - doesn't distinguish ability levels";
    }
  }

  /// Track answer selection
  void recordAttempt(int selectedOption, bool isCorrect) {
    totalAttempts++;
    if (isCorrect) {
      correctResponses++;
    }
    
    optionDistribution[selectedOption] = (optionDistribution[selectedOption] ?? 0) + 1;
    calculateDifficultyIndex();
  }

  /// Get difficulty level description
  String getDifficultyLabel() {
    switch (difficulty) {
      case < 1.5:
        return "Very Easy";
      case < 2.5:
        return "Easy";
      case < 3.5:
        return "Medium";
      case < 4.5:
        return "Hard";
      default:
        return "Very Hard";
    }
  }

  /// Get cognitive level description
  String getCognitiveLevelLabel() {
    switch (cognitiveLevel) {
      case CognitiveLevelBloom.remember:
        return "Remember";
      case CognitiveLevelBloom.understand:
        return "Understand";
      case CognitiveLevelBloom.apply:
        return "Apply";
      case CognitiveLevelBloom.analyze:
        return "Analyze";
      case CognitiveLevelBloom.evaluate:
        return "Evaluate";
      case CognitiveLevelBloom.create:
        return "Create";
    }
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skillId': skillId,
      'skillName': skillName,
      'questionType': questionType,
      'primaryStandard': {
        'code': primaryStandard.code,
        'yearLevel': primaryStandard.yearLevel,
        'description': primaryStandard.description,
        'contentDescriptor': primaryStandard.contentDescriptor,
        'achievementStandard': primaryStandard.achievementStandard,
        'domain': primaryStandard.domain,
        'strand': primaryStandard.strand,
      },
      'naplanStrand': naplanStrand.toString(),
      'naplanItemFormat': naplanItemFormat,
      'naplanEligible': naplanEligible,
      'naplanYearLevel': naplanYearLevel,
      'cognitiveLevel': cognitiveLevel.toString(),
      'cognitiveScore': cognitiveScore,
      'difficulty': difficulty,
      'context': context.toString(),
      'contextDescription': contextDescription,
      'learningObjective': learningObjective,
      'totalAttempts': totalAttempts,
      'correctResponses': correctResponses,
      'difficultyIndex': difficultyIndex,
      'discriminationIndex': discriminationIndex,
      'averageTimeMs': averageTimeMs,
      'author': author,
      'createdDate': createdDate.toIso8601String(),
      'lastUpdatedDate': lastUpdatedDate?.toIso8601String(),
      'accessibilityNotes': accessibilityNotes,
      'flaggedForReview': flaggedForReview ?? false,
      'flagReason': flagReason,
    };
  }
}

/// Question Quality Report
class QuestionQualityReport extends Equatable {
  final QuestionMetadata metadata;
  final List<String> issues;
  final List<String> strengths;
  final String overallRating; // "Excellent", "Good", "Fair", "Poor"
  final List<String> suggestedImprovements;

  const QuestionQualityReport({
    required this.metadata,
    required this.issues,
    required this.strengths,
    required this.overallRating,
    required this.suggestedImprovements,
  });

  @override
  List<Object?> get props => [metadata, issues, strengths, overallRating, suggestedImprovements];

  /// Generate quality report for a question
  static QuestionQualityReport generate(QuestionMetadata metadata) {
    final issues = <String>[];
    final strengths = <String>[];
    var rating = "Excellent";

    // Check difficulty
    if (metadata.difficultyIndex != null) {
      if (metadata.difficultyIndex! < 0.2) {
        issues.add("Too difficult (only ${(metadata.difficultyIndex! * 100).toStringAsFixed(1)}% correct)");
        rating = "Poor";
      } else if (metadata.difficultyIndex! > 0.8) {
        issues.add("Too easy (${(metadata.difficultyIndex! * 100).toStringAsFixed(1)}% correct)");
        rating = "Fair";
      } else {
        strengths.add("Difficulty well-calibrated");
      }
    }

    // Check discrimination
    if (metadata.discriminationIndex != null) {
      if (metadata.discriminationIndex! < 0.2) {
        issues.add("Low discrimination - doesn't differentiate student ability");
        if (rating == "Excellent") rating = "Fair";
      } else if (metadata.discriminationIndex! > 0.3) {
        strengths.add("Good discrimination between high/low performers");
      }
    }

    // Check NAPLAN alignment
    if (metadata.naplanEligible) {
      strengths.add("NAPLAN-aligned and testable");
    }

    // Check cognitive level
    if (metadata.cognitiveLevel.index >= 3) {
      strengths.add("Higher-order thinking (${metadata.getCognitiveLevelLabel()})");
    } else if (metadata.cognitiveLevel.index < 2) {
      issues.add("Lower-order thinking only (${metadata.getCognitiveLevelLabel()})");
    }

    final suggestions = <String>[];
    if (issues.isNotEmpty) {
      if (issues.any((i) => i.contains("Too difficult"))) {
        suggestions.add("Simplify question wording or reduce number of constraints");
      }
      if (issues.any((i) => i.contains("Too easy"))) {
        suggestions.add("Add complexity or introduce common misconceptions as distractors");
      }
      if (issues.any((i) => i.contains("Low discrimination"))) {
        suggestions.add("Review distractors - ensure they target common errors");
      }
    }

    return QuestionQualityReport(
      metadata: metadata,
      issues: issues,
      strengths: strengths,
      overallRating: rating,
      suggestedImprovements: suggestions,
    );
  }
}
