import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/section_title.dart';
import 'package:sample_app/providers/auth_provider.dart';
import 'package:sample_app/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool emailNotifs = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final isDarkMode = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Portal Settings',
              subtitle: 'Manage your preferences and security configurations.',
            ),
            SizedBox(height: 32),

            // Profile Area
            if (user != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      user.name.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 40),
            ],

            // Preferences Group
            Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    leading: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: child.key == const ValueKey('icon1')
                            ? Tween<double>(begin: 1, end: 0.75).animate(anim)
                            : Tween<double>(begin: 0.75, end: 1).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Icon(
                        isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        key: ValueKey(isDarkMode ? 'icon1' : 'icon2'),
                        color: isDarkMode
                            ? colorScheme.primary
                            : AppTheme.warning,
                      ),
                    ),
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      'Toggle dark theme appearance',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    trailing: Switch.adaptive(
                      value: isDarkMode,
                      onChanged: (val) {
                        ref.read(themeProvider.notifier).toggleTheme(val);
                      },
                      activeColor: colorScheme.primary,
                    ),
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    leading: Icon(
                      Icons.email_outlined,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      'Email Notifications',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      'Receive daily attendance digests',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    trailing: Switch.adaptive(
                      value: emailNotifs,
                      onChanged: (val) => setState(() => emailNotifs = val),
                      activeColor: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Account & Security Group
            Text(
              'ACCOUNT & SECURITY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    leading: Icon(
                      Icons.lock_outline,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      'Change Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    leading: Icon(
                      Icons.security,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      'Two-Factor Authentication',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
