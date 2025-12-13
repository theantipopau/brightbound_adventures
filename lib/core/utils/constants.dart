import 'package:uuid/uuid.dart';

class Constants {
  // Zone identifiers
  static const String zoneWordWoods = 'word_woods';
  static const String zoneNumberNebula = 'number_nebula';
  static const String zonePuzzlePeaks = 'puzzle_peaks';
  static const String zoneStorysprings = 'story_springs';
  static const String zoneAdventureArena = 'adventure_arena';

  // ACARA Strands
  static const String strandLiteracy = 'literacy';
  static const String strandNumeracy = 'numeracy';
  static const String strandCommunication = 'communication';
  static const String strandLogic = 'logic';
  static const String strandMotor = 'motor';

  // NAPLAN high-difficulty areas (Years 3 & 5)
  static const List<String> naplanHighRiskLiteracy = [
    'homophones',
    'silent_letters',
    'apostrophes',
    'commas',
    'pronoun_reference',
    'verb_tense',
    'inference',
    'main_idea',
  ];

  static const List<String> naplanHighRiskNumeracy = [
    'multi_step_problems',
    'fractions',
    'place_value',
    'time_elapsed',
    'measurements',
    'data_interpretation',
    'pattern_rules',
  ];

  // XP rewards
  static const int xpPerGameSession = 10;
  static const int xpPerSkillMastery = 50;
  static const int xpPerfectScore = 25;

  // Level progression
  static const int xpPerLevel = 100;
  static const int maxLevel = 50;
}

class UuidGenerator {
  static const Uuid _uuid = Uuid();

  static String generate() => _uuid.v4();

  static String generateSkillId() => 'skill_${_uuid.v4()}';

  static String generateAvatarId() => 'avatar_${_uuid.v4()}';

  static String generateGameProgressId() => 'progress_${_uuid.v4()}';
}

class StringFormatter {
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String formatAccuracy(double accuracy) {
    return '${(accuracy * 100).toStringAsFixed(0)}%';
  }

  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

class ValidationHelper {
  static bool isValidName(String name) {
    return name.isNotEmpty && name.length <= 50;
  }

  static bool isValidPin(String pin) {
    return pin.length == 4 && int.tryParse(pin) != null;
  }
}
