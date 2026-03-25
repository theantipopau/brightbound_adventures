import 'dart:math';

/// Builds varied question sets by removing duplicates and rotating recently seen items.
class QuestionVariationHelper {
  static final Map<String, List<String>> _recentQuestionIdsBySession = {};
  static const double _nearDuplicateThreshold = 0.82;
  static const int _defaultGroupGap = 2;

  static List<T> buildSessionQuestionSet<T>({
    required String sessionKey,
    required List<T> source,
    required String Function(T item) idOf,
    required String Function(T item) promptOf,
    String Function(T item)? groupKeyOf,
    int desiredCount = 10,
    int memorySize = 80,
    Random? random,
  }) {
    if (source.isEmpty) {
      return const [];
    }

    final rng = random ?? Random();
    final deduped = _dedupeByPrompt(source, promptOf);

    if (deduped.isEmpty) {
      return const [];
    }

    final recentIds = _recentQuestionIdsBySession.putIfAbsent(sessionKey, () => <String>[]);
    final pool = List<T>.from(deduped)..shuffle(rng);

    final unseen = <T>[];
    final fallback = <T>[];

    for (final item in pool) {
      if (recentIds.contains(idOf(item))) {
        fallback.add(item);
      } else {
        unseen.add(item);
      }
    }

    final selected = <T>[];
    selected.addAll(unseen.take(desiredCount));

    if (selected.length < desiredCount) {
      selected.addAll(fallback.take(desiredCount - selected.length));
    }

    // If still not enough, fill with unseen items shuffled again (never repeat in one session)
    if (selected.length < desiredCount && unseen.isNotEmpty) {
      final additionalPool = List<T>.from(unseen)..shuffle(rng);
      int addIndex = 0;
      while (selected.length < desiredCount && addIndex < additionalPool.length) {
        final candidate = additionalPool[addIndex++];
        if (!selected.any((s) => idOf(s) == idOf(candidate))) {
          selected.add(candidate);
        }
      }
    }

    // Last resort: shuffle fallback again if still short
    if (selected.length < desiredCount && fallback.isNotEmpty) {
      final additionalFallback = List<T>.from(fallback)..shuffle(rng);
      int addIndex = 0;
      while (selected.length < desiredCount && addIndex < additionalFallback.length) {
        final candidate = additionalFallback[addIndex++];
        if (!selected.any((s) => idOf(s) == idOf(candidate))) {
          selected.add(candidate);
        }
      }
    }

    final spreadSelected = groupKeyOf != null
        ? _spreadByGroup(
            items: selected,
            groupKeyOf: groupKeyOf,
            random: rng,
          )
        : selected;

    final balancedSelected = groupKeyOf != null
        ? _enforceGroupSpacing(
            items: spreadSelected,
            groupKeyOf: groupKeyOf,
            minGap: _defaultGroupGap,
          )
        : spreadSelected;

    final selectedIds = balancedSelected.map(idOf).toList();
    recentIds
      ..addAll(selectedIds)
      ..removeRange(
        0,
        recentIds.length > memorySize ? recentIds.length - memorySize : 0,
      );

    return balancedSelected;
  }

  static List<T> _dedupeByPrompt<T>(
      List<T> source, String Function(T item) promptOf) {
    // Two-stage dedupe:
    // 1) Exact normalized prompt match
    // 2) Near-duplicate prompt match by token similarity
    final uniqueByPrompt = <String, T>{};
    for (final item in source) {
      final promptKey = _normalizePrompt(promptOf(item));
      uniqueByPrompt.putIfAbsent(promptKey, () => item);
    }

    final exactDeduped = uniqueByPrompt.values.toList();
    final semanticDeduped = <T>[];
    final keptTokenSets = <Set<String>>[];

    for (final item in exactDeduped) {
      final tokens = _tokenizePrompt(promptOf(item));

      bool isNearDuplicate = false;
      for (final existing in keptTokenSets) {
        if (_jaccardSimilarity(tokens, existing) >= _nearDuplicateThreshold) {
          isNearDuplicate = true;
          break;
        }
      }

      if (!isNearDuplicate) {
        semanticDeduped.add(item);
        keptTokenSets.add(tokens);
      }
    }

    return semanticDeduped;
  }

