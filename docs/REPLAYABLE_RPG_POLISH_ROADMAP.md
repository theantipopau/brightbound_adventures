# BrightBound Adventures - Replayable RPG Polish Roadmap

**Updated:** June 2026  
**Product direction:** make BrightBound feel like a replayable learning RPG, not a stack of worksheets with rewards attached.

## North Star

BrightBound should make a child want to come back because the world changes, the character grows, the questions feel fresh, and every session gives a clear reason to play one more quest.

The strongest loop is:

`world map -> choose quest -> interactive practice -> meaningful feedback -> loot/progress -> visible character/world change -> next tempting quest`

## Design Pillars

1. **Replayable by design**
   - Sessions should rotate question types, contexts, quest goals, rewards, and difficulty.
   - Replays should feel like new attempts at a familiar skill, not reruns of the same prompt.
   - Missed concepts should return through spaced repetition and remixed question variants.

2. **RPG progress you can see**
   - XP, stars, outfits, accessories, titles, pets/companions, badges, zone mastery, and world unlocks should all connect.
   - The avatar should visibly reflect progress on the map, in practice screens, results screens, and the shop.
   - Rewards should preview before play and land immediately after play.

3. **Interactive learning, not static quizzes**
   - Multiple choice remains the fast baseline, but high-value skills need matching, ordering, drag/drop, tracing, typing, timed challenges, boss rounds, and mini-game variants.
   - The app should pick interaction types that suit the skill rather than forcing every concept into the same UI.

4. **Fast, calm, polished**
   - Visual richness should come from strong composition, readable surfaces, good assets, and restrained motion.
   - Animations should be event-driven, reduced-motion aware, and cheap to repaint.
   - Web and tablet layouts should feel first-class.

5. **Parent trust**
   - The app should explain growth clearly: what improved, what needs review, and what to play next.
   - Analytics should stay local/privacy-first unless an explicit sync layer is later added.

## Current Progress

Completed in the current sprint:

- Phase 0 verification baseline is green:
  - `dart format lib test`
  - `flutter analyze`
  - `flutter test`
  - `flutter build web --release`
- Added local `QuestSessionSummary` and `QuestSessionHistoryService`.
- Registered session history in `ServiceRegistry` and the app provider tree.
- Numeracy, literacy, and science quiz sessions now record:
  - zone,
  - skill,
  - skill name,
  - started/ended time,
  - score,
  - accuracy,
  - hints used,
  - difficulty,
  - question IDs,
  - fresh vs repeated question counts.
- Added question-set freshness stats through `QuestionVariationHelper.buildSessionQuestionSetWithStats`.
- Added tests for session history and question freshness stats.

Next best move: use these session summaries to generate visible review/challenge quest recommendations on the world map.

## Current Priority Order

### Phase 0: Stabilise and Verify

Goal: make the current improvement pass safe to build on.

- Run `dart format lib test`.
- Run `flutter analyze`.
- Run `flutter test`.
- Run `flutter build web --release`.
- Fix any fallout from the shared quiz layout, answer option, adaptive difficulty, and question generator changes.
- Add smoke tests for:
  - shared quiz layout on narrow and wide constraints,
  - answer option activation/state changes,
  - world map render,
  - avatar creator happy path,
  - shop purchase/equip path.

Exit criteria:

- Analyzer is clean.
- Tests pass.
- A release web build completes.
- No visible clipping on phone, tablet portrait, tablet landscape, and desktop.

### Phase 1: Replayability Engine

Goal: every practice session should have freshness, purpose, and memory.

- Expand `QuestionFreshnessService` from passive tracking into active selection:
  - sort candidate questions by freshness,
  - avoid recent prompt hashes,
  - intentionally reintroduce missed concepts after a delay,
  - track repeated wrong answers as weak concepts.
- Add session goal types:
  - accuracy goal,
  - streak goal,
  - speed goal,
  - no-hints goal,
  - review weak concepts goal.
- Add quest modifiers:
  - "Review Round": more missed concepts,
  - "Treasure Run": earn bonus stars for streaks,
  - "Boss Prep": harder mixed questions,
  - "Calm Practice": no timer, more hints.
- Store lightweight session summaries:
  - skill IDs practised,
  - accuracy,
  - time spent,
  - hints used,
  - fresh vs repeated questions,
  - rewards earned.

Exit criteria:

- Replaying the same skill produces a visibly different question mix.
- Results screen can say why the next quest is recommended.
- Parent/dashboard systems can read session summaries later.

