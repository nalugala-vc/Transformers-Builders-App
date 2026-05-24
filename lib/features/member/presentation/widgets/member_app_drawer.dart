import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';

enum MemberDrawerItemId {
  dashboard,
  contribute,
  myProgress,
  churchProgress,
  editTarget,
  contributionHistory,
  upcomingEvents,
  share,
  notifications,
  settings,
}

extension MemberDrawerItemIdX on MemberDrawerItemId {
  String label(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      MemberDrawerItemId.dashboard => l10n.drawerDashboard,
      MemberDrawerItemId.contribute => l10n.drawerContribute,
      MemberDrawerItemId.myProgress => l10n.drawerMyProgress,
      MemberDrawerItemId.churchProgress => l10n.drawerChurchProgress,
      MemberDrawerItemId.editTarget => l10n.drawerEditTarget,
      MemberDrawerItemId.contributionHistory => l10n.drawerContributionHistory,
      MemberDrawerItemId.upcomingEvents => l10n.drawerUpcomingEvents,
      MemberDrawerItemId.share => l10n.drawerShare,
      MemberDrawerItemId.notifications => l10n.drawerNotifications,
      MemberDrawerItemId.settings => l10n.drawerSettings,
    };
  }

  IconData get icon => switch (this) {
        MemberDrawerItemId.dashboard => Icons.dashboard_rounded,
        MemberDrawerItemId.contribute => Icons.volunteer_activism_rounded,
        MemberDrawerItemId.myProgress => Icons.trending_up_rounded,
        MemberDrawerItemId.churchProgress => Icons.church_rounded,
        MemberDrawerItemId.editTarget => Icons.flag_rounded,
        MemberDrawerItemId.contributionHistory => Icons.history_rounded,
        MemberDrawerItemId.upcomingEvents => Icons.event_rounded,
        MemberDrawerItemId.share => Icons.share_rounded,
        MemberDrawerItemId.notifications => Icons.notifications_rounded,
        MemberDrawerItemId.settings => Icons.settings_rounded,
      };
}

class MemberAppDrawer extends StatelessWidget {
  const MemberAppDrawer({
    super.key,
    required this.onLogout,
    this.onNavigatePlaceholder,
  });

  final Future<void> Function() onLogout;
  final void Function(MemberDrawerItemId item)? onNavigatePlaceholder;

  static const _items = MemberDrawerItemId.values;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Drawer(
      backgroundColor: AppPallete.tcWhite,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                l10n.chapelName,
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
                        item.label(context),
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppPallete.textPrimary,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigatePlaceholder?.call(item);
                      },
                    ),
                  const Divider(height: 1, color: AppPallete.border),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppPallete.tcRed, size: 22),
                    title: Text(
                      l10n.drawerLogout,
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
