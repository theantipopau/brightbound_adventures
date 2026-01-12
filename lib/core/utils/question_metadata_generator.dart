
/// Helper class for generating question metadata templates
class QuestionMetadataGenerator {
  /// Map of skill IDs to their ACARA standards (from acara_curriculum_mapping.json)
  static final Map<String, AcaraStandardInfo> skillToStandard = {
    // Literacy skills
    'skill_homophones': AcaraStandardInfo(
      code: 'ACELA1440',
      yearLevel: 'Year 3',
      domain: 'Literacy',
      strand: 'Phonics and word knowledge',
      naplanStrand: 'Spelling',
    ),
    'skill_apostrophes': AcaraStandardInfo(
      code: 'ACELA1452',
      yearLevel: 'Year 4',
      domain: 'Literacy',
      strand: 'Grammar, spelling and punctuation',
      naplanStrand: 'Punctuation',
    ),
    'skill_compound_words': AcaraStandardInfo(
      code: 'ACELA1436',
      yearLevel: 'Year 2',
      domain: 'Literacy',
      strand: 'Phonics and word knowledge',
      naplanStrand: 'Vocabulary',
    ),
    'skill_synonyms': AcaraStandardInfo(
      code: 'ACELA1446',
      yearLevel: 'Year 3',
      domain: 'Literacy',
      strand: 'Vocabulary',
      naplanStrand: 'Vocabulary',
    ),
    'skill_comprehension': AcaraStandardInfo(
      code: 'ACELY1688',
      yearLevel: 'Year 3',
      domain: 'Literacy',
      strand: 'Reading',
      naplanStrand: 'Reading',
    ),
    'skill_verb_tenses': AcaraStandardInfo(
      code: 'ACELA1450',
      yearLevel: 'Year 3',
      domain: 'Literacy',
      strand: 'Grammar and punctuation',
      naplanStrand: 'Grammar',
    ),

    // Numeracy skills
    'skill_place_value': AcaraStandardInfo(
      code: 'ACMNA053',
      yearLevel: 'Year 3',
      domain: 'Numeracy',
      strand: 'Number and Algebra',
      naplanStrand: 'Number',
    ),
    'skill_fractions': AcaraStandardInfo(
      code: 'ACMNA072',
      yearLevel: 'Year 3',
      domain: 'Numeracy',
      strand: 'Number and Algebra',
      naplanStrand: 'Fractions',
    ),
    'skill_addition': AcaraStandardInfo(
      code: 'ACMNA054',
      yearLevel: 'Year 3',
      domain: 'Numeracy',
      strand: 'Number and Algebra',
      naplanStrand: 'Number',
    ),
    'skill_subtraction': AcaraStandardInfo(
      code: 'ACMNA054',
      yearLevel: 'Year 3',
      domain: 'Numeracy',
      strand: 'Number and Algebra',
      naplanStrand: 'Number',
    ),
    'skill_multiplication': AcaraStandardInfo(
      code: 'ACMNA063',
      yearLevel: 'Year 3',
      domain: 'Numeracy',
      strand: 'Number and Algebra',
      naplanStrand: 'Number',
    ),
    'skill_division': AcaraStandardInfo(
      code: 'ACMNA063',
      yearLevel: 'Year 3',
      domain: 'Numeracy',
      strand: 'Number and Algebra',
      naplanStrand: 'Number',
    ),
    'skill_patterns': AcaraStandardInfo(
      code: 'ACMNA064',
      yearLevel: 'Year 3',
      domain: 'Numeracy',
      strand: 'Number and Algebra',
      naplanStrand: 'Patterns',
    ),
  };

  /// Map skill IDs to suggested cognitive levels (as strings to avoid enum issues)
  static final Map<String, String> skillToCognitiveLevelStr = {
    'skill_homophones': 'remember',
    'skill_apostrophes': 'apply',
    'skill_compound_words': 'understand',
    'skill_synonyms': 'understand',
    'skill_comprehension': 'analyze',
    'skill_verb_tenses': 'apply',
    'skill_place_value': 'remember',
    'skill_fractions': 'understand',
    'skill_addition': 'apply',
    'skill_subtraction': 'apply',
    'skill_multiplication': 'apply',
    'skill_division': 'apply',
    'skill_patterns': 'understand',
  };

