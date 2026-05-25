import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../../domain/models/contribution_activity.dart';
import '../providers/member_contribution_providers.dart';
import '../utils/member_formatters.dart';
import '../widgets/home/add_contribution_sheet.dart';
import '../widgets/home/activity_detail_sheet.dart';

class MemberContributionHistoryScreen extends ConsumerWidget {
  const MemberContributionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(memberContributionsListProvider);
    final l10n = context.l10n;

    return Scaffold(
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
          l10n.contributionHistory,
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppPallete.textPrimary,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final success = await showAddContributionSheet(context);
          if (success == true && context.mounted) {
            showAppSuccessToast(context, l10n.contributionAdded);
          }
        },
        backgroundColor: AppPallete.tcBlueBright,
        foregroundColor: AppPallete.tcWhite,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addContribution),
      ),
      body: contributionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(context.responsivePagePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.couldNotLoadHome, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(memberContributionsListProvider),
                  child: Text(l10n.tryAgain),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(context.responsivePagePadding),
                child: Text(
                  l10n.noContributionsYet,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: AppPallete.textSecondary,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              context.responsivePagePadding,
              16,
              context.responsivePagePadding,
              96,
            ),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final activity = items[index];
              return _ContributionListTile(
                activity: activity,
                onTap: () => showActivityDetailSheet(
                  context,
                  activity,
                  onEdit: () async {
                    Navigator.of(context).pop();
                    final success = await showEditContributionSheet(context, activity);
                    if (success == true && context.mounted) {
                      showAppSuccessToast(context, l10n.contributionUpdated);
                    }
                  },
                  onDelete: () => _confirmDelete(context, ref, activity),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ContributionActivity activity,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppPallete.tcWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.deleteContribution,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n.deleteContributionConfirm,
          style: GoogleFonts.dmSans(color: AppPallete.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppPallete.tcRed),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    Navigator.of(context).pop();

    final err = await deleteMemberContribution(ref, contributionId: activity.id);
    if (!context.mounted) return;
    if (err != null) {
      showAppErrorToast(context, err);
    } else {
      showAppSuccessToast(context, l10n.contributionDeleted);
    }
  }
}

class _ContributionListTile extends StatelessWidget {
  const _ContributionListTile({
    required this.activity,
    required this.onTap,
  });

  final ContributionActivity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (activity.status) {
      ContributionPaymentStatus.completed => AppPallete.successGreen,
      ContributionPaymentStatus.pending => AppPallete.warningAmber,
      ContributionPaymentStatus.failed => AppPallete.errorRed,
    };

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
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppPallete.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
