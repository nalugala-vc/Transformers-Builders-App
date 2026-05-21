import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../providers/member_home_provider.dart';
import '../providers/member_notifications_provider.dart';
import '../providers/member_shell_providers.dart';
import '../widgets/home/activity_detail_sheet.dart';
import '../widgets/home/member_greeting_bar.dart';
import '../widgets/home/member_progress_card.dart';
import '../widgets/home/member_start_contributing_card.dart';
import '../widgets/home/member_recent_activity_card.dart';
import '../widgets/home/pending_admin_banner.dart';
import '../widgets/home/set_contribution_goal_sheet.dart';
import '../widgets/home/share_fundraiser_sheet.dart';

class MemberHomeTabScreen extends ConsumerWidget {
  const MemberHomeTabScreen({
    super.key,
    required this.onOpenDrawer,
  });

  final VoidCallback onOpenDrawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(memberHomeUiProvider);
    final bannerDismissed = ref.watch(pendingAdminBannerDismissedProvider);
    final unreadCount = ref.watch(memberUnreadNotificationsCountProvider);

    return ColoredBox(
      color: AppPallete.scaffoldBg,
      child: homeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(context.responsivePagePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Could not load home',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppPallete.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(memberHomeUiProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (state) {
          final showBanner = state.showPendingAdminBanner && !bannerDismissed;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showBanner)
                PendingAdminBanner(
                  onDismiss: () =>
                      ref.read(pendingAdminBannerDismissedProvider.notifier).state = true,
                ),
              MemberGreetingBar(
                firstName: state.firstName,
                unreadNotificationCount: unreadCount,
                onMenuTap: onOpenDrawer,
                onNotificationsTap: () =>
                    context.push(AppRoutePaths.memberNotifications),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    context.responsivePagePadding,
                    20,
                    context.responsivePagePadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.hasContributionGoal && state.raisedKes > 0)
                        MemberProgressCard(
                          state: state,
                          onContribute: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Contribution page coming soon')),
                            );
                          },
                          onShare: () => showShareFundraiserSheet(context),
                        )
                      else if (state.hasContributionGoal)
                        MemberStartContributingCard(
                          targetKes: state.targetKes,
                          onStartContributing: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Contribution page coming soon')),
                            );
                          },
                          onShare: () => showShareFundraiserSheet(context),
                        )
                      else
                        MemberSetGoalCard(
                          onSetGoal: () => showSetContributionGoalSheet(context),
                        ),
                      if (state.recentActivities.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        MemberRecentActivityCard(
                          activities: state.recentActivities,
                          onActivityTap: (activity) =>
                              showActivityDetailSheet(context, activity),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
