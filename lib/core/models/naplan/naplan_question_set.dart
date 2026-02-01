class NaplanQuestionSet {
  final Meta meta;
  final List<Question> questions;

  NaplanQuestionSet({required this.meta, required this.questions});

  factory NaplanQuestionSet.fromJson(Map<String, dynamic> json) {
    return NaplanQuestionSet(
      meta: Meta.fromJson(json['meta']),
      questions: (json['questions'] as List)
          .map((i) => Question.fromJson(i))
          .toList(),
    );
  }
}

class Meta {
  final String subject;
  final int yearLevel;
  final String source;
  final String version;

  Meta({
    required this.subject,
    required this.yearLevel,
    required this.source,
    required this.version,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      subject: json['subject'],
      yearLevel: json['year_level'],
      source: json['source'],
      version: json['version'],
    );
  }
}

class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final int difficulty;
  final String topic;
  final String? hint;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.difficulty,
    required this.topic,
    this.hint,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correct_index'],
      difficulty: json['difficulty'],
      topic: json['topic'],
      hint: json['hint'],
    );
  }
}