  static String _normalizePrompt(String prompt) {
    return prompt
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static Set<String> _tokenizePrompt(String prompt) {
    final normalized = _normalizePrompt(prompt);
    if (normalized.isEmpty) {
      return <String>{};
    }

    const stopWords = {
      'the',
      'a',
      'an',
      'of',
      'to',
      'and',
      'or',
      'in',
      'on',
      'for',
      'is',
      'are',
      'was',
      'were',
      'this',
      'that',
      'these',
      'those',
      'which',
      'what',
      'choose',
      'select',
      'correct',
      'answer'
    };

    final words = normalized
        .split(' ')
        .where((w) => w.length > 1 && !stopWords.contains(w))
        .toSet();

    return words;
  }

  static double _jaccardSimilarity(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final intersection = a.intersection(b).length;
    final union = a.union(b).length;
    return union == 0 ? 0.0 : intersection / union;
  }

  static List<T> _spreadByGroup<T>({
    required List<T> items,
    required String Function(T item) groupKeyOf,
    required Random random,
  }) {
    if (items.length < 3) {
      return items;
    }

    final buckets = <String, List<T>>{};
    for (final item in items) {
      final key = groupKeyOf(item).trim().isEmpty
          ? 'ungrouped'
          : groupKeyOf(item).trim().toLowerCase();
      buckets.putIfAbsent(key, () => <T>[]).add(item);
    }

    final keys = buckets.keys.toList()..shuffle(random);
    for (final key in keys) {
      buckets[key]!.shuffle(random);
    }

    final result = <T>[];
    String? lastGroup;

    while (result.length < items.length) {
      String? selectedKey;
      int bestCount = -1;

      for (final key in keys) {
        final bucket = buckets[key]!;
        if (bucket.isEmpty) continue;

        final isDifferentFromLast = key != lastGroup;
        if (isDifferentFromLast && bucket.length > bestCount) {
          selectedKey = key;
          bestCount = bucket.length;
        }
      }

      selectedKey ??= keys.firstWhere(
        (k) => buckets[k]!.isNotEmpty,
        orElse: () => keys.first,
      );

      final chosenBucket = buckets[selectedKey]!;
      final next = chosenBucket.removeLast();
      result.add(next);
      lastGroup = selectedKey;
    }

    return result;
  }

  static List<T> _enforceGroupSpacing<T>({
    required List<T> items,
    required String Function(T item) groupKeyOf,
    required int minGap,
  }) {
    if (items.length <= 2 || minGap <= 0) {
      return items;
    }

    final result = List<T>.from(items);
    final lastIndexByGroup = <String, int>{};

    String norm(T item) {
      final raw = groupKeyOf(item).trim().toLowerCase();
      return raw.isEmpty ? 'ungrouped' : raw;
    }

    for (var i = 0; i < result.length; i++) {
      final currentGroup = norm(result[i]);
      final lastSeen = lastIndexByGroup[currentGroup];

      if (lastSeen != null && i - lastSeen <= minGap) {
        var swapIndex = -1;
        for (var j = i + 1; j < result.length; j++) {
          final candidateGroup = norm(result[j]);
          final candidateLastSeen = lastIndexByGroup[candidateGroup];
          final canPlaceCandidate =
              candidateLastSeen == null || i - candidateLastSeen > minGap;
          if (candidateGroup != currentGroup && canPlaceCandidate) {
            swapIndex = j;
            break;
          }
        }

        if (swapIndex != -1) {
          final temp = result[i];
          result[i] = result[swapIndex];
          result[swapIndex] = temp;
        }
      }

      lastIndexByGroup[norm(result[i])] = i;
    }

    return result;
  }

  /// Calculates novelty score (0-100) for a session.
  /// Novelty = percentage of questions that were unseen before this session.
  /// Useful for tracking session variety and engaging newer content.
  static double getNoveltyPercentage<T>({
    required String sessionKey,
    required List<T> selectedQuestions,
    required String Function(T item) idOf,
  }) {
    if (selectedQuestions.isEmpty) return 0.0;

    final recentIds = _recentQuestionIdsBySession[sessionKey] ?? <String>[];
    
    // Count how many selected questions were already in recent history
    // before this session was generated
    int unseenCount = 0;
    for (final item in selectedQuestions) {
      final itemId = idOf(item);
      // If item is not in recent history, it's unseen
      if (!recentIds.contains(itemId)) {
        unseenCount++;
      }
    }

    // Novelty = unseen / total * 100
    return (unseenCount / selectedQuestions.length) * 100.0;
  }

  /// Resets novelty history for a specific session key.
  /// Useful for testing or starting fresh with a skill.
  static void resetSessionNoveltyHistory(String sessionKey) {
    _recentQuestionIdsBySession.remove(sessionKey);
  }
}
