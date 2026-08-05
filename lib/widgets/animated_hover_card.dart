import 'package:flutter/material.dart';

const _defaultPadding = EdgeInsets.all(16);

class AnimatedHoverCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AnimatedHoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = _defaultPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