### Phase 2: Better Question Quality

Goal: questions should feel age-appropriate, contextual, and varied.

- Build a question quality rubric:
  - clear prompt,
  - one unambiguous correct answer,
  - plausible distractors,
  - useful explanation,
  - age/curriculum fit,
  - context variety,
  - cognitive level.
- Add validation helpers for generated questions:
  - no duplicate options,
  - correct index valid,
  - no empty hint/explanation for core quizzes,
  - no option text longer than the UI can support without wrapping badly,
  - no repeated exact prompt in a session.
- Prioritise content gaps:
  - numeracy: time, money, measurement, geometry, data, fractions, decimals,
  - literacy: comprehension passages, inference, punctuation in context, vocabulary in context,
  - science: observation, classification, states of matter, habitats, simple experiments,
  - logic: multi-step pattern reasoning, spatial reasoning, deduction.
- Add more higher-order questions:
  - explain why,
  - choose the best strategy,
  - find the mistake,
  - compare two answers,
  - apply the concept in a story scenario.

Exit criteria:

- Core generated questions pass automated validation.
- Each major zone has enough variety for several sessions without obvious repeats.
- Explanations teach the concept, not just repeat the answer.

### Phase 3: RPG Character and Reward Loop

Goal: rewards should be visible, desirable, and connected to learning.

- Add a reward preview panel before starting each quest:
  - base stars,
  - bonus stars,
  - XP,
  - possible cosmetic/chest reward,
  - mastery progress.
- Add post-quest loot flow:
  - show stars flying into wallet,
  - XP bar fill,
  - level-up reward preview,
  - newly unlocked cosmetic/equip action.
- Expand cosmetics into categories:
  - outfit,
  - accessory,
  - trail/effect,
  - title,
  - companion/pet,
  - map decoration.
- Add rarity tiers:
  - common,
  - uncommon,
  - rare,
  - epic,
  - legendary.
- Add collection goals:
  - complete a zone set,
  - earn a mastery outfit,
  - collect all items in a theme.

Exit criteria:

- A child can see what they earned and where it appears.
- Shop inventory and avatar equip flows feel connected.
- Level-up and zone mastery unlocks feel meaningful.

### Phase 4: World Map as the Hub

Goal: the map should feel like a living board game hub.

- Make the quest board more actionable:
  - recommended next quest,
  - daily quest,
  - review quest,
  - boss quest when ready,
  - reward preview.
- Add zone states:
  - locked,
  - available,
  - in progress,
  - ready for boss,
  - mastered,
  - needs review.
- Add map progression feedback:
  - route markers,
  - small flags/stamps on completed quests,
  - unlocked decorations,
  - visible avatar movement after selection.
- Keep performance constraints:
  - static ambient effects by default on web/compact layouts,
  - event-only animations,
  - repaint boundaries around map layers,
  - no constantly ticking decoration unless it materially improves the scene.

Exit criteria:

- The map answers "what should I do next?" at a glance.
- Progress is visible without opening a dashboard.
- Map remains responsive on web and mobile.

### Phase 5: Interaction Variety

Goal: different skills should play differently.

- Add or deepen interaction types:
  - matching pairs,
  - sequence/order,
  - drag to category,
  - fill-in-the-blank,
  - tap the evidence,
  - number line placement,
  - shape/geometry manipulation,
  - short typed answer with forgiving validation,
  - timed boss variants.
- Route interaction type by skill:
  - homophones: sentence completion, matching, find-the-error,
  - fractions: visual fraction bars, number line, comparison,
  - time: clock manipulation,
  - measurement: choose tool/unit, estimate/compare,
  - comprehension: tap evidence, infer motive, order events.
- Add a practice mode switch:
  - calm practice,
  - challenge mode,
  - boss battle,
  - review mode.

Exit criteria:

- The app no longer feels like one repeated multiple-choice template.
- Interaction type supports the learning objective.
- Keyboard and touch flows are complete.

### Phase 6: Visual and Audio Polish

Goal: make the app feel premium without making it slow.

- Define a cleaner visual system:
  - fewer competing gradients,
  - consistent surface elevation,
  - consistent card radius and button language,
  - readable typography at every breakpoint,
  - zone palettes that are distinct but not overpowering.
- Replace noisy decorative effects with focused moments:
  - correct answer sparkle,
  - level-up burst,
  - chest open,
  - map unlock,
  - boss defeated.
- Add zone identity assets:
  - background motifs,
  - quest icons,
  - reward art,
  - avatar props.
