import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/navigation_item_data.dart';

class NavigationTile extends StatefulWidget {
  final NavigationItemData item;
  final bool selected;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const NavigationTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  State<NavigationTile> createState() => NavigationTileState();
}

class NavigationTileState extends State<NavigationTile> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final tc =
        widget.textColor ??
        (widget.selected ? AppTheme.primary : AppTheme.textSecondary);
    final ic =
        widget.iconColor ??
        (widget.selected ? AppTheme.primary : AppTheme.textMuted);

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.selected
                ? AppTheme.primaryLight
                : (hover ? AppTheme.background : Colors.transparent),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, size: 20, color: ic),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    color: tc,
                    fontSize: 14,
                    fontWeight: widget.selected
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
              if (widget.selected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
