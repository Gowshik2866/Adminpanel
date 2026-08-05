import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/providers/auth_provider.dart';

class TopHeader extends ConsumerWidget {
  const TopHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'EnggStaff',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'College Portal',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Contextual Notification Indicator
          PopupMenuButton<dynamic>(
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme
                          .warning, // Semantic Warning for unread alerts
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                enabled: false,
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                child: ListTile(
                  leading: Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.warning,
                  ),
                  title: Text('Prof. Martin is late'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                child: ListTile(
                  leading: Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.success,
                  ),
                  title: Text('Weekly report generated'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 28,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user?.name ?? 'Guest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    user != null ? 'Super Admin' : 'Login Required',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  user?.name.substring(0, 2).toUpperCase() ?? 'G',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
