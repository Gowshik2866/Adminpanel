import 'package:flutter/material.dart';
import 'package:sample_app/widgets/navigation_item_data.dart';

class NavigationTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tc = textColor ?? (selected ? colorScheme.primary : colorScheme.onSurfaceVariant);
    final ic = iconColor ?? (selected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.5));

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: ListTile(
        onTap: onTap,
        selected: selected,
        selectedTileColor: colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: Icon(item.icon, color: ic, size: 20),
        title: Text(
          item.label,
          style: TextStyle(
            color: tc,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: selected
            ? Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}
