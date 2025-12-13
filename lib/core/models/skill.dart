import 'package:equatable/equatable.dart';

enum SkillState {
  locked,      // Not yet available
  introduced,  // First exposure to skill
  practising,  // Active practice
  mastered,    // Consistently high performance
}

class Skill extends Equatable {
  final String id;
  final String name;
  final String description;
  final String strand;  // ACARA strand
  final String? naplanArea; // NAPLAN high-difficulty area (optional)
  final SkillState state;
  final double accuracy; // 0.0 - 1.0
  final int attempts;
  final int hintsUsed;
  final DateTime lastPracticed;
  final int difficulty; // 1-5 scale

  const Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.strand,
    this.naplanArea,
    this.state = SkillState.locked,
    this.accuracy = 0.0,
    this.attempts = 0,
    this.hintsUsed = 0,
    required this.lastPracticed,
    this.difficulty = 1,
  });

  // Progression logic
  SkillState getNextState() {
    if (state == SkillState.locked) return SkillState.introduced;
    if (state == SkillState.introduced && accuracy >= 0.65) {
      return SkillState.practising;
    }
    if (state == SkillState.practising && accuracy >= 0.85 && hintsUsed == 0) {
      return SkillState.mastered;
    }
    return state;
  }

  Skill copyWith({
    String? id,
    String? name,
    String? description,
    String? strand,
    String? naplanArea,
    SkillState? state,
    double? accuracy,
    int? attempts,
    int? hintsUsed,
    DateTime? lastPracticed,
    int? difficulty,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      strand: strand ?? this.strand,
      naplanArea: naplanArea ?? this.naplanArea,
      state: state ?? this.state,
      accuracy: accuracy ?? this.accuracy,
      attempts: attempts ?? this.attempts,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        strand,
        naplanArea,
        state,
        accuracy,
        attempts,
        hintsUsed,
        lastPracticed,
        difficulty,
      ];
}