  /// Map question types to default cognitive levels
  static final Map<String, String> questionTypeToCognitiveLevelStr = {
    'recall': 'remember',
    'definition': 'remember',
    'identification': 'understand',
    'application': 'apply',
    'comparison': 'analyze',
    'analysis': 'analyze',
    'evaluation': 'evaluate',
    'creation': 'create',
  };

  /// Generate metadata template for a question
  static AcaraStandardInfo? getAcaraStandardForSkill(String skillId) {
    return skillToStandard[skillId];
  }

  /// Get suggested cognitive level for a skill
  static String getSuggestedCognitiveLevelStr(String skillId) {
    return skillToCognitiveLevelStr[skillId] ?? 'understand';
  }

  /// Estimate difficulty from question complexity keywords
  static double estimateDifficulty(
    String questionText,
    String cognitiveLevelStr,
  ) {
    // Map string to numeric value
    final cognitiveValue = {
      'remember': 1.0,
      'understand': 2.0,
      'apply': 3.0,
      'analyze': 4.0,
      'evaluate': 5.0,
      'create': 6.0,
    }[cognitiveLevelStr] ?? 2.0;

    // Base difficulty from cognitive level
    double difficulty = cognitiveValue / 6.0;

    // Adjust based on complexity keywords
    final lowerText = questionText.toLowerCase();

    // Complexity indicators
    if (lowerText.contains('multiple')  || 
        lowerText.contains('choose') ||
        lowerText.contains('which') ||
        lowerText.contains('select')) {
      difficulty += 0.1;
    }

    if (lowerText.contains('compare') ||
        lowerText.contains('contrast') ||
        lowerText.contains('analyze') ||
        lowerText.contains('explain why')) {
      difficulty += 0.3;
    }

    if (lowerText.contains('create') ||
        lowerText.contains('design') ||
        lowerText.contains('write your own')) {
      difficulty += 0.4;
    }

    // Number of options factor
    if (lowerText.length > 200) {
      difficulty += 0.2; // Long questions are harder
    }

    return (difficulty * 5).clamp(1.0, 5.0);
  }

  /// Extract context from question text
  static String? extractContext(String questionText) {
    final lowerText = questionText.toLowerCase();

    // Shopping context
    if (lowerText.contains('shop') ||
        lowerText.contains('price') ||
        lowerText.contains('buy') ||
        lowerText.contains('cost') ||
        lowerText.contains('dollar') ||
        lowerText.contains('money')) {
      return 'shopping';
    }

    // Cooking context
    if (lowerText.contains('recipe') ||
        lowerText.contains('cook') ||
        lowerText.contains('bake') ||
        lowerText.contains('ingredient') ||
        lowerText.contains('cup') ||
        lowerText.contains('teaspoon')) {
      return 'cooking';
    }

    // Sports context
    if (lowerText.contains('sport') ||
        lowerText.contains('game') ||
        lowerText.contains('team') ||
        lowerText.contains('score') ||
        lowerText.contains('win') ||
        lowerText.contains('player')) {
      return 'sports';
    }

    // Story context
    if (lowerText.contains('story') ||
        lowerText.contains('character') ||
        lowerText.contains('plot') ||
        lowerText.contains('read') ||
        lowerText.contains('book')) {
      return 'stories';
    }

    // Social media context
    if (lowerText.contains('post') ||
        lowerText.contains('tweet') ||
        lowerText.contains('social') ||
        lowerText.contains('message')) {
      return 'socialMedia';
    }

    // Email context
    if (lowerText.contains('email') ||
        lowerText.contains('letter')) {
      return 'emails';
    }

    // Time context
    if (lowerText.contains('time') ||
        lowerText.contains('clock') ||
        lowerText.contains('day') ||
        lowerText.contains('week')) {
      return 'time';
    }

    return null;
  }

  /// Generate a complete metadata object for a question
  static Map<String, dynamic> generateMetadataJson({
    required String questionId,
    required String skillId,
    required String questionText,
    required int difficulty,
    String? contextDescription,
  }) {
    final standardInfo = skillToStandard[skillId];
    final suggestedCognitiveLevelStr = getSuggestedCognitiveLevelStr(skillId);
    estimateDifficulty(questionText, suggestedCognitiveLevelStr); // Validate complexity
    final detectedContext = extractContext(questionText);

    return {
      'id': questionId,
      'skillId': skillId,
      'primaryStandard': standardInfo?.toJson(),
      'naplanStrand': standardInfo?.naplanStrand,
      'cognitiveLevel': suggestedCognitiveLevelStr,
      'difficulty': (difficulty / 5.0 * 5.0).clamp(1.0, 5.0),
      'context': detectedContext ?? 'other',
      'contextDescription': contextDescription ?? 'General question',
      'totalAttempts': 0,
      'correctResponses': 0,
      'difficultyIndex': null,
      'discriminationIndex': null,
      'averageTimeMs': 0,
    };
  }

