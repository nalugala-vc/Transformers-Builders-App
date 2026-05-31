import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../../../../core/utils/user_initials.dart';
import '../../domain/models/admin_member_activity_event.dart';
import '../../domain/models/admin_member_detail.dart';
import '../providers/admin_member_providers.dart';
import '../widgets/admin_blue_title_bar.dart';
import '../widgets/admin_contribution_detail_sheet.dart';
import '../widgets/admin_goal_history_sheet.dart';
import '../widgets/admin_remove_member_dialog.dart';
import '../../../member/domain/models/contribution_activity.dart';
import '../../../member/presentation/utils/member_formatters.dart';

class AdminMemberDetailScreen extends ConsumerWidget {
  const AdminMemberDetailScreen({super.key, required this.memberUid});

  final String memberUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(adminMemberDetailProvider(memberUid));
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppPallete.scaffoldBg,
      body: detailAsync.when(
        loading: () => Column(
          children: [
            AdminBlueTitleBar(
              title: l10n.adminMemberProfile,
              onBack: () => context.pop(),
            ),
            const Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
        error: (_, __) => Column(
          children: [
            AdminBlueTitleBar(
              title: l10n.adminMemberProfile,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(context.responsivePagePadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.adminMembersLoadError, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => refreshAdminMemberDetail(ref, memberUid),
                        child: Text(l10n.tryAgain),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        data: (detail) => _AdminMemberDetailBody(detail: detail),
      ),
    );
  }
}

class _AdminMemberDetailBody extends ConsumerWidget {
  const _AdminMemberDetailBody({required this.detail});

  final AdminMemberDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = detail.user;

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminBlueTitleBar(
            title: l10n.adminMemberProfile,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(context.responsivePagePadding),
                    child: _MemberHeader(detail: detail),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      labelColor: AppPallete.tcBlueLight,
                      unselectedLabelColor: AppPallete.textMuted,
                      indicatorColor: AppPallete.tcBlueLight,
                      labelStyle: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      tabs: [
                        Tab(text: l10n.adminMemberTabOverview),
                        Tab(text: l10n.adminMemberTabContributions),
                        Tab(text: l10n.adminMemberTabActivity),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  _OverviewTab(detail: detail),
                  _ContributionsTab(contributions: detail.contributions),
                  _ActivityTab(events: detail.activityEvents),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.responsivePagePadding,
              0,
              context.responsivePagePadding,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: OutlinedButton.icon(
              onPressed: () => _confirmRemove(context, ref, user.fullName),
              icon: const Icon(Icons.person_remove_outlined, color: AppPallete.tcRed),
              label: Text(l10n.adminMemberActionRemove),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppPallete.tcRed,
                side: const BorderSide(color: AppPallete.tcRed),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    String memberName,
  ) async {
    final confirmed = await showAdminRemoveMemberDialog(
      context,
      memberName: memberName,
    );
    if (confirmed != true || !context.mounted) return;

    final err = await deactivateAdminMember(ref, uid: detail.user.uid);
    if (!context.mounted) return;
    if (err != null) {
      showAppErrorToast(context, context.l10n.adminRemoveMemberFailed);
    } else {
      showAppSuccessToast(
        context,
        context.l10n.adminMemberRemoved(memberName),
      );
      context.pop();
    }
  }
}

class _MemberHeader extends StatelessWidget {
  const _MemberHeader({required this.detail});

  final AdminMemberDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = detail.user;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPallete.tcWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPallete.border),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppPallete.tcBlueBright, AppPallete.tcBlueBrightDark],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.center,
            child: Text(
              initialsForName(user.fullName),
              style: GoogleFonts.dmSans(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppPallete.tcWhite,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.fullName,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          if (user.email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(user.email, style: GoogleFonts.dmSans(color: AppPallete.textMuted)),
          ],
          if (user.phoneE164 != null && user.phoneE164!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              user.phoneE164!,
              style: GoogleFonts.dmSans(color: AppPallete.textSecondary, fontSize: 13),
            ),
          ],
          if (user.createdAt case final DateTime joined) ...[
            const SizedBox(height: 8),
            Text(
              l10n.adminMemberJoined(formatDisplayDate(joined)),
              style: GoogleFonts.dmSans(fontSize: 13, color: AppPallete.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.detail});

  final AdminMemberDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = detail.user;

    return ListView(
      padding: EdgeInsets.all(context.responsivePagePadding),
      children: [
        _InfoCard(
          title: l10n.adminMemberTabOverview,
          rows: [
            _InfoRow(label: l10n.email, value: user.email),
            if (user.phoneE164 != null && user.phoneE164!.isNotEmpty)
              _InfoRow(label: l10n.phone, value: user.phoneE164!),
            _InfoRow(
              label: l10n.contributionTarget,
              value: formatKes(detail.targetKes),
              trailing: detail.goalLowerCount > 1
                  ? _GoalWarningChip(
                      count: detail.goalLowerCount,
                      onTap: () => showAdminGoalHistorySheet(
                        context,
                        detail.goalHistory,
                      ),
                    )
                  : null,
            ),
            _InfoRow(
              label: l10n.totalContributed,
              value: formatKes(detail.raisedKes),
            ),
            _InfoRow(
              label: l10n.adminPaymentMethodsUsed,
              value: detail.paymentMethodsUsed.isEmpty
                  ? l10n.adminPaymentMethodsNone
                  : detail.paymentMethodsUsed.join(', '),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContributionsTab extends StatelessWidget {
  const _ContributionsTab({required this.contributions});

  final List<ContributionActivity> contributions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (contributions.isEmpty) {
      return Center(
        child: Text(
          l10n.noContributionsYet,
          style: GoogleFonts.dmSans(color: AppPallete.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        context.responsivePagePadding,
        16,
        context.responsivePagePadding,
        24,
      ),
      itemCount: contributions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final activity = contributions[index];
        return _ContributionTile(
          activity: activity,
          onTap: () => showAdminContributionDetailSheet(context, activity),
        );
      },
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.events});

  final List<AdminMemberActivityEvent> events;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (events.isEmpty) {
      return Center(
        child: Text(
          l10n.adminMemberActivityEmpty,
          style: GoogleFonts.dmSans(color: AppPallete.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        context.responsivePagePadding,
        16,
        context.responsivePagePadding,
        24,
      ),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        return _ActivityTimelineTile(
          event: events[index],
          isLast: index == events.length - 1,
        );
      },
    );
  }
}

class _ActivityTimelineTile extends StatelessWidget {
  const _ActivityTimelineTile({
    required this.event,
    required this.isLast,
  });

  final AdminMemberActivityEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, color, title) = switch (event.kind) {
      AdminMemberActivityKind.joined => (
          Icons.person_add_outlined,
          AppPallete.tcBlueLight,
          l10n.adminActivityJoined,
        ),
      AdminMemberActivityKind.targetSet => (
          Icons.flag_outlined,
          AppPallete.tcBlueBright,
          l10n.adminActivityTargetSet,
        ),
      AdminMemberActivityKind.goalChanged => (
          Icons.trending_down_rounded,
          AppPallete.warningAmber,
          l10n.adminActivityGoalChanged(
            formatKes(event.fromKes ?? 0),
            formatKes(event.toKes ?? 0),
          ),
        ),
      AdminMemberActivityKind.contribution => (
          Icons.payments_outlined,
          AppPallete.successGreen,
          l10n.adminActivityContribution(formatKes(event.amountKes ?? 0)),
        ),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppPallete.border,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppPallete.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDisplayDate(event.date),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppPallete.textMuted,
                    ),
                  ),
                  if (event.paymentMethod != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      event.paymentMethod!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppPallete.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContributionTile extends StatelessWidget {
  const _ContributionTile({required this.activity, required this.onTap});

  final ContributionActivity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPallete.tcWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPallete.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatKes(activity.amountKes),
                      style: GoogleFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppPallete.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${activity.paymentMethod} · ${formatDisplayDate(activity.date)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppPallete.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppPallete.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPallete.tcWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPallete.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 13, color: AppPallete.textMuted),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppPallete.textPrimary,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalWarningChip extends StatelessWidget {
  const _GoalWarningChip({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppPallete.warningAmber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPallete.warningAmber.withValues(alpha: 0.4)),
        ),
        child: Text(
          context.l10n.adminGoalLoweredCount(count),
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppPallete.warningAmber,
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: AppPallete.scaffoldBg,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
