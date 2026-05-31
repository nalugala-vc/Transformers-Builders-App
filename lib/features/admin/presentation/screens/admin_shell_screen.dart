import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../member/presentation/screens/member_profile_tab_screen.dart';
import '../../domain/models/admin_tab.dart';
import '../providers/admin_tab_provider.dart';
import '../widgets/admin_bottom_nav_bar.dart';
import 'admin_dashboard_tab_screen.dart';
import 'admin_management_tab_screen.dart';
import 'admin_updates_tab_screen.dart';

class AdminShellScreen extends ConsumerWidget {
  const AdminShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(adminTabProvider);
    final localeCode = ref.watch(localeProvider).languageCode;

    return Scaffold(
      backgroundColor: AppPallete.scaffoldBg,
      body: IndexedStack(
        index: tab.index,
        children: [
          AdminDashboardTabScreen(key: ValueKey('admin-dashboard-$localeCode')),
          AdminManagementTabScreen(key: ValueKey('admin-management-$localeCode')),
          AdminUpdatesTabScreen(key: ValueKey('admin-updates-$localeCode')),
          MemberProfileTabScreen(key: ValueKey('admin-profile-$localeCode')),
        ],
      ),
      bottomNavigationBar: AdminBottomNavBar(
        currentTab: tab,
        onTabSelected: (selected) =>
            ref.read(adminTabProvider.notifier).state = selected,
      ),
      floatingActionButton: tab == AdminTab.updates
          ? const AdminPublishUpdateFab()
          : null,
    );
  }
}
