import 'package:flutter/material.dart';
import 'package:sample_app/theme/app_theme.dart';
import 'package:sample_app/widgets/section_title.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool emailNotifs = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Portal Settings',
              subtitle: 'Manage your preferences and security configurations.',
            ),
            const SizedBox(height: 40),

            // Preferences Group
            const Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
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
                        color: isDarkMode ? AppTheme.primary : AppTheme.warning,
                      ),
                    ),
                    title: const Text(
                      'Dark Mode',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Toggle dark theme appearance'),
                    trailing: Switch.adaptive(
                      value: isDarkMode,
                      onChanged: (val) => setState(() => isDarkMode = val),
                      // ignore: deprecated_member_use
                      activeColor: AppTheme.primary,
                    ),
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    leading: const Icon(
                      Icons.email_outlined,
                      color: AppTheme.primary,
                    ),
                    title: const Text(
                      'Email Notifications',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Receive daily attendance digests'),
                    trailing: Switch.adaptive(
                      value: emailNotifs,
                      onChanged: (val) => setState(() => emailNotifs = val),
                      // ignore: deprecated_member_use
                      activeColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Account & Security Group
            const Text(
              'ACCOUNT & SECURITY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    leading: const Icon(
                      Icons.lock_outline,
                      color: AppTheme.textSecondary,
                    ),
                    title: const Text(
                      'Change Password',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    leading: const Icon(
                      Icons.security,
                      color: AppTheme.textSecondary,
                    ),
                    title: const Text(
                      'Two-Factor Authentication',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textMuted,
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
