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

  /// Get vertical spacing based on screen size
  static double getVerticalSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= largeDesktop) return 32;
    if (width >= desktop) return 24;
    if (width >= tablet) return 20;
    return 16;
  }

  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    return isDesktop(context) ? 56 : 48;
  }

  /// Get responsive font scale
  static double getFontScale(BuildContext context) {
    if (isLargeDesktop(context)) return 1.2;
    if (isDesktop(context)) return 1.1;
    if (isTablet(context)) return 1.0;
    return 0.95;
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
    final vSpacing = ScreenBreakpoints.getVerticalSpacing(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: vSpacing),
        child: isWide 
          ? _buildSideBySideLayout(vSpacing) 
          : _buildStackedLayout(vSpacing),
      ),
    );
  }

  Widget _buildSideBySideLayout(double spacing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: Question + Score (40% width)
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (scoreCard != null) ...[
                scoreCard!,
                SizedBox(height: spacing),
              ],
              questionCard,
              if (feedbackWidget != null) ...[
                SizedBox(height: spacing),
                feedbackWidget!,
              ],
            ],
          ),
        ),
        SizedBox(width: spacing + 8),
        // Right column: Options (60% width)
        Expanded(
          flex: 6,
          child: optionsArea,
        ),
      ],
    );
  }

  Widget _buildStackedLayout(double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scoreCard != null) ...[
          scoreCard!,
          SizedBox(height: spacing),
        ],
        questionCard,
        SizedBox(height: spacing),
        optionsArea,
        if (feedbackWidget != null) ...[
          SizedBox(height: spacing),
          feedbackWidget!,
        ],
      ],
    );
  }
}

/// Hover-enhanced card widget for better desktop experience
class HoverCard extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool enabled;

  const HoverCard({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE0E0E0),
    this.borderRadius = 16,
    this.onTap,
    this.tooltip,
    this.enabled = true,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Widget card = MouseRegion(
      cursor: widget.enabled && widget.onTap != null 
        ? SystemMouseCursors.click 
        : SystemMouseCursors.basic,
      onEnter: (_) {
        if (widget.enabled && widget.onTap != null) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        setState(() => _hovered = false);
      },
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: _hovered && widget.enabled
                ? widget.borderColor.withValues(alpha: 0.7)
                : widget.borderColor.withValues(alpha: 0.4),
              width: _hovered && widget.enabled ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered && widget.enabled
                  ? Colors.black.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.08),
                blurRadius: _hovered && widget.enabled ? 24 : 12,
                offset: Offset(0, _hovered && widget.enabled ? 10 : 4),
                spreadRadius: _hovered && widget.enabled ? 2 : 0,
              ),
            ],
          ),
          transform: (_hovered && widget.enabled)
            ? Matrix4.translationValues(0, -5, 0)
            : Matrix4.identity(),
          child: AnimatedOpacity(
            opacity: widget.enabled ? 1.0 : 0.6,
            duration: const Duration(milliseconds: 200),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      card = Tooltip(
        message: widget.tooltip!,
        showDuration: const Duration(seconds: 3),
        child: card,
      );
    }

    return card;
  }
}

/// Enhanced button with hover effects
class HoverButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color hoverColor;
  final double height;
  final String? tooltip;
  final bool enabled;

  const HoverButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = const Color(0xFF4CAF50),
    this.hoverColor = const Color(0xFF45a049),
    this.height = 56,
    this.tooltip,
    this.enabled = true,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Widget button = MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) {
        if (widget.enabled) setState(() => _hovered = true);
      },
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _hovered && widget.enabled
                ? [
                    widget.hoverColor,
                    widget.hoverColor.withValues(alpha: 0.85),
                  ]
                : [
                    widget.backgroundColor,
                    widget.backgroundColor.withValues(alpha: 0.9),
                  ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: _hovered && widget.enabled ? 0.5 : 0.2),
              width: _hovered && widget.enabled ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (_hovered && widget.enabled ? widget.hoverColor : widget.backgroundColor)
                    .withValues(alpha: _hovered && widget.enabled ? 0.5 : 0.2),
                blurRadius: _hovered && widget.enabled ? 24 : 12,
                offset: Offset(0, _hovered && widget.enabled ? 8 : 4),
                spreadRadius: _hovered && widget.enabled ? 2 : 0,
              ),
            ],
          ),
          transform: (_hovered && widget.enabled)
            ? Matrix4.translationValues(0, -3, 0)
            : Matrix4.identity(),
          child: Center(
            child: AnimatedOpacity(
              opacity: widget.enabled ? 1.0 : 0.65,
              duration: const Duration(milliseconds: 200),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null && ScreenBreakpoints.isDesktop(context)) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
