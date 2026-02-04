class ScienceQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String? hint;
  final int difficulty;
  final String topic;

  ScienceQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.difficulty,
    required this.topic,
    this.explanation,
    this.hint,
  });
}
