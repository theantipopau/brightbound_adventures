// Layout-overflow probe for the question + movement screens (2026-10-10
// clipping pass).
//
// Renders each real game screen at a tiny phone viewport and at 200% text
// scale — the two conditions that surfaced the clipping the bug report
// describes — and asserts Flutter raises no overflow/clip exceptions, both
// on first render and after answering (feedback panel state).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brightbound_adventures/core/services/adaptive_difficulty_service.dart';
import 'package:brightbound_adventures/core/services/avatar_provider.dart';
import 'package:brightbound_adventures/core/services/haptic_service.dart';
import 'package:brightbound_adventures/features/literacy/models/question.dart';
import 'package:brightbound_adventures/features/literacy/widgets/multiple_choice_game.dart';
import 'package:brightbound_adventures/features/logic/models/question.dart';
import 'package:brightbound_adventures/features/logic/widgets/logic_game.dart';
import 'package:brightbound_adventures/features/motor/models/motor_game.dart';
import 'package:brightbound_adventures/features/motor/widgets/motor_game.dart';
import 'package:brightbound_adventures/features/numeracy/models/question.dart';
import 'package:brightbound_adventures/features/numeracy/widgets/numeracy_game.dart';
import 'package:brightbound_adventures/features/science/models/question.dart';
import 'package:brightbound_adventures/features/science/widgets/science_game.dart';
import 'package:brightbound_adventures/features/storytelling/models/question.dart';
import 'package:brightbound_adventures/features/storytelling/widgets/story_game.dart';

const _longQuestion =
    'Which sentence uses the correct homophone for "there"? The dragon '
    'guarded its treasure deep inside the mountain cave, and nobody would '
    'ever find it unless they looked very carefully behind the hidden door.';

const _longOptions = [
  'Their treasure was buried under the old oak tree by the river bank',
  'There treasure was buried under the old oak tree by the river bank',
  'They’re treasure was buried under the old oak tree by the river bank',
  'Its treasure was buried under the old oak tree by the river bank',
];

Future<void> _probe(
  WidgetTester tester,
  Widget screen, {
  required Size size,
  double scale = 1.0,
  String? answerTapText,
  void Function()? validate,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<HapticService>(create: (_) => HapticService()),
        ChangeNotifierProvider<AdaptiveDifficultyService>(
          create: (_) => AdaptiveDifficultyService(),
        ),
        // Science game reads the avatar for its session header.
        ChangeNotifierProvider<AvatarProvider>(
          create: (_) => _ProbeAvatarProvider(),
        ),
      ],
      child: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(scale),
        ),
        child: MaterialApp(home: screen),
      ),
    ),
  );

  // Bounded pumps — games run ambient timers, pumpAndSettle would hang.
  await tester.pump(const Duration(milliseconds: 120));
  await tester.pump(const Duration(milliseconds: 500));
  expect(
    tester.takeException(),
    isNull,
    reason: 'initial render overflowed at '
        '${size.width}x${size.height} @${scale}x text',
  );

  if (answerTapText != null) {
    final target = find.text(answerTapText);
    if (target.evaluate().isNotEmpty) {
      await tester.tap(target.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 600));
      expect(
        tester.takeException(),
        isNull,
        reason: 'feedback state overflowed at '
            '${size.width}x${size.height} @${scale}x text',
      );
      if (validate != null) validate();
    }
  }

  await tester.pumpWidget(const SizedBox.shrink());
}

class _ProbeAvatarProvider extends AvatarProvider {
  @override
  bool get hasAvatar => true;

