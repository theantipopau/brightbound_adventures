# Phase 7 Premium Product Track

This track complements `PHASE_7_MASTER_PLAN.md` with content quality and AI integration.

## Track A — Repetition Reduction

- [x] Add semantic near-duplicate filtering in session generation
  - File: `lib/core/utils/question_variation_helper.dart`
- [x] Add exposure caps by concept tag (avoid same concept too soon)
  - Added group spacing enforcement to reduce concept clustering
- [ ] Add novelty score telemetry per session
- [ ] Build weekly duplicate report for question banks

## Track B — AI-Assisted Learning (Safe Rollout)

- [x] Add AI assistant service facade with local fallback mode
  - File: `lib/core/services/ai_learning_assistant_service.dart`
- [x] Add settings toggles:
  - `aiHintsEnabled`
  - `aiExplanationsEnabled`
  - `aiCloudMode` (off by default)
- [x] Wire AI hints into quiz hint dialogs
  - Implemented in literacy, numeracy, and science quiz flows
- [x] Wire AI explanations into post-answer feedback
  - Implemented in literacy, numeracy, and science quiz flows
- [ ] Add backend integration contract (server-side key only)

## Track C — Premium UX Polish

- [x] Path readability and contrast uplift
- [x] Star gain pop animation in map HUD
- [x] Locked zone overlay clarity
- [x] Current/selected zone visual hierarchy upgrades
- [x] Avatar creator control scaling pass
- [x] Question card typography and spacing pass for small screens

## Safety Requirements for AI

- No direct API keys in client app
- Server-side moderation and output filtering
- Deterministic fallback if AI fails
- Parent-facing transparency note in settings

## Done Criteria

- Repeated/near-duplicate prompts reduced by at least 30% in sampled sessions
- AI hint + explanation flow is optional, safe, and falls back gracefully
- UI remains stable with zero clipping on tested breakpoints