- Improve sound:
  - short, optional UI sounds,
  - distinct correct/incorrect/level-up/chest sounds,
  - no looping ambience until performance is proven,
  - respect sound settings everywhere.

Exit criteria:

- Screens feel cohesive rather than assembled from separate styles.
- Motion is event-based and reduced-motion aware.
- Visual polish does not reduce frame stability.

Recent progress:

- Splash, onboarding, avatar creation, and world-entry now have centered, constrained first-run layouts with better keyboard/touch/mouse affordances.
- Avatar creation now reduces animation work in reduced-motion mode and uses a portrait-friendly character grid on narrow devices.
- World-entry timing is shorter and its looping animation controllers stop in reduced-motion mode.
- First-run viewport smoke tests now cover splash, onboarding, avatar creator, and world-entry at phone portrait, tablet portrait, and laptop sizes.

### Phase 7: Parent Insight and Learning Trust

Goal: make parents understand the value.

- Add weekly summary:
  - time practised,
  - skills improved,
  - skills needing review,
  - best streak,
  - recommended next goals.
- Add local goals:
  - sessions per week,
  - minutes per week,
  - zone mastery target,
  - review target.
- Add report/export later:
  - printable certificate,
  - progress summary,
  - teacher-friendly skill breakdown.

Exit criteria:

- Parents can quickly answer: "Is my child improving?"
- Recommendations are based on real session data.
- No unnecessary tracking or cloud dependency is introduced.

### Phase 8: Performance Hardening

Goal: keep the game rich but fast.

- Add performance budgets:
  - no page should create unbounded animation tickers,
  - particle counts capped by platform,
  - no large image decoded at full size when displayed small,
  - quiz answer selection should feel instant,
  - app startup should avoid forced delay.
- Add manual profiling checklist:
  - world map idle,
  - world map navigation,
  - quiz answer selection,
  - results screen,
  - shop grid,
  - avatar creator.
- Add viewport smoke checks for splash, onboarding, avatar creator, and world-entry at phone portrait, tablet portrait, laptop, and desktop widths.
- Add build/bundle tracking:
  - release web size,
  - largest assets,
  - unused assets,
  - font impact,
  - service worker/cache behaviour.

Exit criteria:

- Performance regressions are caught before polish layers are added.
- Web build size and runtime jank are tracked.
- Reduced-motion mode is genuinely calmer and faster.

## First Three Implementation Sprints

### Sprint 1: Verify and Smooth the Core Quiz Loop

- Format, analyze, test, and build.
- Fix any issues from the current shared quiz changes.
- Add shared quiz layout smoke tests.
- Replace per-game custom feedback pills with the shared `AnswerFeedbackPanel` where practical.
- Record question freshness/session summaries from numeracy, literacy, and science quizzes.

### Sprint 2: Replayable Quest Sessions

- Add `QuestSession` and `QuestGoal` models.
- Generate one recommended quest, one review quest, and one challenge quest per zone.
- Show quest goals and reward previews on the world map quest board.
- Use freshness and weak-skill history to choose questions.

### Sprint 3: Reward and Customisation Upgrade

- Add a post-quest reward reveal flow.
- Add cosmetic rarity and collection metadata.
- Improve Star Shop inventory/equip UI.
- Show equipped outfit/accessory/trail in more places.
- Add one zone mastery reward set as the template.

## Backlog By Impact

### Highest Impact

- Active question freshness and review scheduling.
- Reward previews and post-quest loot reveal.
- Quest board with daily/review/challenge quests.
- Better question validation and explanations.
- Interaction types beyond multiple choice.

### Medium Impact

- More cosmetics and rarity tiers.
- Companion/pet reactions.
- Parent weekly summary.
- Boss quest flow per zone.
- Map decorations from achievements.

### Polish Impact

- Stronger zone visual identity.
- Cleaner global surface/button system.
- Better sounds.
- Event-only animations.
- Better empty/loading/error states.

### Technical Impact

- Widget smoke tests for key screens.
- Performance profiling checklist.
- Asset size audit.
- Bundle tracking.
- Data model cleanup for sessions/rewards.

## Definition of Done for Future Polish Work

Every substantial polish or gameplay task should include:

- visual check on phone, tablet, and desktop,
- reduced-motion behaviour,
- keyboard/touch path,
- no clipped text,
- no constantly ticking animation unless justified,
- focused test or smoke test when the behaviour is shared,
- changelog entry.
