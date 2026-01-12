import 'dart:convert';
import '../utils/question_metadata_generator.dart';

/// Question Audit Service for Phase 7.2
/// 
/// This service orchestrates the auditing of questions through the metadata generator,
/// creating comprehensive quality reports for each question bank and identifying
/// patterns, gaps, and quality issues.

class QuestionAuditService {
  /// Audit a single question and generate its metadata
  static Map<String, dynamic> auditQuestion({
    required String questionId,
    required String skillId,
    required String questionText,
    required int difficulty,
    String? context,
  }) {
    // Generate metadata for the question
    final metadata = QuestionMetadataGenerator.generateMetadataJson(
      questionId: questionId,
      skillId: skillId,
      questionText: questionText,
      difficulty: difficulty,
      contextDescription: context,
    );

    return {
      'auditTimestamp': DateTime.now().toIso8601String(),
      'skillId': skillId,
      'metadata': metadata,
      'validationStatus': _validateMetadata(metadata),
      'qualityScore': _calculateQualityScore(metadata),
      'flags': _identifyFlags(metadata),
    };
  }

  /// Validate metadata structure
  static Map<String, dynamic> _validateMetadata(Map<String, dynamic> metadata) {
    final issues = <String>[];

    if (!metadata.containsKey('primaryStandard') || metadata['primaryStandard'] == null) {
      issues.add('missing_primary_standard');
    }

    if (!metadata.containsKey('acaraCodes') || (metadata['acaraCodes'] as List).isEmpty) {
      issues.add('missing_acara_codes');
    }

    if (!metadata.containsKey('cognitive_level') || metadata['cognitive_level'] == null) {
      issues.add('missing_cognitive_level');
    }

    if (!metadata.containsKey('naplanStrand') || metadata['naplanStrand'] == null) {
      issues.add('missing_naplan_strand');
    }

    if (!metadata.containsKey('context') || metadata['context'] == null) {
      issues.add('missing_context');
    }

    if (!metadata.containsKey('estimated_difficulty') || metadata['estimated_difficulty'] == null) {
      issues.add('missing_estimated_difficulty');
    }

    return {
      'isValid': issues.isEmpty,
      'issueCount': issues.length,
      'issues': issues,
      'completeness': _calculateCompleteness(metadata),
    };
  }

  /// Calculate metadata completeness percentage
  static double _calculateCompleteness(Map<String, dynamic> metadata) {
    final requiredFields = [
      'primaryStandard',
      'acaraCodes',
      'cognitive_level',
      'naplanStrand',
      'context',
      'estimated_difficulty',
    ];

    final presentFields = requiredFields.where(
      (field) => metadata.containsKey(field) && metadata[field] != null,
    ).length;

    return (presentFields / requiredFields.length) * 100;
  }

  /// Calculate quality score (0-100)
  static double _calculateQualityScore(Map<String, dynamic> metadata) {
    double score = 100.0;

    // Deduct for missing critical fields
    if (metadata['primaryStandard'] == null) score -= 15;
    if ((metadata['acaraCodes'] as List?)?.isEmpty ?? true) score -= 10;
    if (metadata['cognitive_level'] == null) score -= 10;
    if (metadata['naplanStrand'] == null) score -= 10;
    if (metadata['context'] == null) score -= 10;

    // Deduct for difficulty issues
    final difficulty = metadata['estimated_difficulty'] as double?;
    if (difficulty != null) {
      if (difficulty < 0.2 || difficulty > 0.8) {
        score -= 15; // Flagged difficulty
      }
    }

    return score.clamp(0, 100);
  }

  /// Identify quality flags
  static List<String> _identifyFlags(Map<String, dynamic> metadata) {
    final flags = <String>[];

    final difficulty = metadata['estimated_difficulty'] as double?;
    if (difficulty != null) {
      if (difficulty < 0.2) {
        flags.add('too_easy');
      } else if (difficulty > 0.8) {
        flags.add('too_hard');
      }
    }

    if (metadata['acaraCodes'] == null || (metadata['acaraCodes'] as List).isEmpty) {
      flags.add('unaligned_acara');
    }

    if (metadata['naplanStrand'] == null) {
      flags.add('unaligned_naplan');
    }

    if (metadata['context'] == null) {
      flags.add('no_context');
    }

    return flags;
  }

