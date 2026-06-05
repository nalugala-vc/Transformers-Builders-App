import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../member/presentation/screens/member_profile_tab_screen.dart';
import '../../domain/models/admin_shell_view.dart';
import '../providers/admin_shell_providers.dart';
import '../widgets/admin_app_drawer.dart';
import '../widgets/admin_bottom_nav_bar.dart';
import '../widgets/admin_shell_menu_bar.dart';
import 'admin_dashboard_tab_screen.dart';
import 'admin_management_tab_screen.dart';
import 'admin_personal_contributions_screen.dart';
import 'admin_updates_tab_screen.dart';

class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _onSidebarAction(AdminSidebarAction action) {
    handleAdminSidebarAction(context, ref, action);
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(adminShellViewProvider);
    final localeCode = ref.watch(localeProvider).languageCode;
    final bottomTab = view.bottomNavTab;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppPallete.scaffoldBg,
      drawer: AdminAppDrawer(onAction: _onSidebarAction),
      body: IndexedStack(
        index: view.index,
        children: [
          AdminDashboardTabScreen(
            key: ValueKey('admin-dashboard-$localeCode'),
            onOpenDrawer: _openDrawer,
          ),
          AdminManagementTabScreen(
            key: ValueKey('admin-management-$localeCode'),
            onOpenDrawer: _openDrawer,
          ),
          AdminUpdatesTabScreen(
            key: ValueKey('admin-updates-$localeCode'),
            onOpenDrawer: _openDrawer,
          ),
          AdminProfileTabScreen(
            key: ValueKey('admin-profile-$localeCode'),
            onOpenDrawer: _openDrawer,
          ),
          AdminPersonalContributionsScreen(
            key: ValueKey('admin-my-giving-$localeCode'),
            onOpenDrawer: _openDrawer,
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavBar(
        currentTab: bottomTab,
        onTabSelected: (selected) {
          ref.read(adminShellViewProvider.notifier).state =
              AdminShellView.fromTab(selected);
        },
      ),
      floatingActionButton: view == AdminShellView.updates
          ? const AdminPublishUpdateFab()
          : null,
    );
  }
}

/// Profile tab with menu button above the member profile content.
class AdminProfileTabScreen extends StatelessWidget {
  const AdminProfileTabScreen({
    super.key,
    required this.onOpenDrawer,
  });

  final VoidCallback onOpenDrawer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminShellMenuBar(
          onOpenDrawer: onOpenDrawer,
          title: context.l10n.adminTabProfile,
        ),
        const Expanded(
          child: MemberProfileTabScreen(includeTopSafeArea: false),
        ),
      ],
    );
  }
}
