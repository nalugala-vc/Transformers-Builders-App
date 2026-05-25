import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/member_shell_providers.dart';
import '../../domain/models/member_tab.dart';
import '../widgets/home/add_contribution_sheet.dart';
import '../widgets/home/set_contribution_goal_sheet.dart';
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

  void _onDrawerItem(MemberDrawerItemId item) {
    switch (item) {
      case MemberDrawerItemId.dashboard:
        ref.read(memberTabProvider.notifier).state = MemberTab.home;
      case MemberDrawerItemId.contribute:
        openContributeFlow(context, ref);
      case MemberDrawerItemId.myProgress:
        ref.read(memberTabProvider.notifier).state = MemberTab.progress;
      case MemberDrawerItemId.churchProgress:
        ref.read(memberTabProvider.notifier).state = MemberTab.progress;
      case MemberDrawerItemId.editTarget:
        showSetContributionGoalSheet(context);
      case MemberDrawerItemId.contributionHistory:
        context.push(AppRoutePaths.memberContributions);
      case MemberDrawerItemId.notifications:
        context.push(AppRoutePaths.memberNotifications);
      case MemberDrawerItemId.upcomingEvents:
      case MemberDrawerItemId.share:
      case MemberDrawerItemId.settings:
        showAppInfoToast(context, context.l10n.comingSoon(item.label(context)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(memberTabProvider);
    final localeCode = ref.watch(localeProvider).languageCode;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: MemberAppDrawer(
        onLogout: () => ref.read(authRepositoryProvider).signOut(),
        onNavigatePlaceholder: _onDrawerItem,
      ),
      body: IndexedStack(
        index: tab.index,
        children: [
          MemberHomeTabScreen(
            key: ValueKey('home-$localeCode'),
            onOpenDrawer: _openDrawer,
          ),
          MemberProgressTabScreen(key: ValueKey('progress-$localeCode')),
          MemberProfileTabScreen(key: ValueKey('profile-$localeCode')),
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
