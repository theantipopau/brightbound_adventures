# Phase 7.2: Metadata Generation Template

This document provides the template and process for generating ACARA/NAPLAN metadata for all questions.

---

## Example: Homophone Question Metadata

### Source Question
```dart
LiteracyQuestion(
  id: 'hom_1',
  skillId: 'skill_homophones',
  question: 'Which word means "a place to live"?',
  options: ['their', 'there', 'they\'re'],
  correctIndex: 1,
  hint: 'Think about a location',
  explanation: '"There" refers to a place. "Their" shows ownership. "They\'re" means "they are".',
  difficulty: 1,
)
```

### Generated Metadata
```json
{
  "questionId": "hom_1",
  "skillId": "skill_homophones",
  "acaraCodes": ["ACELA1440"],
  "yearLevel": 3,
  "naplanStrand": "spelling",
  "contentDomain": "word_recognition",
  "cognitiveLevel": 1.0,
  "cognitiveDescription": "Remember",
  "context": "story",
  "estimatedDifficulty": 0.15,
  "difficultyLabel": "easy",
  "questionType": "multiple_choice_select_correct",
  "bloomsLevel": {
    "code": 1,
    "name": "Remember",
    "descriptor": "Recall facts and basic concepts"
  },
  "acaraAlignment": {
    "primary": {
      "code": "ACELA1440",
      "description": "Spell words using the spelling patterns and generalisations being taught",
      "contentDescriptor": "Spelling - homophones and near-homophones",
      "achievementStandard": "Students spell most words correctly, with accurate spelling of most homophones and near-homophones"
    },
    "strand": "Spelling",
    "subStrand": "Word Recognition"
  },
  "naplanAlignment": {
    "strand": "spelling",
    "itemFormat": "Multiple choice",
    "skillCode": "NAPLAN_SPL_001"
  },
  "psychometrics": {
    "discriminationIndex": null,
    "difficultyIndex": 0.15,
    "confidence": 0.7,
    "estimateMethod": "cognitive_complexity"
  },
  "qualityMetrics": {
    "hasHint": true,
    "hasExplanation": true,
    "hasContext": false,
    "optionCount": 3,
    "qualityScore": 82.5
  },
  "flags": ["missing_context"],
  "suggestions": [
    "Consider embedding this question in a real-world scenario (e.g., fixing a text message, email, or story excerpt)",
    "The question could be contextualized: 'In an email to a friend, which is correct?' "
  ]
}
```

---

## Metadata Mapping Guidelines

### 1. ACARA Codes (ACARA v9)

#### Spelling (ACELA codes)
- **ACELA1440**: Spell words using patterns (homophones, near-homophones) - Year 3
- **ACELA1439**: Use apostrophes to show contractions and possession - Year 2-3
- **ACELA1441**: Use punctuation marks correctly - Year 3-4

#### Grammar (ACELA codes)
- **ACELA1438**: Identify and use nouns, verbs, adjectives - Year 2
- **ACELA1442**: Understand sentence structure - Year 3-4

#### Writing (ACELA codes)
- **ACELA1450**: Use accurate spelling - Year 4
- **ACELA1451**: Compose texts using wide vocabulary - Year 4

### 2. NAPLAN Strand Mapping

| Literacy Domain | NAPLAN Strand | Examples |
|----------------|---------------|----------|
| Spelling | NAPLAN_SPL | Homophones, apostrophes, spelling patterns |
| Grammar | NAPLAN_GRM | Punctuation, sentence structure |
| Vocabulary | NAPLAN_VOC | Word meanings, synonyms, antonyms |
| Reading | NAPLAN_RDG | Comprehension, inference, main idea |
| Writing | NAPLAN_WRT | Composition, organization, conventions |

### 3. Cognitive Levels (Bloom's Taxonomy)

