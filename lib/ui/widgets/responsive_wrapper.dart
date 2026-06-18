import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final Size designSize;
  final bool minWidth;
  final bool minHeight;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.designSize = const Size(1024, 768),
    this.minWidth = true,
    this.minHeight = true,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const _BrightBoundScrollBehavior(),
      child: FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: child,
      ),
    );
  }
}

class _BrightBoundScrollBehavior extends MaterialScrollBehavior {
  const _BrightBoundScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
