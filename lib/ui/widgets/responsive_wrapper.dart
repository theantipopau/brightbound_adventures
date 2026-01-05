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
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        
        // Calculate scale factor to fit design size
        double scale = 1.0;
        if (minWidth && size.width < designSize.width) {
          scale = size.width / designSize.width;
        }
        
        // If we also care about height (e.g. game view), we might want to use the smaller scale
        if (minHeight && size.height < designSize.height) {
          final heightScale = size.height / designSize.height;
          if (heightScale < scale) {
            scale = heightScale;
          }
        }

        // If scale is 1.0, just return child
        if (scale >= 1.0) {
          return child;
        }

        // Otherwise, scale the content
        return FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: designSize.width,
            height: designSize.height,
            child: child,
          ),
        );
      },
    );
  }
}
