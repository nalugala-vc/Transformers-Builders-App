import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../member/presentation/widgets/home/add_contribution_sheet.dart';
import '../../../member/presentation/widgets/home/set_contribution_goal_sheet.dart';
import '../../domain/models/admin_shell_view.dart';
import '../providers/admin_shell_providers.dart';

enum AdminSidebarAction {
  contribute,
  editTarget,
  contributionHistory,
}

/// Slide-out navigation drawer — fully hidden until opened from the menu button.
class AdminAppDrawer extends ConsumerWidget {
  const AdminAppDrawer({
    super.key,
    required this.onAction,
  });

  final ValueChanged<AdminSidebarAction> onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final view = ref.watch(adminShellViewProvider);

    return Drawer(
      backgroundColor: AppPallete.tcWhite,
      width: MediaQuery.sizeOf(context).width * 0.82,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chapelName,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppPallete.tcBlueBright,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.adminBadge,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppPallete.tcBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppPallete.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _SectionLabel(label: l10n.adminSidebarChurch),
                  _DrawerTile(
                    icon: Icons.dashboard_rounded,
                    label: l10n.adminTabDashboard,
                    selected: view == AdminShellView.dashboard,
                    onTap: () => adminDrawerGoTo(context, ref, AdminShellView.dashboard),
                  ),
                  _DrawerTile(
                    icon: Icons.groups_rounded,
                    label: l10n.adminTabManagement,
                    selected: view == AdminShellView.management,
                    onTap: () => adminDrawerGoTo(context, ref, AdminShellView.management),
                  ),
                  _DrawerTile(
                    icon: Icons.campaign_rounded,
                    label: l10n.adminTabUpdates,
                    selected: view == AdminShellView.updates,
                    onTap: () => adminDrawerGoTo(context, ref, AdminShellView.updates),
                  ),
                  const SizedBox(height: 8),
                  _SectionLabel(label: l10n.adminSidebarPersonal),
                  _DrawerTile(
                    icon: Icons.volunteer_activism_rounded,
                    label: l10n.adminMyContributions,
                    selected: view == AdminShellView.myContributions,
                    onTap: () =>
                        adminDrawerGoTo(context, ref, AdminShellView.myContributions),
                  ),
                  _DrawerTile(
                    icon: Icons.add_circle_rounded,
                    label: l10n.contribute,
                    onTap: () {
                      Navigator.of(context).pop();
                      onAction(AdminSidebarAction.contribute);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.flag_rounded,
                    label: l10n.drawerEditTarget,
                    onTap: () {
                      Navigator.of(context).pop();
                      onAction(AdminSidebarAction.editTarget);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.history_rounded,
                    label: l10n.drawerContributionHistory,
                    onTap: () {
                      Navigator.of(context).pop();
                      onAction(AdminSidebarAction.contributionHistory);
                    },
                  ),
                  const SizedBox(height: 8),
                  _SectionLabel(label: l10n.adminSidebarAccount),
                  _DrawerTile(
                    icon: Icons.person_rounded,
                    label: l10n.adminTabProfile,
                    selected: view == AdminShellView.profile,
                    onTap: () => adminDrawerGoTo(context, ref, AdminShellView.profile),
                  ),
                  _DrawerTile(
                    icon: Icons.notifications_rounded,
                    label: l10n.notifications,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutePaths.memberNotifications);
                    },
                  ),
                  const Divider(height: 24, indent: 20, endIndent: 20),
                  _DrawerTile(
                    icon: Icons.logout_rounded,
                    label: l10n.logOut,
                    iconColor: AppPallete.tcRed,
                    labelColor: AppPallete.tcRed,
                    onTap: () async {
                      Navigator.of(context).pop();
                      await ref.read(authRepositoryProvider).signOut();
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

void adminDrawerGoTo(BuildContext context, WidgetRef ref, AdminShellView view) {
  Navigator.of(context).pop();
  final location = GoRouter.of(context).state.matchedLocation;
  if (location != AppRoutePaths.adminHome) {
    context.go(AppRoutePaths.adminHome);
  }
  ref.read(adminShellViewProvider.notifier).state = view;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppPallete.textMuted,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppPallete.tcBlueBright;

    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: labelColor ??
              (selected ? AppPallete.textPrimary : AppPallete.textSecondary),
        ),
      ),
      selected: selected,
      selectedTileColor: AppPallete.tcBlueBright.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: onTap,
    );
  }
}

void handleAdminSidebarAction(
  BuildContext context,
  WidgetRef ref,
  AdminSidebarAction action,
) {
  switch (action) {
    case AdminSidebarAction.contribute:
      openContributeFlow(context, ref);
    case AdminSidebarAction.editTarget:
      showSetContributionGoalSheet(context);
    case AdminSidebarAction.contributionHistory:
      context.push(AppRoutePaths.memberContributions);
  }
}
