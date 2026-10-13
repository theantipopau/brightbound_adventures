# Content Quality Report — question banks, generators, and feedback

**Recorded:** 6 October 2026
**Method:** static inspection of every question source under `lib/`. Counts are mechanical (`question:` / `explanation:` / `hint:` occurrences per file), so treat them as ±1 estimates rather than an authoring audit. No content in this repository has been through an educator review this cycle; existing curriculum mappings are preserved unchanged, and none have been strengthened.

---

## 1. Where the questions come from

| Source | Type | Used by |
|---|---|---|
| `lib/core/utils/literacy_skill_questions.dart` | hand-authored static bank | literacy skills with dedicated banks (homophones, apostrophes, commas…) |
| `lib/features/literacy/models/question.dart` (inline banks) | hand-authored static bank | fallback literacy/creative skills |
| `lib/features/numeracy/models/question.dart` | hand-authored static bank | numeracy |
| `lib/features/science/models/question.dart` + `lib/core/data/science_explorers_questions.json` | authored (Dart + JSON) | science |
| `lib/features/logic/models/question.dart` | hand-authored static bank | logic |
| `lib/features/storytelling/models/question.dart` + `lib/core/utils/story_springs_questions.dart` | hand-authored static bank | storytelling |
| `lib/core/utils/science_question_bank.dart` | hand-authored static bank | science quests |
| `lib/core/utils/puzzle_peaks_question_bank.dart` | hand-authored static bank | puzzle peaks |
| `lib/core/utils/australian_naplan_questions.dart` | authored, procedurally parameterised (numbers/contexts swapped) | numeracy/NAPLAN-flavoured sets |
| `lib/core/utils/word_woods_generator.dart`, `number_nebula_generator.dart`, `creative_corner_generator.dart`, `science_quest_generator.dart`, `story_springs_questions.dart`, `puzzle_peaks_question_bank.dart` | **procedural generators** (deterministic input → output, bounded difficulty) | any skill without a dedicated bank |
| `AiQuestionService` / `AiLearningAssistantService` | **network AI** (Cloudflare Worker) with a 7-day local cache; offline-first fallback is the static/procedural path | optional prefetch + AI hints/explanations toggles |

---

## 2. Explanation and hint coverage (the slice that now displays them)

Since this release, the authored explanation is shown after **every** answer, so coverage is no longer cosmetic — a question without one simply gives the child praise with no "why".

| Source | Questions | With explanation | With hint | Verdict |
|---|---:|---:|---:|---|
| `literacy_skill_questions.dart` | ~125 | ~112 | ~112 | Good; **~13 gaps** to fill |
| `puzzle_peaks_question_bank.dart` | ~52 | ~52 | ~52 | Complete |
| `science_question_bank.dart` | ~62 | ~62 | ~62 | Complete |
| `literacy` inline bank | ~65 | ~65 | ~65 | Complete |
| `numeracy` inline bank | ~159 | ~159 | ~159 | Complete |
| `logic` inline bank | ~55 | ~55 | ~55 | Complete |
| `science` inline bank | ~36 | ~36 | ~36 | Complete |
| `storytelling` inline bank | ~66 | ~66 | ~66 | Complete |
| **`story_springs_questions.dart`** | **~47** | **~1** | ~47 | **Priority gap: 46 questions have a hint but no explanation** |
| **`australian_naplan_questions.dart`** | ~42 prompts | ~4 | **0** | **Priority gap: no hints, almost no explanations** |
| `science_quest_generator.dart` | ~17 generated | ~10 | ~1 | Partial — generated output sometimes lacks both |
| `enhanced_question_generator.dart` (distractor shuffler) | n/a | **0** | **0** | Passes through the caller's question; never adds explanation/hint — safe, but it also cannot improve one |

**Because explanations are now visible, the two priority gaps above are the first authoring tasks of the next content pass.**

---

## 3. Interaction types currently reachable

| Interaction | Where | Status |
|---|---|---|
| Multiple choice (tap) | literacy, numeracy, science, logic, storytelling | dominant — every zone |
| Drag-to-order (structured, keyboard-equivalent) | Story Springs, one curated question | **tested slice only** (`test/interactions/drag_to_order_test.dart`); most sequencing content still renders as MCQ |
| Tracing / drawing | motor zone | live |
| Word search, pattern puzzle, memory match | mini-games | live |
| Sorting, number line, tap-the-evidence, fill-the-gap | — | **not implemented** (IN-3..IN-5 open) |

So the honest statement is: **the app is still overwhelmingly MCQ**, with one production-quality non-MCQ interaction.

---

## 4. Content problems found and fixed this cycle

1. **Fake fallback questions.** `skill_practice_screen.dart` used to return a real playable question reading *"This skill is coming soon! Would you like to practice anyway?"* when a generator threw — a child could "answer" a non-question and earn rewards for it. **Removed from the literacy route**; it now shows an honest empty state with a way forward. The same pattern **still exists** in `numeracy_practice_screen.dart` (CO-1 debt, listed in `docs/CURRENT_STATE_AUDIT.md`).
2. **Star-threshold mismatch.** The results screen displayed stars at ≥95/70/40% while `ShopService` awarded them at ≥90/70/50% — a child could see 1 star and receive 0. The reveal now reports `RewardResult.starsAwarded` (the value actually banked) and says what is needed next when it is zero.
3. **Explanation never rendered** (fixed in this slice — see §2).
4. **Questions regenerated on every rebuild** in `SkillPracticeScreen` — a random set could change under a child mid-quest (and made sessions untestable). Questions are now generated once per session in `initState`.

## 5. Content problems still open (flagged for educator review)

| Priority | Item | Evidence |
|---|---|---|
| P0 | `story_springs_questions.dart` explanations (≈46 missing) | §2 |
| P0 | `australian_naplan_questions.dart` hints + explanations (≈42/38 missing) | §2 |
| P0 | Reachable placeholder paths outside literacy: `story_practice_screen.dart`, `logic_practice_screen.dart`, `numeracy_practice_screen.dart` ("Coming Soon"/fake fallback), `shop_screen.dart`, exported `placeholder_zone_screen.dart` | grep, CO-1 |
| P1 | Distractor-rationale metadata does not exist as a field — `LiteracyQuestion`/`StoryQuestion` etc. carry `hint`/`explanation` but no `distractorRationale`, no `reviewStatus`, no `version` | model inspection |
| P1 | Near-duplicate detection across banks is not automated; `question_variation_helper.dart` only guards *within-session* repeats | `test/question_variation_helper_test.dart` scope |
| P1 | AI-generated content (`AiQuestionService`) is cached but not marked with source/review status in any persisted metadata | service inspection |
| P2 | Difficulty is an int 1–5 with no mapping to an age/year band in the question models | `Skill.difficulty`, question models |
| P2 | No validation gate fails CI on duplicate IDs/options or missing answers for advertised skills (CO-2 `content_matrix.json` still open) | — |

## 6. Recommended next content pass (in order)

1. Author explanations for the Story Springs and NAPLAN banks (highest visible impact now that explanations render).
2. Retire the remaining placeholder/fake-question paths (CO-1) so no advertised skill can hand back a non-question.
3. Add `content_matrix.json` + a CI check (CO-2) with duplicate-ID/option/answer validation.
4. Extend question metadata with `distractorRationale`, `reviewStatus`, `version`, and `source` (`authored` / `generated` / `ai`) so an educator can review by flag rather than by reading every file.
5. Roll the tested drag-to-order interaction into all sequencing content, then add sort-into-bins and number line (IN-3/IN-4).
