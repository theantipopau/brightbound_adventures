# Phase 7: Question Audit & Metadata Mapping

## Status: IN PROGRESS

### Overview
Map all existing questions (200+) from Dart files to ACARA v9 standards, NAPLAN strands, cognitive levels, and contexts using the new `QuestionMetadata` model.

---

## 1. Question Files to Audit

| File | Type | Approx Count | Status | Notes |
|------|------|-------------|--------|-------|
| `lib/features/literacy/models/question.dart` | LiteracyQuestion | 150+ | 🔄 Auditing | HomophoneQuestions, ApostropheQuestions, etc. |
| `lib/features/numeracy/models/question.dart` | NumeracyQuestion | 100+ | 🔄 Auditing | Counting, Addition, Fractions, etc. |
| `lib/core/utils/literacy_skill_questions.dart` | Various | 50+ | 🔄 Auditing | Extended literacy skill questions |
| `lib/core/utils/australian_naplan_questions.dart` | Various | 40+ | 🔄 Auditing | NAPLAN prep questions |
| `lib/core/utils/story_springs_questions.dart` | Story-based | 30+ | 🔄 Auditing | Creative writing prompts |
| `lib/core/utils/enhanced_question_generator.dart` | Generated | ~50 | 🔄 Auditing | Dynamically generated questions |
| **TOTAL** | - | **420+** | - | **Full audit needed** |

---

## 2. ACARA Mapping Key Decisions

### Literacy (Word Woods)

| Skill | ACARA Code (Year 3) | ACARA Code (Year 5) | NAPLAN Strand | Context Examples |
|-------|-------------------|-------------------|------------------|-----------------|
| **Homophones** | ACELA1440 | ACELA1557 | Spelling | Social media, emails, stories |
| **Apostrophes** | ACELA1452 | ACELA1565 | Punctuation | Dialogue, emails |
| **Compound Words** | ACELA1436 | ACELA1441 | Vocabulary | Instructions, recipes |
| **Synonyms/Antonyms** | ACELA1446 | - | Vocabulary | Stories, advertisements |
| **Reading Comprehension** | ACELY1688 | ACELY1740 | Reading | Stories, articles, informational |
| **Verb Tenses** | ACELA1450 | ACELA1560 | Grammar | Stories, emails |

### Numeracy (Number Nebula)

| Skill | ACARA Code (Year 3) | ACARA Code (Year 5) | NAPLAN Strand | Context Examples |
|-------|-------------------|-------------------|------------------|-----------------|
| **Place Value** | ACMNA053 | ACMNA099 | Number | Shopping, time, addresses |
| **Fractions** | ACMNA072 | ACMNA115 | Fractions | Cooking, pizza, shopping |
| **Addition/Subtraction** | ACMNA054 | ACMNA100 | Number | Shopping, sports scores |
| **Multiplication/Division** | ACMNA063 | ACMNA078 | Number | Shopping, games, sharing |
| **Patterns** | ACMNA064 | ACMNA124 | Patterns | Games, calendar, sequences |

---

## 3. Cognitive Level Mapping (Bloom's Taxonomy)

### Literacy Questions

```
Remember (1.0):
- "What word means..."
- "Which letter..."
- "Identify the..."

Understand (2.0):
- "What does this phrase mean?"
- "Why did the character..."
- "Complete the sentence..."

Apply (3.0):
- "Fix the mistake in..."
- "Use this word in..."
- "Choose the correct usage..."

Analyze (4.0):
- "How is this different from..."
- "Why did the author use..."
- "What pattern do you see..."

Evaluate (5.0):
- "Which version is better?"
- "Would this work in this context?"

Create (6.0):
- "Write your own sentence..."
- "Create a story using..."
```

### Numeracy Questions

```
Remember (1.0):
- "What is 5 + 3?"
- "How many shapes?"
- "Which is bigger?"

Understand (2.0):
- "Why is this pattern..."
- "What does this fraction represent?"
- "How would you explain..."

Apply (3.0):
- "If you have $50..."
- "How would you solve..."
- "Use multiplication to..."

Analyze (4.0):
- "Compare these two approaches..."
- "What's the most efficient way..."
- "Why does this strategy work..."

Evaluate (5.0):
- "Which strategy is best?"
- "Would this method work for..."

Create (6.0):
- "Design your own problem..."
- "Create a pattern where..."
```

---

## 4. Context Mapping Strategy

### Real-World Contexts Used

1. **Shopping** - Prices, change, budgeting, discounts
2. **Cooking** - Recipes, measurements, fractions, quantities
3. **Sports** - Scores, time, distance, speed
4. **Social Media** - Writing, tone, audience, spelling
5. **Stories** - Plot, character, setting, emotion
6. **Games** - Rules, counting, chance, strategy
7. **Time** - Clocks, calendars, sequences, duration
8. **Money** - Prices, change, saving, spending
9. **Building/Construction** - Measurement, shapes, planning
10. **Travel** - Distance, time, maps, planning
11. **School** - Tests, grades, scheduling, learning
12. **Family** - Relationships, sharing, responsibilities
13. **Pets** - Care, feeding, training, behavior
14. **Weather** - Temperature, patterns, seasons
15. **Hobbies** - Collections, crafts, interests
16. **Health** - Fitness, nutrition, sleep, exercise
17. **Technology** - Devices, apps, internet, safety
18. **Environment** - Recycling, conservation, nature
19. **Jobs/Careers** - Work, skills, earnings, planning
20. **Communication** - Letters, emails, presentations, conversation

