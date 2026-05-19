import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/member_shell_providers.dart';
import '../widgets/member_app_drawer.dart';
import '../widgets/member_bottom_nav_bar.dart';
import 'member_home_tab_screen.dart';
import 'member_profile_tab_screen.dart';
import 'member_progress_tab_screen.dart';

class MemberShellScreen extends ConsumerStatefulWidget {
  const MemberShellScreen({super.key});

  @override
  ConsumerState<MemberShellScreen> createState() => _MemberShellScreenState();
}

class _MemberShellScreenState extends ConsumerState<MemberShellScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _onDrawerPlaceholder(String label) {
    if (label == 'Notifications') {
      context.push(AppRoutePaths.memberNotifications);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(memberTabProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: MemberAppDrawer(
        onLogout: () => ref.read(authRepositoryProvider).signOut(),
        onNavigatePlaceholder: _onDrawerPlaceholder,
      ),
      body: IndexedStack(
        index: tab.index,
        children: [
          MemberHomeTabScreen(onOpenDrawer: _openDrawer),
          const MemberProgressTabScreen(),
          const MemberProfileTabScreen(),
        ],
      ),
      bottomNavigationBar: MemberBottomNavBar(
        currentTab: tab,
        onTabSelected: (selected) =>
            ref.read(memberTabProvider.notifier).state = selected,
      ),
    );
  }
}
