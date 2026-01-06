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
    // Simply return the child - let it fill the available space
    // The app will be responsive to any screen size
    return child;
  }
}
