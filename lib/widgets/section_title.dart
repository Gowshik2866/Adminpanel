import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title, subtitle;
  const SectionTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
      ),
    ],
  );
}
