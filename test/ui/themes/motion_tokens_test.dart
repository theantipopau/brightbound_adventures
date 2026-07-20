import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/ui/themes/motion_tokens.dart';

void main() {
  Widget wrap({required bool disableAnimations, required WidgetBuilder build}) {
    return MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Builder(builder: build),
    );
  }

  group('MotionTokens', () {
    testWidgets('normal motion uses full durations and playful curves',
        (tester) async {
      late MotionTokens tokens;
      await tester.pumpWidget(wrap(
        disableAnimations: false,
        build: (context) {
          tokens = MotionTokens.of(context);
          return const SizedBox();
        },
      ));

      expect(tokens.reduced, isFalse);
      expect(tokens.instant, const Duration(milliseconds: 100));
      expect(tokens.quick, const Duration(milliseconds: 180));
      expect(tokens.standard, const Duration(milliseconds: 250));
      expect(tokens.emphasised, const Duration(milliseconds: 400));
      expect(tokens.celebration, const Duration(milliseconds: 850));
      expect(tokens.bounceCurve, Curves.easeOutBack);
      expect(tokens.elasticCurve, Curves.elasticOut);
      expect(tokens.pressScale, lessThan(1.0));
      expect(tokens.hoverLift, greaterThan(0.0));
    });

    testWidgets('reduced motion collapses everything toward instant/linear',
        (tester) async {
      late MotionTokens tokens;
      await tester.pumpWidget(wrap(
        disableAnimations: true,
        build: (context) {
          tokens = MotionTokens.of(context);
          return const SizedBox();
        },
      ));

      expect(tokens.reduced, isTrue);
      expect(tokens.instant, const Duration(milliseconds: 100));
      expect(tokens.quick, const Duration(milliseconds: 100));
      expect(tokens.standard, const Duration(milliseconds: 100));
      expect(tokens.emphasised, const Duration(milliseconds: 100));
      // Celebration still carries information (what was earned), so it
      // collapses to `standard` rather than vanishing entirely.
      expect(tokens.celebration, const Duration(milliseconds: 250));
      expect(tokens.standardCurve, Curves.linear);
      expect(tokens.enterCurve, Curves.linear);
      expect(tokens.exitCurve, Curves.linear);
      expect(tokens.bounceCurve, isNot(Curves.easeOutBack));
      expect(tokens.elasticCurve, isNot(Curves.elasticOut));
      expect(tokens.pressScale, 1.0);
      expect(tokens.hoverLift, 0.0);
    });
  });
}
