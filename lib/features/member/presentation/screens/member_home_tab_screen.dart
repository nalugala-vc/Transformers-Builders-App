import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../providers/member_home_provider.dart';
import '../providers/member_shell_providers.dart';
import '../widgets/home/activity_detail_sheet.dart';
import '../widgets/home/member_greeting_bar.dart';
import '../widgets/home/member_progress_card.dart';
import '../widgets/home/member_recent_activity_card.dart';
import '../widgets/home/pending_admin_banner.dart';
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

    return ColoredBox(
      color: AppPallete.scaffoldBg,
      child: homeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load home')),
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
                unreadNotificationCount: state.unreadNotificationCount,
                onMenuTap: onOpenDrawer,
                onNotificationsTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon')),
                  );
                },
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
                      if (state.hasContributionGoal)
                        MemberProgressCard(
                          state: state,
                          onContribute: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Contribution page coming soon')),
                            );
                          },
                          onShare: () => showShareFundraiserSheet(context),
                        )
                      else
                        MemberSetGoalCard(
                          onSetGoal: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Set goal flow coming soon')),
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      MemberRecentActivityCard(
                        activities: state.recentActivities,
                        onActivityTap: (activity) =>
                            showActivityDetailSheet(context, activity),
                      ),
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
