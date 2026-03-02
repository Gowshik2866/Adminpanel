import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/animated_hover_card.dart';

class DepartmentSummaryCard extends StatelessWidget {
  final String dept;
  final double percent;

  const DepartmentSummaryCard({
    super.key,
    required this.dept,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    // Strict Semantic UI Color Rules
    Color indicatorColor = percent >= 0.90
        ? AppTheme.success
        : percent >= 0.80
        ? AppTheme.warning
        : AppTheme.danger;

    return AnimatedHoverCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dept,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: indicatorColor,
                ),
              ),
              SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  value: percent,
                  backgroundColor: AppTheme.border,
                  color: indicatorColor,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
