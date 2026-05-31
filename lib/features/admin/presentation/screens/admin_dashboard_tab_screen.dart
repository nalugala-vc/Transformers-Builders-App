import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../../../member/presentation/utils/member_formatters.dart';
import '../../../member/presentation/widgets/home/activity_detail_sheet.dart';
import '../../domain/models/admin_dashboard_data.dart';
import '../../domain/models/admin_recent_activity.dart';
import '../providers/admin_dashboard_providers.dart';
import '../widgets/admin_contribution_progress_section.dart';
import '../widgets/admin_greeting_bar.dart';
import '../widgets/admin_kpi_card.dart';
import '../widgets/admin_needs_attention_card.dart';
import '../widgets/admin_recent_activity_card.dart';

class AdminDashboardTabScreen extends ConsumerWidget {
  const AdminDashboardTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(adminDashboardProvider);

    return ColoredBox(
      color: AppPallete.scaffoldBg,
      child: dataAsync.when(
        loading: () => const _LoadingState(),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminDashboardProvider),
        ),
        data: (data) => _DashboardBody(data: data),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final firstName = _firstNameOf(FirebaseAuth.instance.currentUser);

    return Column(
      children: [
        AdminGreetingBar(
          firstName: firstName,
          title: l10n.adminDashboardSubtitle,
          onNotificationsTap: () => showAppInfoToast(
            context,
            l10n.comingSoon(l10n.notifications),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppPallete.tcBlueBright,
            onRefresh: () => refreshAdminDashboard(ref),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: 12,
                bottom: 32 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                _KpiCarousel(data: data),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.responsivePagePadding,
                    24,
                    context.responsivePagePadding,
                    0,
                  ),
                  child: AdminContributionProgressSection(
                    data: data.churchProgress,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.responsivePagePadding,
                    24,
                    context.responsivePagePadding,
                    0,
                  ),
                  child: AdminRecentActivityCard(
                    activities: data.recentActivity,
                    onActivityTap: (activity) =>
                        _onActivityTap(context, ref, activity),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.responsivePagePadding,
                    24,
                    context.responsivePagePadding,
                    0,
                  ),
                  child: AdminNeedsAttentionCard(
                    items: data.attentionItems,
                    onItemTap: (item) {
                      showAppInfoToast(
                        context,
                        l10n.comingSoon(item.title),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onActivityTap(
    BuildContext context,
    WidgetRef ref,
    AdminRecentActivity activity,
  ) async {
    final l10n = context.l10n;
    if (activity.type != AdminRecentActivityType.memberContribution) {
      showAppInfoToast(context, l10n.comingSoon(activity.title));
      return;
    }

    final memberUid = activity.memberUid;
    final contributionId = activity.contributionId;
    if (memberUid == null || contributionId == null) {
      showAppInfoToast(context, l10n.errorSomethingWrong);
      return;
    }

    try {
      final repo = ref.read(adminDashboardRepositoryProvider);
      final detail = await repo
          .loadContributionDetail(uid: memberUid, contributionId: contributionId);
      if (!context.mounted) return;
      if (detail == null) {
        showAppInfoToast(context, l10n.errorSomethingWrong);
        return;
      }
      await showActivityDetailSheet(context, detail);
    } catch (_) {
      if (!context.mounted) return;
      showAppInfoToast(context, l10n.errorSomethingWrong);
    }
  }
}

class _KpiCarousel extends StatelessWidget {
  const _KpiCarousel({required this.data});

  final AdminDashboardData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final media = MediaQuery.sizeOf(context);
    final padding = context.responsivePagePadding;
    final cardWidth = (media.width - padding * 2 - 12).clamp(220.0, 340.0);

    return SizedBox(
      height: 188,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: padding),
        children: [
          SizedBox(
            width: cardWidth,
            child: AdminKpiCard(
              variant: AdminKpiVariant.raised,
              icon: Icons.payments_outlined,
              label: l10n.adminKpiTotalRaised,
              heroValue: formatKes(data.totalRaisedKes),
              deltaText: _formatKesDelta(
                data.totalRaisedDeltaKes,
                data.totalRaisedDeltaPercent,
                l10n.adminKpiDeltaThisWeek,
              ),
              deltaPositive: data.totalRaisedDeltaKes >= 0,
              onTap: () => showAppInfoToast(
                context,
                l10n.comingSoon(l10n.adminAnalyticsRaised),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: cardWidth,
            child: AdminKpiCard(
              variant: AdminKpiVariant.members,
              icon: Icons.groups_outlined,
              label: l10n.adminKpiActiveMembers,
              heroValue: data.activeMembers.toString(),
              deltaText: l10n.adminKpiNewMembersThisWeek(
                data.newMembersThisWeek,
              ),
              deltaPositive: data.newMembersThisWeek >= 0,
              onTap: () => showAppInfoToast(
                context,
                l10n.comingSoon(l10n.adminAnalyticsMembers),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatKesDelta(int kes, double percent, String suffix) {
    final sign = kes >= 0 ? '+' : '-';
    final amount = formatKes(kes.abs());
    final pct = percent.abs().toStringAsFixed(1);
    return '$sign$amount ($pct%) $suffix';
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(context.responsivePagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.adminDashboardLoadError, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppPallete.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _firstNameOf(User? user) {
  final displayName = user?.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) {
    return displayName.split(RegExp(r'\s+')).first;
  }
  final email = user?.email;
  if (email != null && email.contains('@')) {
    final handle = email.split('@').first;
    if (handle.isEmpty) return 'Admin';
    return handle[0].toUpperCase() + handle.substring(1);
  }
  return 'Admin';
}