| Level | Code | Name | Description | Example |
|-------|------|------|-------------|---------|
| 1 | 1.0 | Remember | Recall facts/concepts | "Which spelling is correct?" |
| 2 | 2.0 | Understand | Explain ideas/concepts | "Why is this punctuation correct?" |
| 3 | 3.0 | Apply | Use info in new situations | "Correct the spelling in this text" |
| 4 | 4.0 | Analyze | Distinguish parts and relationships | "Compare these sentence structures" |
| 5 | 5.0 | Evaluate | Justify a decision | "Evaluate which revision is better" |
| 6 | 6.0 | Create | Produce new work | "Write a paragraph using correct grammar" |

### 4. Context Categories

| Context | Code | Examples |
|---------|------|----------|
| Story | `story` | Narrative passages, dialogue |
| Email | `email` | Informal/formal emails, messages |
| Recipe | `recipe` | Instructions, ingredient lists |
| Advertisement | `advertisement` | Product descriptions, marketing copy |
| News Article | `newsArticles` | News headlines, articles |
| Poetry | `poetry` | Poems, verse, rhyming text |
| Instructions | `instructions` | How-to guides, steps |
| Dialogue | `dialogue` | Conversations, interviews |
| Academic | `academic` | Textbook-style questions |
| Social Media | `socialMedia` | Posts, comments, messages |

### 5. Difficulty Estimation

**Formula**: (Cognitive Level + Context Complexity + Pattern Recognition) / 3

**Scale: 0.0-1.0**
- 0.0-0.2: Easy (Level 1-2, common patterns, clear context)
- 0.2-0.4: Easy-Medium (Level 2-3, some complexity)
- 0.4-0.6: Medium (Level 3, multiple patterns, requires analysis)
- 0.6-0.8: Medium-Hard (Level 4-5, complex relationships)
- 0.8-1.0: Hard (Level 5-6, synthesis/evaluation, uncommon patterns)

---

## Audit Batch Template

### Homophones (hom_1 through hom_15)

#### Common ACARA/NAPLAN Pattern
```json
{
  "skillId": "skill_homophones",
  "acaraCodes": ["ACELA1440"],
  "yearLevel": 3,
  "naplanStrand": "spelling",
  "contentDomain": "word_recognition",
  "cognitiveLevel": 1.0,
  "context": "academic"  // To be updated per question
}
```

#### Individual Question Adaptations

| ID | Pattern | Context | Difficulty | Cognitive | Notes |
|----|---------|---------|------------|-----------|-------|
| hom_1 | there/their/they're | academic | 0.15 | 1.0 | Missing context - add email scenario |
| hom_2 | their/there/they're | academic | 0.20 | 1.0 | Good progression - intermediate difficulty |
| hom_3 | its/it's | academic | 0.10 | 1.0 | Very easy - consider combining |
| hom_4 | to/too/two | academic | 0.18 | 1.0 | Missing context |
| hom_5 | to/too/two | academic | 0.22 | 1.0 | Number context helps |
| hom_6 | blue/blew | academic | 0.25 | 2.0 | Good - requires understanding |
| hom_7 | blew/blue | academic | 0.28 | 2.0 | Good progression |
| hom_8 | hour/our | academic | 0.30 | 2.0 | Less common - good variety |
| hom_9 | hour/our | academic | 0.32 | 2.0 | Good paired question |
| hom_10 | would/wood | academic | 0.35 | 2.0 | Context would help |
| hom_11 | would/wood | academic | 0.38 | 2.0 | Less common pairing |
| hom_12 | write/right/rite | academic | 0.40 | 2.5 | Three options - harder |
| hom_13 | right/write/rite | academic | 0.42 | 2.5 | Good pair - three options |
| hom_14 | one/won | academic | 0.20 | 1.0 | Easy - number context |
| hom_15 | one/won | academic | 0.22 | 1.0 | Similar to previous |

### Apostrophes (apos_1 through apos_10)

#### Common Pattern
```json
{
  "skillId": "skill_apostrophes",
  "acaraCodes": ["ACELA1439"],
  "yearLevel": 2-3,
  "naplanStrand": "grammar",
  "contentDomain": "mechanics",
  "cognitiveLevel": 1.0-2.0,
  "context": "academic"  // To be updated
}
```

