import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// A single AI-generated question — normalised format shared across all zones.
class AiQuestion {
  final String question;

  /// Always exactly 4 options.
  final List<String> options;
  final int correctIndex;
  final String hint;
  final String explanation;

  const AiQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.hint,
    required this.explanation,
  });

  factory AiQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List).cast<String>();
    return AiQuestion(
      question: (json['question'] as String).trim(),
      options: options.map((o) => o.trim()).toList(),
      correctIndex: (json['correctIndex'] as num).toInt().clamp(0, 3),
      hint: (json['hint'] as String?)?.trim() ?? 'Think carefully about all the options.',
      explanation: (json['explanation'] as String?)?.trim() ?? '',
    );
  }
}

class _AiCache {
  final List<AiQuestion> questions;
  final DateTime fetchedAt;

  _AiCache({required this.questions, required this.fetchedAt});

  bool get isExpired => DateTime.now().difference(fetchedAt).inDays >= 7;
}

/// Manages AI-generated question fetching, caching, and serving to generators.
///
/// Architecture
/// ────────────
/// • Registered with Provider as a ChangeNotifier (for reactive rebuilds).
/// • Also accessible as [AiQuestionService.instance] from generators that have
///   no BuildContext — generators call the synchronous [getCached] method.
/// • [prefetch] is called fire-and-forget from practice screen initState so
///   that the next session has fresh questions in the cache.
/// • Results are stored in SharedPreferences (7-day TTL) so they survive
///   app restarts without burning Cloudflare AI neurons every session.
///
/// Questions arrive in batches of 10–20 from the Cloudflare Worker and are
/// merged into a pool of up to 60 per (zone, skill, difficulty) key.
class AiQuestionService extends ChangeNotifier {
  // ── Cloudflare Worker endpoint ─────────────────────────────────────────────
  //
  // After running `npx wrangler deploy` in workers/question-gen/, paste the
  // deployed URL here (e.g. https://brightbound-question-gen.<sub>.workers.dev).
  static const String workerUrl =
      'https://brightbound-question-gen.workers.dev';

  // ── Singleton ──────────────────────────────────────────────────────────────

  static AiQuestionService? _instance;

  /// Static accessor for generator code that has no BuildContext.
  static AiQuestionService get instance {
    _instance ??= AiQuestionService._();
    return _instance!;
  }

  // Private named constructor for internal use.
  AiQuestionService._();

  /// Public factory — used by ServiceRegistry / Provider.
  /// Always returns the singleton instance.
  factory AiQuestionService() {
    _instance ??= AiQuestionService._();
    return _instance!;
  }

  // ── State ──────────────────────────────────────────────────────────────────

  final Map<String, _AiCache> _pool = {};
  final Set<String> _inflight = {};
  SharedPreferences? _prefs;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Call once from ServiceRegistry after construction.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Synchronous getter for generators.
  ///
  /// Returns up to [count] cached AI questions for the given key.
  /// Returns an empty list (never throws) if no questions have been cached yet.
  List<AiQuestion> getCached({
    required String zone,
    required String skill,
    required int difficulty,
    int count = 5,
  }) {
    final key = _key(zone, skill, difficulty);
    final cache = _pool[key];
    if (cache == null || cache.questions.isEmpty) return const [];
    final pool = List<AiQuestion>.from(cache.questions)..shuffle();
    return pool.take(count).toList();
  }

  /// Fire-and-forget: fetch questions from the Cloudflare Worker and cache them.
  ///
  /// Safe to call multiple times — duplicate in-flight requests are suppressed
  /// and a warm cache (≥ 5 fresh questions) skips the network entirely.
  void prefetch({
    required String zone,
    required String skill,
    required int difficulty,
    int fetchCount = 20,
    String ageGroup = '6-9',
  }) {
    final key = _key(zone, skill, difficulty);
    if (_inflight.contains(key)) return;
    if (_isCacheWarm(key)) return;

    _inflight.add(key);
    _doFetch(
      zone: zone,
      skill: skill,
      difficulty: difficulty,
      fetchCount: fetchCount,
      ageGroup: ageGroup,
      key: key,
    );
  }

  // ── Internal fetch ─────────────────────────────────────────────────────────

  Future<void> _doFetch({
    required String zone,
    required String skill,
    required int difficulty,
    required int fetchCount,
    required String ageGroup,
    required String key,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(workerUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'zone': zone,
              'skill': skill,
              'difficulty': difficulty,
              'count': fetchCount.clamp(1, 10),
              'ageGroup': ageGroup,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final rawList = (body['questions'] as List?) ?? [];
        final questions = rawList
            .whereType<Map<String, dynamic>>()
            .map(AiQuestion.fromJson)
            .toList();
        if (questions.isNotEmpty) {
          _mergeIntoPool(key, questions);
          await _persistToPrefs(key, questions);
          notifyListeners();
        }
      }
    } catch (_) {
      // Network errors are silently swallowed — the app works perfectly
      // with its static question banks when AI is unavailable.
    } finally {
      _inflight.remove(key);
    }
  }

  void _mergeIntoPool(String key, List<AiQuestion> incoming) {
    final existing = _pool[key]?.questions ?? [];
    final seen = <String>{};
    final merged = <AiQuestion>[];
    for (final q in [...existing, ...incoming]) {
      if (seen.add(q.question.toLowerCase())) merged.add(q);
      if (merged.length >= 60) break;
    }
    _pool[key] = _AiCache(questions: merged, fetchedAt: DateTime.now());
  }

  bool _isCacheWarm(String key) {
    final cache = _pool[key];
    return cache != null && !cache.isExpired && cache.questions.length >= 5;
  }

  String _key(String zone, String skill, int difficulty) =>
      '${zone}_${skill}_$difficulty';

  // ── SharedPreferences persistence ──────────────────────────────────────────

  void _loadFromPrefs() {
    if (_prefs == null) return;
    final keys = _prefs!.getKeys().where((k) => k.startsWith('aiq_'));
    for (final prefKey in keys) {
      try {
        final raw = _prefs!.getString(prefKey);
        if (raw == null) continue;
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final fetchedAt =
            DateTime.tryParse((map['fetchedAt'] as String?) ?? '');
        if (fetchedAt == null) {
          _prefs!.remove(prefKey);
          continue;
        }
        if (DateTime.now().difference(fetchedAt).inDays >= 7) {
          _prefs!.remove(prefKey);
          continue;
        }
        final rawList = (map['questions'] as List?) ?? [];
        final questions = rawList
            .whereType<Map<String, dynamic>>()
            .map(AiQuestion.fromJson)
            .toList();
        final poolKey = prefKey.replaceFirst('aiq_', '');
        _pool[poolKey] =
            _AiCache(questions: questions, fetchedAt: fetchedAt);
      } catch (_) {
        _prefs!.remove(prefKey);
      }
    }
  }

  Future<void> _persistToPrefs(
      String key, List<AiQuestion> questions) async {
    if (_prefs == null) return;
    try {
      final payload = jsonEncode({
        'fetchedAt': DateTime.now().toIso8601String(),
        'questions': questions
            .map((q) => {
                  'question': q.question,
                  'options': q.options,
                  'correctIndex': q.correctIndex,
                  'hint': q.hint,
                  'explanation': q.explanation,
                })
            .toList(),
      });
      await _prefs!.setString('aiq_$key', payload);
    } catch (_) {}
  }
}
