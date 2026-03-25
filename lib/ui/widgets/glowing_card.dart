import 'package:flutter/material.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// A card that glows and scales slightly on hover.
class GlowingCard extends StatefulWidget {
  final Widget child;
  final Color? color;
  final double borderRadius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double glowIntensity;

  const GlowingCard({
    super.key,
    required this.child,
    this.color,
    this.borderRadius = 24.0,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.glowIntensity = 0.5,
  });

  @override
  State<GlowingCard> createState() => _GlowingCardState();
}

class _GlowingCardState extends State<GlowingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.color ?? AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppMotion.standard,
          curve: AppMotion.hover,
          transform: Matrix4.identity()
            ..scaleByDouble(
              _isHovered ? 1.02 : 1.0,
              _isHovered ? 1.02 : 1.0,
              1.0,
              1.0,
            ),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: cardColor.withValues(alpha: _isHovered ? 0.6 : 0.2),
              width: _isHovered ? 2.5 : 1.5,
            ),
            boxShadow: _isHovered 
                ? AppShadows.glow(cardColor, intensity: widget.glowIntensity)
                : AppShadows.sm(cardColor),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
