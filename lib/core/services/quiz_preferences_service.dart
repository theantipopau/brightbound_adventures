import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightbound_adventures/core/services/ai_learning_assistant_service.dart';

class QuizPreferences {
  final bool autoReadQuestions;
  final bool aiHintsEnabled;
  final bool aiExplanationsEnabled;
  final bool aiCloudMode;

  const QuizPreferences({
    required this.autoReadQuestions,
    required this.aiHintsEnabled,
    required this.aiExplanationsEnabled,
    required this.aiCloudMode,
  });

  bool get aiEnabled => aiHintsEnabled || aiExplanationsEnabled;
}

class QuizPreferencesService {
  static const autoReadQuestionsKey = 'autoReadQuestions';
  static const aiHintsEnabledKey = 'aiHintsEnabled';
  static const aiExplanationsEnabledKey = 'aiExplanationsEnabled';
  static const aiCloudModeKey = 'aiCloudMode';

  static Future<QuizPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return QuizPreferences(
      autoReadQuestions: prefs.getBool(autoReadQuestionsKey) ?? false,
      aiHintsEnabled: prefs.getBool(aiHintsEnabledKey) ?? false,
      aiExplanationsEnabled: prefs.getBool(aiExplanationsEnabledKey) ?? false,
      aiCloudMode: prefs.getBool(aiCloudModeKey) ?? false,
    );
  }

  static void applyToAssistant(
    AiLearningAssistantService assistant,
    QuizPreferences preferences,
  ) {
    assistant
      ..setEnabled(preferences.aiEnabled)
      ..setCloudMode(preferences.aiCloudMode);
  }
}
