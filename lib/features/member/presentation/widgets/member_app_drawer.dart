import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/utils/theme/app_pallete.dart';

class MemberDrawerItem {
  const MemberDrawerItem({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
}

class MemberAppDrawer extends StatelessWidget {
  const MemberAppDrawer({
    super.key,
    required this.onLogout,
    this.onNavigatePlaceholder,
  });

  final Future<void> Function() onLogout;
  final void Function(String label)? onNavigatePlaceholder;

  static const _items = [
    MemberDrawerItem(label: 'Dashboard', icon: Icons.dashboard_rounded),
    MemberDrawerItem(label: 'Contribute', icon: Icons.volunteer_activism_rounded),
    MemberDrawerItem(label: 'My Progress', icon: Icons.trending_up_rounded),
    MemberDrawerItem(label: 'Church Progress', icon: Icons.church_rounded),
    MemberDrawerItem(label: 'Edit Target', icon: Icons.flag_rounded),
    MemberDrawerItem(label: 'Contribution History', icon: Icons.history_rounded),
    MemberDrawerItem(label: 'Upcoming Events', icon: Icons.event_rounded),
    MemberDrawerItem(label: 'Share', icon: Icons.share_rounded),
    MemberDrawerItem(label: 'Notifications', icon: Icons.notifications_rounded),
    MemberDrawerItem(label: 'Settings', icon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppPallete.tcWhite,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Transformers Chapel',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppPallete.tcBlueBright,
                ),
              ),
            ),
            const Divider(height: 1, color: AppPallete.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final item in _items)
                    ListTile(
                      leading: Icon(item.icon, color: AppPallete.tcBlueBright, size: 22),
                      title: Text(
                        item.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppPallete.textPrimary,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigatePlaceholder?.call(item.label);
                      },
                    ),
                  const Divider(height: 1, color: AppPallete.border),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppPallete.tcRed, size: 22),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppPallete.tcRed,
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await onLogout();
                      if (context.mounted) {
                        context.go(AppRoutePaths.login);
                      }
                    },
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