  /// Validate that a question has complete metadata
  static Map<String, dynamic> validateQuestion({
    required String questionId,
    required String skillId,
    required String questionText,
    Map<String, dynamic>? metadata,
  }) {
    final issues = <String>[];
    final suggestions = <String>[];

    // Check skill mapping
    if (!skillToStandard.containsKey(skillId)) {
      issues.add('Skill "$skillId" not found in ACARA mapping');
      suggestions.add('Add skill to skillToStandard map');
    }

    // Check if metadata exists
    if (metadata == null) {
      issues.add('No metadata attached to question');
      suggestions.add('Generate metadata using generateMetadataJson()');
    } else {
      // Validate metadata fields
      final requiredFields = [
        'primaryStandard',
        'naplanStrand',
        'cognitiveLevel',
        'difficulty',
        'context'
      ];

      for (final field in requiredFields) {
        if (!metadata.containsKey(field) || metadata[field] == null) {
          issues.add('Missing required field: $field');
        }
      }

      // Validate difficulty range
      final diff = metadata['difficulty'];
      if (diff != null && (diff < 1.0 || diff > 5.0)) {
        issues.add('Difficulty out of range: $diff (should be 1.0-5.0)');
      }
    }

    return {
      'questionId': questionId,
      'skillId': skillId,
      'isValid': issues.isEmpty,
      'issues': issues,
      'suggestions': suggestions,
    };
  }

  /// Generate audit report for a batch of questions
  static Map<String, dynamic> generateAuditReport(
    List<Map<String, dynamic>> questions,
  ) {
    int totalQuestions = questions.length;
    int questionsWithMetadata = 0;
    int questionsValid = 0;
    final Map<String, int> skillCounts = {};
    final Map<String, int> cognitiveLevelCounts = {};
    final issuesList = <Map<String, dynamic>>[];

    for (final q in questions) {
      final skillId = q['skillId'] as String;
      skillCounts[skillId] = (skillCounts[skillId] ?? 0) + 1;

      if (q['metadata'] != null) {
        questionsWithMetadata++;
        final validation = validateQuestion(
          questionId: q['id'] as String,
          skillId: skillId,
          questionText: q['question'] as String,
          metadata: q['metadata'] as Map<String, dynamic>?,
        );

        if (validation['isValid'] == true) {
          questionsValid++;
        } else {
          issuesList.add(validation);
        }
        final cogLevel = q['metadata']['cognitiveLevel'] as String?;
        if (cogLevel != null) {
          cognitiveLevelCounts[cogLevel] =
              (cognitiveLevelCounts[cogLevel] ?? 0) + 1;
        }
      } else {
        issuesList.add({
          'questionId': q['id'],
          'skillId': skillId,
          'isValid': false,
          'issues': ['No metadata'],
        });
      }
    }

    return {
      'totalQuestions': totalQuestions,
      'questionsWithMetadata': questionsWithMetadata,
      'metadataCompleteness': (questionsWithMetadata / totalQuestions * 100).toStringAsFixed(1),
      'questionsValid': questionsValid,
      'validityRate': (questionsValid / totalQuestions * 100).toStringAsFixed(1),
      'skillDistribution': skillCounts,
      'cognitiveLevelDistribution': cognitiveLevelCounts,
      'issues': issuesList,
    };
  }
}

/// Information about an ACARA standard
class AcaraStandardInfo {
  final String code;
  final String yearLevel;
  final String domain;
  final String strand;
  final String naplanStrand;

  const AcaraStandardInfo({
    required this.code,
    required this.yearLevel,
    required this.domain,
    required this.strand,
    required this.naplanStrand,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'yearLevel': yearLevel,
      'domain': domain,
      'strand': strand,
      'naplanStrand': naplanStrand,
    };
  }

  @override
  String toString() {
    return '$code ($yearLevel) - $domain: $strand';
  }
}
