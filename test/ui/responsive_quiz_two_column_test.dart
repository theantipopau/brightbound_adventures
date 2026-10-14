import 'package:brightbound_adventures/ui/widgets/responsive_quiz_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Size size) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: ResponsiveQuizLayout(
        questionCard: Container(key: const Key('question-card')),
        optionsArea: Container(key: const Key('options-area')),
      ),
    ),
  );
}

void main() {
  testWidgets('≥900px wide: question and options render side by side',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(const Size(1920, 1080)));
    await tester.pump();

    expect(find.byKey(const Key('question-card')), findsOneWidget);
    expect(find.byKey(const Key('options-area')), findsOneWidget);

    // Side-by-side: options sit to the right of the question (higher x).
    final questionX = tester.getCenter(find.byKey(const Key('question-card')));
    final optionsX = tester.getCenter(find.byKey(const Key('options-area')));
    expect(optionsX.dx, greaterThan(questionX.dx),
        reason: 'desktop layout puts options in the right column');
  });

  testWidgets('<900px wide: stacked unchanged (options below question)',
      (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(_host(const Size(420, 900)));
    await tester.pump();

    final questionY = tester.getCenter(find.byKey(const Key('question-card')));
    final optionsY = tester.getCenter(find.byKey(const Key('options-area')));
    expect(optionsY.dy, greaterThan(questionY.dy),
        reason: 'mobile keeps the stacked layout');
    expect(
      tester.getCenter(find.byKey(const Key('options-area'))).dx,
      closeTo(tester.getCenter(find.byKey(const Key('question-card'))).dx, 40),
    );
  });
}