#### Individual Mappings

| ID | Type | Year | Cognitive | Difficulty | Issues |
|----|------|------|-----------|------------|--------|
| apos_1 | Contraction (do not) | 2 | 1.0 | 0.15 | Missing context |
| apos_2 | Contraction (I am) | 2 | 1.0 | 0.12 | Missing context |
| apos_3 | Contraction (cannot) | 2 | 1.0 | 0.18 | Missing context |
| apos_4 | Contraction (we are) | 2 | 1.0 | 0.15 | Missing context |
| apos_5 | Contraction (will not) | 3 | 1.0 | 0.20 | Missing context |
| apos_6 | Possessive (noun's) | 3 | 2.0 | 0.30 | Could add text context |
| apos_7 | Possessive (plural) | 3 | 2.0 | 0.35 | More complex |
| apos_8 | Complex contraction | 4 | 2.0 | 0.40 | Good variety |
| apos_9 | Mixed (contraction/possessive) | 4 | 2.5 | 0.45 | Good difficulty progression |
| apos_10 | Advanced usage | 4 | 2.5 | 0.50 | Requires analysis |

### Punctuation (punc_1 through punc_12)

#### Common Pattern
```json
{
  "skillId": "skill_punctuation",
  "acaraCodes": ["ACELA1438", "ACELA1441"],
  "yearLevel": 3-4,
  "naplanStrand": "grammar",
  "contentDomain": "mechanics",
  "context": "varies"
}
```

#### Individual Mappings

| ID | Focus | Cognitive | Difficulty | Context | Notes |
|----|-------|-----------|------------|---------|-------|
| punc_1 | List commas | 1.0 | 0.25 | academic | Good example |
| punc_2 | Question mark | 1.0 | 0.12 | academic | Very easy |
| punc_3 | Exclamation | 1.0 | 0.15 | academic | Basic |
| punc_4 | Introductory comma | 2.0 | 0.35 | academic | Good progression |
| punc_5 | Coordinating comma | 2.0 | 0.40 | academic | More complex |
| punc_6 | Dialogue punctuation | 2.0 | 0.45 | dialogue | Context helps |
| punc_7 | Complex sentences | 3.0 | 0.55 | academic | Requires analysis |
| punc_8 | Dialogue + punctuation | 2.5 | 0.50 | dialogue | Good contextualization |
| punc_9 | Multiple rules | 3.0 | 0.60 | story | Complex |
| punc_10 | Mixed punctuation | 3.0 | 0.65 | academic | Challenging |
| punc_11 | Semicolon usage | 4.0 | 0.70 | academic | Advanced |
| punc_12 | Colon usage | 4.0 | 0.75 | list | Advanced |

---

## Quality Checklist

For each batch of questions, verify:

### Metadata Completeness
- [ ] All questions have ACARA codes
- [ ] All questions have year levels (2-6)
- [ ] All questions have NAPLAN strand
- [ ] All questions have cognitive level
- [ ] All questions have difficulty estimate
- [ ] All questions have context category

### Quality Standards
- [ ] Variety in difficulty levels (not all <0.3)
- [ ] Balanced cognitive levels (not all "Remember")
- [ ] Real-world contexts where appropriate (not all "academic")
- [ ] Clear progression from easy to hard
- [ ] Hint quality assessed
- [ ] Explanation quality assessed

### Validation
- [ ] No flags for missing critical metadata
- [ ] Quality scores calculated correctly
- [ ] Difficulty estimates reasonable
- [ ] Cognitive levels accurate
- [ ] Context assignments appropriate

---

## Next Steps

1. **Generate Full Metadata** for 37 questions in initial batch
2. **Create Audit Reports** for each bank (Homophones, Apostrophes, Punctuation)
3. **Identify Patterns** across all three banks
4. **Generate Recommendations** for improvements
5. **Continue to Full Audit** for remaining 200+ questions

**Status**: Template complete, ready for batch generation

