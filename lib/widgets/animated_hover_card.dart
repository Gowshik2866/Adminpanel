import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';

class AnimatedHoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AnimatedHoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<AnimatedHoverCard> createState() => _AnimatedHoverCardState();
}

class _AnimatedHoverCardState extends State<AnimatedHoverCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, isHovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered
                  ? AppTheme.primary.withValues(alpha: 0.3)
                  : AppTheme.border,
              width: isHovered ? 1.5 : 1.0,
            ),
            boxShadow: isHovered
                ? AppTheme.cardShadow
                : [
                    BoxShadow(
                      color: AppTheme.shadowColor.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}
