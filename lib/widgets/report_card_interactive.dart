import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/animated_hover_card.dart';

class ReportCardInteractive extends StatefulWidget {
  final Map<String, dynamic> item;
  const ReportCardInteractive({super.key, required this.item});

  @override
  State<ReportCardInteractive> createState() => _ReportCardInteractiveState();
}

class _ReportCardInteractiveState extends State<ReportCardInteractive> {
  bool isLoading = false;

  void handleGenerate() async {
    setState(() => isLoading = true);
    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // Simulate generation
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedHoverCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(widget.item['icon'], color: widget.item['color'], size: 36),
          const Spacer(),
          Text(
            widget.item['title'],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.item['sub'],
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: isLoading ? null : handleGenerate,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.item['color'].withValues(alpha: 0.1),
                foregroundColor: widget.item['color'],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.item['color'],
                      ),
                    )
                  : const Text(
                      'Generate Report',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
