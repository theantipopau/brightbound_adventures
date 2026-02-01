import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:brightbound_adventures/core/models/naplan/naplan_question_set.dart';

class QuestionLoaderService {
  static const String _basePath = 'lib/core/data';

  Future<NaplanQuestionSet> loadQuestions(String filename) async {
    try {
      final String jsonString = await rootBundle.loadString('$_basePath/$filename');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return NaplanQuestionSet.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }
}