  @override
  Future<void> loadAvatar() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({
      'autoReadQuestions': false,
      'aiHintsEnabled': false,
      'aiExplanationsEnabled': false,
      'aiCloudMode': false,
    });
  });

  final viewports = <(String, Size, double)>[
    ('tiny phone', const Size(320, 568), 1.0),
    ('small phone @200% text', const Size(360, 640), 2.0),
  ];

  final literacy = LiteracyQuestion(
    id: 'probe_lit',
    skillId: 'probe_skill',
    question: _longQuestion,
    options: _longOptions,
    correctIndex: 3,
    hint: 'Look at the word before "treasure" and check what it modifies.',
    explanation: '"Its" shows the treasure belongs to the dragon.',
    difficulty: 2,
  );

  final numeracy = NumeracyQuestion(
    id: 'probe_num',
    skillId: 'probe_skill',
    question: 'What is 12 + 27?',
    options: ['37', '38', '39', '49'],
    correctIndex: 2,
    type: NumeracyQuestionType.multipleChoice,
  );

  final science = ScienceQuestion(
    id: 'probe_sci',
    skillId: 'probe_skill',
    question: _longQuestion,
    options: _longOptions,
    correctIndex: 3,
    difficulty: 2,
    topic: 'probe',
    explanation: 'Scientific reading: possessive "its" needs no apostrophe.',
  );

  final logic = LogicQuestion(
    id: 'probe_log',
    skillId: 'probe_skill',
    question: _longQuestion,
    options: _longOptions,
    correctIndex: 3,
    type: LogicQuestionType.multipleChoice,
  );

  final story = StoryQuestion(
    id: 'probe_sto',
    skillId: 'probe_skill',
    question: _longQuestion,
    options: _longOptions,
    correctIndex: 3,
    type: StoryQuestionType.multipleChoice,
  );

  for (final (label, size, scale) in viewports) {
    testWidgets('literacy quiz has no overflow — $label', (tester) async {
      await _probe(
        tester,
        MultipleChoiceGame(
          questions: [literacy],
          skillName: 'Homophones & Their Friends',
        ),
        size: size,
        scale: scale,
        answerTapText: _longOptions[3],
      );
    });

    testWidgets('numeracy quiz has no overflow — $label', (tester) async {
      await _probe(
        tester,
        NumeracyGame(questions: [numeracy], skillName: 'Addition Station'),
        size: size,
        scale: scale,
        answerTapText: '39',
      );
    });

    testWidgets('science quiz has no overflow — $label', (tester) async {
      await _probe(
        tester,
        ScienceGame(questions: [science]),
        size: size,
        scale: scale,
        answerTapText: _longOptions[3],
      );
    });

    testWidgets('logic quiz has no overflow — $label', (tester) async {
      await _probe(
        tester,
        LogicGame(
          questions: [logic],
          skillName: 'Pattern Party',
          onComplete: () {},
          onFinish: (correct, total, hints) {},
        ),
        size: size,
        scale: scale,
        answerTapText: _longOptions[3],
      );
    });

    testWidgets('story quiz has no overflow — $label', (tester) async {
      await _probe(
        tester,
        StoryGame(
          questions: [story],
          skillName: 'Story Builder',
          onComplete: () {},
          onFinish: (correct, total, hints) {},
        ),
        size: size,
        scale: scale,
        answerTapText: _longOptions[3],
      );
    });

    testWidgets('motor movement game has no overflow — $label', (tester) async {
      await _probe(
        tester,
        MotorGame(
          config: MotorGameConfigs.tapAccuracy,
          onGameComplete: (_) {},
        ),
        size: size,
        scale: scale,
      );
    });
  }

  group('taught feedback: authored explanation surfaces after answering', () {
    testWidgets('numeracy shows the authored explanation as a teaching note',
        (tester) async {
      const numeracyWithNote = NumeracyQuestion(
        id: 'note_num',
        skillId: 'probe_skill',
        question: 'What is 2 + 3?',
        options: ['4', '5', '6', '7'],
        correctIndex: 1,
        hint: 'Count on from 2.',
        explanation: '2 + 3 means two and three more — count 3, 4, 5.',
        type: NumeracyQuestionType.multipleChoice,
      );

      var noteShown = false;
      await _probe(
        tester,
        NumeracyGame(questions: [numeracyWithNote], skillName: 'Addition'),
        size: const Size(420, 900),
        answerTapText: '5',
        validate: () {
          noteShown = find.text('Why?').evaluate().isNotEmpty &&
              find
                  .text('2 + 3 means two and three more — count 3, 4, 5.')
                  .evaluate()
                  .isNotEmpty;
        },
      );

      expect(noteShown, isTrue,
          reason: 'the authored explanation must surface after answering');
    });

    testWidgets('science shows the authored explanation as a teaching note',
        (tester) async {
      const scienceWithNote = ScienceQuestion(
        id: 'note_sci',
        skillId: 'probe_skill',
        question: 'What do plants need to grow?',
        options: [
          'Only air',
          'Water, sunlight, and soil',
          'Only water',
          'Only sunlight'
        ],
        correctIndex: 1,
        hint: 'Think about the garden.',
        explanation:
            'Plants need water, sunlight and nutrients from soil to grow.',
        difficulty: 1,
        topic: 'Plant Needs',
      );

      var noteShown = false;
      await _probe(
        tester,
        ScienceGame(questions: [scienceWithNote]),
        size: const Size(420, 900),
        answerTapText: 'Water, sunlight, and soil',
        validate: () {
          noteShown = find.text('Why?').evaluate().isNotEmpty &&
              find
                  .text(
                      'Plants need water, sunlight and nutrients from soil to grow.')
                  .evaluate()
                  .isNotEmpty;
        },
      );

      expect(noteShown, isTrue,
          reason: 'the authored explanation must surface after answering');
    });

    testWidgets('numeracy hides the note when the question has no explanation',
        (tester) async {
      const numeracyNoNote = NumeracyQuestion(
        id: 'note_none_num',
        skillId: 'probe_skill',
        question: 'What is 1 + 1?',
        options: ['1', '2', '3', '4'],
        correctIndex: 1,
        type: NumeracyQuestionType.multipleChoice,
      );

      var noteHidden = true;
      await _probe(
        tester,
        NumeracyGame(
          questions: [numeracyNoNote],
          skillName: 'Addition',
        ),
        size: const Size(420, 900),
        answerTapText: '2',
        validate: () {
          noteHidden = find.text('Why?').evaluate().isEmpty;
        },
      );

      expect(noteHidden, isTrue,
          reason: 'no teaching note may appear without an explanation');
    });
  });
}
