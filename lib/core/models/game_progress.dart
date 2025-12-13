import 'package:equatable/equatable.dart';

class GameProgress extends Equatable {
  final String id;
  final String zoneId;
  final String gameId;
  final int sessionsCompleted;
  final int totalScore;
  final double averageAccuracy;
  final DateTime lastPlayedAt;

  const GameProgress({
    required this.id,
    required this.zoneId,
    required this.gameId,
    this.sessionsCompleted = 0,
    this.totalScore = 0,
    this.averageAccuracy = 0.0,
    required this.lastPlayedAt,
  });

  GameProgress copyWith({
    String? id,
    String? zoneId,
    String? gameId,
    int? sessionsCompleted,
    int? totalScore,
    double? averageAccuracy,
    DateTime? lastPlayedAt,
  }) {
    return GameProgress(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      gameId: gameId ?? this.gameId,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      totalScore: totalScore ?? this.totalScore,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        zoneId,
        gameId,
        sessionsCompleted,
        totalScore,
        averageAccuracy,
        lastPlayedAt,
      ];
}