  /// Generate audit report for a batch of questions
  static Map<String, dynamic> generateBatchAuditReport({
    required String bankName,
    required int totalQuestions,
    required List<Map<String, dynamic>> auditResults,
  }) {
    final validCount = auditResults.where((r) => r['validationStatus']['isValid'] as bool).length;
    final flaggedCount = auditResults.where((r) => (r['flags'] as List).isNotEmpty).length;
    
    final qualityScores = auditResults.map((r) => r['qualityScore'] as double).toList();
    final averageQuality = qualityScores.isEmpty ? 0.0 : qualityScores.reduce((a, b) => a + b) / qualityScores.length;

    final allFlags = auditResults.expand((r) => r['flags'] as List).cast<String>().toList();
    final flagSummary = _summarizeFlags(allFlags);

    return {
      'bankName': bankName,
      'auditDate': DateTime.now().toIso8601String(),
      'totalQuestions': totalQuestions,
      'auditedQuestions': auditResults.length,
      'validQuestions': validCount,
      'validityRate': (validCount / auditResults.length) * 100,
      'averageQualityScore': (averageQuality * 100) / 100, // Round to 2 decimals
      'flaggedQuestions': flaggedCount,
      'flagRate': (flaggedCount / auditResults.length) * 100,
      'flagSummary': flagSummary,
      'qualityDistribution': _analyzeQualityDistribution(qualityScores),
      'recommendations': _generateRecommendations(auditResults, flagSummary),
    };
  }

  /// Summarize flags across all questions
  static Map<String, int> _summarizeFlags(List<String> flags) {
    final summary = <String, int>{};
    for (final flag in flags) {
      summary[flag] = (summary[flag] ?? 0) + 1;
    }
    return summary;
  }

  /// Analyze quality score distribution
  static Map<String, int> _analyzeQualityDistribution(List<double> scores) {
    return {
      'excellent': scores.where((s) => s >= 90).length, // 90-100
      'good': scores.where((s) => s >= 75 && s < 90).length, // 75-89
      'fair': scores.where((s) => s >= 60 && s < 75).length, // 60-74
      'needs_work': scores.where((s) => s < 60).length, // <60
    };
  }

  /// Generate recommendations based on audit results
  static List<String> _generateRecommendations(
    List<Map<String, dynamic>> auditResults,
    Map<String, int> flagSummary,
  ) {
    final recommendations = <String>[];

    if ((flagSummary['too_easy'] ?? 0) > 0) {
      recommendations.add('Review ${flagSummary['too_easy']} questions with difficulty < 0.2. Consider increasing complexity.');
    }

    if ((flagSummary['too_hard'] ?? 0) > 0) {
      recommendations.add('Review ${flagSummary['too_hard']} questions with difficulty > 0.8. Consider simplifying or providing hints.');
    }

    if ((flagSummary['unaligned_acara'] ?? 0) > 0) {
      recommendations.add('${flagSummary['unaligned_acara']} questions lack ACARA alignment. Review skill tags and content.');
    }

    if ((flagSummary['unaligned_naplan'] ?? 0) > 0) {
      recommendations.add('${flagSummary['unaligned_naplan']} questions lack NAPLAN strand alignment. Consider broader curriculum coverage.');
    }

    if ((flagSummary['no_context'] ?? 0) > 0) {
      recommendations.add('${flagSummary['no_context']} questions lack real-world context. Consider embedding in meaningful scenarios.');
    }

    if (auditResults.isEmpty) {
      recommendations.add('No questions to audit. Ensure question bank is populated.');
    }

    return recommendations;
  }

  /// Export audit report as JSON string
  static String exportReportAsJson(Map<String, dynamic> report) {
    return JsonEncoder.withIndent('  ').convert(report);
  }

  /// Export audit report as markdown table
  static String exportReportAsMarkdown(Map<String, dynamic> report) {
    final sb = StringBuffer();
    sb.writeln('# Question Audit Report');
    sb.writeln();
    sb.writeln('## Summary');
    sb.writeln('| Metric | Value |');
    sb.writeln('|--------|-------|');
    sb.writeln('| Bank Name | ${report['bankName']} |');
    sb.writeln('| Total Questions | ${report['totalQuestions']} |');
    sb.writeln('| Audited | ${report['auditedQuestions']} |');
    sb.writeln('| Valid | ${report['validQuestions']} (${(report['validityRate'] as double).toStringAsFixed(1)}%) |');
    sb.writeln('| Avg Quality | ${(report['averageQualityScore'] as double).toStringAsFixed(1)}/100 |');
    sb.writeln('| Flagged | ${report['flaggedQuestions']} (${(report['flagRate'] as double).toStringAsFixed(1)}%) |');
    sb.writeln();
    
    if ((report['flagSummary'] as Map).isNotEmpty) {
      sb.writeln('## Flags');
      sb.writeln('| Flag | Count |');
      sb.writeln('|------|-------|');
      final flags = report['flagSummary'] as Map<String, int>;
      flags.forEach((flag, count) {
        sb.writeln('| $flag | $count |');
      });
      sb.writeln();
    }

    if ((report['recommendations'] as List).isNotEmpty) {
      sb.writeln('## Recommendations');
      final recs = report['recommendations'] as List;
      for (var i = 0; i < recs.length; i++) {
        sb.writeln('${i + 1}. ${recs[i]}');
      }
    }

    return sb.toString();
  }
}
