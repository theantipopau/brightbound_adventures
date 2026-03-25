import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/data/zone_guardian_data.dart';

/// A banner that appears at the top of a zone detail screen showing the
/// guardian NPC with their quest hook and name. Tapping it expands/collapses
/// the full quest hook text.
class ZoneGuardianBanner extends StatefulWidget {
  final String zoneId;
  final Color themeColor;

  const ZoneGuardianBanner({
    super.key,
    required this.zoneId,
    required this.themeColor,
  });

  @override
  State<ZoneGuardianBanner> createState() => _ZoneGuardianBannerState();
}

class _ZoneGuardianBannerState extends State<ZoneGuardianBanner>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guardian = guardianForZone(widget.zoneId);
    if (guardian == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeIn,
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.themeColor.withValues(alpha: 0.15),
                widget.themeColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.themeColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guardian emoji avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.themeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.themeColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    guardian.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          guardian.name,
                          style: TextStyle(
                            color: widget.themeColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            guardian.title,
                            style: TextStyle(
                              color: widget.themeColor.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AnimatedCrossFade(
                      firstChild: Text(
                        guardian.questHook,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF444444),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: Text(
                        guardian.questHook,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF444444),
                          height: 1.4,
                        ),
                      ),
                      crossFadeState: _expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 16,
                          color: widget.themeColor.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
