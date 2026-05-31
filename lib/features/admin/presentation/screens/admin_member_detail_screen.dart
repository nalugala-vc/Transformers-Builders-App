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
import '../widgets/admin_contribution_detail_sheet.dart';
import '../widgets/admin_goal_history_sheet.dart';
import '../widgets/admin_remove_member_dialog.dart';
import '../../../member/presentation/widgets/profile/profile_section_card.dart';
import '../../../member/domain/models/contribution_activity.dart';
import '../../../member/presentation/utils/member_formatters.dart';

class AdminMemberDetailScreen extends ConsumerWidget {
  const AdminMemberDetailScreen({super.key, required this.memberUid});

  final String memberUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(adminMemberDetailProvider(memberUid));
    final l10n = context.l10n;

    return detailAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppPallete.scaffoldBg,
        appBar: _detailAppBar(context, l10n.adminMemberProfile),
        body: const Center(
          child: CircularProgressIndicator(color: AppPallete.tcBlueBright),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: AppPallete.scaffoldBg,
        appBar: _detailAppBar(context, l10n.adminMemberProfile),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(context.responsivePagePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.adminMembersLoadError, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => refreshAdminMemberDetail(ref, memberUid),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppPallete.tcBlueBright,
                  ),
                  child: Text(l10n.tryAgain),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (detail) => _AdminMemberDetailBody(detail: detail),
    );
  }
}

PreferredSizeWidget _detailAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: AppPallete.tcWhite,
    surfaceTintColor: AppPallete.tcWhite,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
      color: AppPallete.textPrimary,
      onPressed: () => context.pop(),
    ),
    title: Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppPallete.textPrimary,
      ),
    ),
  );
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
      child: Scaffold(
        backgroundColor: AppPallete.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppPallete.tcWhite,
          surfaceTintColor: AppPallete.tcWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppPallete.textPrimary,
            onPressed: () => context.pop(),
          ),
          title: Text(
            user.fullName,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded, color: AppPallete.textMuted),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'remove') {
                  _confirmRemove(context, ref, user.fullName);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'remove',
                  child: Text(
                    l10n.adminMemberActionRemove,
                    style: const TextStyle(color: AppPallete.tcRed),
                  ),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(49),
            child: Column(
              children: [
                TabBar(
                  labelColor: AppPallete.tcBlueBright,
                  unselectedLabelColor: AppPallete.textMuted,
                  indicatorColor: AppPallete.tcBlueBright,
                  indicatorWeight: 2.5,
                  labelStyle: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: l10n.adminMemberTabOverview),
                    Tab(text: l10n.adminMemberTabContributions),
                    Tab(text: l10n.adminMemberTabActivity),
                  ],
                ),
                const Divider(height: 1, color: AppPallete.border),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(detail: detail),
            _ContributionsTab(contributions: detail.contributions),
            _ActivityTab(events: detail.activityEvents),
          ],
        ),
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppPallete.tcBlueBright, AppPallete.tcBlueBrightDark],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppPallete.tcBlueBright.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
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
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          if (user.email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.email,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: AppPallete.textMuted, fontSize: 14),
            ),
          ],
          if (user.phoneE164 != null && user.phoneE164!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              user.phoneE164!,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppPallete.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          if (user.createdAt case final DateTime joined) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppPallete.cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.adminMemberJoined(formatDisplayDate(joined)),
                style: GoogleFonts.dmSans(fontSize: 12, color: AppPallete.textMuted),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppPallete.cardBg,
              borderRadius: BorderRadius.circular(14),
            ),
            width: double.infinity,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      l10n.adminContributionProgress,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppPallete.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${detail.progressPercent}%',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppPallete.tcBlueBright,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: detail.progressFraction,
                    minHeight: 8,
                    backgroundColor: AppPallete.progressTrack,
                    color: AppPallete.tcBlueBright,
                  ),
                ),
              ],
            ),
          ),
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
    final padding = context.responsivePagePadding;

    return ListView(
      padding: EdgeInsets.fromLTRB(padding, 16, padding, 24),
      children: [
        _MemberHeader(detail: detail),
        const SizedBox(height: 16),
        ProfileSectionCard(
          title: l10n.adminMemberTabOverview.toUpperCase(),
          children: [
            _OverviewTile(label: l10n.email, value: user.email),
            if (user.phoneE164 != null && user.phoneE164!.isNotEmpty)
              _OverviewTile(label: l10n.phone, value: user.phoneE164!),
            _OverviewTile(
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
            _OverviewTile(
              label: l10n.totalContributed,
              value: formatKes(detail.raisedKes),
            ),
            _OverviewTile(
              label: l10n.adminPaymentMethodsUsed,
              value: detail.paymentMethodsUsed.isEmpty
                  ? l10n.adminPaymentMethodsNone
                  : detail.paymentMethodsUsed.join(', '),
              showDivider: false,
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
        child: Padding(
          padding: EdgeInsets.all(context.responsivePagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppPallete.tcBlueBright.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppPallete.tcBlueBright,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noContributionsYet,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppPallete.textPrimary,
                ),
              ),
            ],
          ),
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
        child: Padding(
          padding: EdgeInsets.all(context.responsivePagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppPallete.tcBlueBright.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.timeline_outlined,
                  color: AppPallete.tcBlueBright,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.adminMemberActivityEmpty,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppPallete.textPrimary,
                ),
              ),
            ],
          ),
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
      separatorBuilder: (context, index) => const SizedBox(height: 0),
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
          AppPallete.tcBlueBright,
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

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({
    required this.label,
    required this.value,
    this.trailing,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppPallete.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppPallete.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 20, color: AppPallete.border),
      ],
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
