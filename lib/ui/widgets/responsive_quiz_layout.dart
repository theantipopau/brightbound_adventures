import 'package:flutter/material.dart';

/// Helper to determine screen breakpoints
class ScreenBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1920;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }
  
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktop;
  }
  
  static bool isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }
  
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= largeDesktop) return 120;
    if (width >= desktop) return 80;
    if (width >= tablet) return 40;
    return 20;
  }
  
  static double getMaxContentWidth(BuildContext context) {
    if (isLargeDesktop(context)) return 1400;
    if (isDesktop(context)) return 1200;
    return double.infinity;
  }
}

/// Responsive quiz layout widget
class ResponsiveQuizLayout extends StatelessWidget {
  final Widget questionCard;
  final Widget optionsArea;
  final Widget? feedbackWidget;
  final Widget? scoreCard;
  final double maxWidth;
  
  const ResponsiveQuizLayout({
    super.key,
    required this.questionCard,
    required this.optionsArea,
    this.feedbackWidget,
    this.scoreCard,
    this.maxWidth = 1400,
  });
  
  @override
  Widget build(BuildContext context) {
    final isWide = ScreenBreakpoints.isWideScreen(context);
    final padding = ScreenBreakpoints.getHorizontalPadding(context);
    
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
        child: isWide ? _buildSideBySideLayout() : _buildStackedLayout(),
      ),
    );
  }
  
  Widget _buildSideBySideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: Question + Score
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (scoreCard != null) ...[
                scoreCard!,
                const SizedBox(height: 20),
              ],
              questionCard,
              if (feedbackWidget != null) ...[
                const SizedBox(height: 20),
                feedbackWidget!,
              ],
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Right column: Options
        Expanded(
          flex: 5,
          child: optionsArea,
        ),
      ],
    );
  }
  
  Widget _buildStackedLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scoreCard != null) ...[
          scoreCard!,
          const SizedBox(height: 20),
        ],
        questionCard,
        const SizedBox(height: 20),
        optionsArea,
        if (feedbackWidget != null) ...[
          const SizedBox(height: 20),
          feedbackWidget!,
        ],
      ],
    );
  }
}