---

## 5. Question Audit Process

### For Each Question File:

1. **Identify** skill and zone
2. **Map** to ACARA standard(s) using `acara_curriculum_mapping.json`
3. **Assign** cognitive level based on question type
4. **Select** primary context (or create new if needed)
5. **Estimate** difficulty (cross-check with current value)
6. **Note** any gaps or issues

### Template for Each Question

```dart
// BEFORE (current)
LiteracyQuestion(
  id: 'hom_1',
  skillId: 'skill_homophones',
  question: 'Which word means "a place to live"?',
  options: ['their', 'there', 'they\'re'],
  correctIndex: 1,
  difficulty: 1,
  // ... no metadata
)

// AFTER (with metadata)
LiteracyQuestion(
  id: 'hom_1',
  skillId: 'skill_homophones',
  question: 'Which word means "a place to live"?',
  options: ['their', 'there', 'they\'re'],
  correctIndex: 1,
  difficulty: 1,
  metadata: QuestionMetadata(
    id: 'hom_1',
    skillId: 'skill_homophones',
    primaryStandard: AcaraStandard(
      code: 'ACELA1440',
      yearLevel: 'Year 3',
      domain: AcaraDomain.literacy,
      strand: AcaraStrand.phonicsWordKnowledge,
      contentDescriptor: 'Understand how to identify and use homophones',
      achievementStandard: 'Students can identify homophones in context',
    ),
    naplanStrand: NaplanStrand.spelling,
    cognitiveLevel: CognitiveLevelBloom.remember,
    context: QuestionContext.social_media,
    difficulty: 1.0,
  )
)
```

---

## 6. Implementation Plan

### Phase 6.1: Create Metadata Integration (This Week)
- [x] Create `acara_curriculum_mapping.json` with all standard mappings
- [x] Update `question_metadata.dart` with complete enums and classes
- [ ] Extend LiteracyQuestion model to optionally include metadata
- [ ] Extend NumeracyQuestion model to optionally include metadata

### Phase 6.2: Audit Literacy Questions (Week 2)
- [ ] Audit homophone questions (15 questions)
- [ ] Audit apostrophe questions (20 questions)
- [ ] Audit compound words (10 questions)
- [ ] Audit synonyms/antonyms (25 questions)
- [ ] Audit comprehension questions (30 questions)
- [ ] Audit grammar/tenses (25 questions)
- [ ] Audit remaining literacy (25 questions)

### Phase 6.3: Audit Numeracy Questions (Week 2-3)
- [ ] Audit place value questions (20 questions)
- [ ] Audit fractions (25 questions)
- [ ] Audit addition/subtraction (30 questions)
- [ ] Audit multiplication/division (30 questions)
- [ ] Audit patterns (15 questions)
- [ ] Audit remaining numeracy (30 questions)

### Phase 6.4: Audit Other Files (Week 3)
- [ ] Australian NAPLAN questions (40 questions)
- [ ] Story Springs questions (30 questions)
- [ ] Enhanced question generator (50 questions)

### Phase 6.5: Create Migration Script (Week 4)
- [ ] Build tool to add metadata to all questions
- [ ] Validate completeness of mappings
- [ ] Test that all questions load correctly with metadata

---

## 7. Key Audit Findings (Update as we go)

### Literacy Observations
- Most questions focus on "Remember" level (70%) - need to increase Apply/Analyze
- Limited variety of contexts - mostly isolated examples, need real-world integration
- Comprehension questions limited (5 passages) - need 10+ diverse passages

### Numeracy Observations
- Good coverage of basics (counting, addition) - need advanced topics (fractions, decimals, geometry)
- Limited visual representations - consider adding more imagery
- Shopping context heavily used (good) - need more sports/time contexts

### Gaps Identified
- **Decimals**: 0 questions - need 10+
- **Comprehension**: 5 passages - need 10+ with varied genres
- **Measurement**: Limited (2 questions) - need 15+
- **Geometry**: 0 questions - need 15+
- **Data Interpretation**: 0 questions - need 10+
- **Time**: 5 questions - need 10+
- **Money**: 10 questions - need 15+

---

## 8. Success Criteria

✅ **Complete when:**
- All 200+ existing questions mapped to ACARA standards
- Each question assigned cognitive level, context, and metadata
- Gaps documented and prioritized for Phase 7.2
- Migration script validates all questions with complete metadata
- Zero questions missing ACARA mapping

---

## Timeline
- **Target Completion**: End of Week 3, January
- **Parallel Work**: Begin multi-type question system (Phase 7.3) while auditing

