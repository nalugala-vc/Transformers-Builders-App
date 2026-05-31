import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../member/domain/models/contribution_activity.dart';
import '../../../member/presentation/utils/member_formatters.dart';

Future<void> showAdminContributionDetailSheet(
  BuildContext context,
  ContributionActivity activity,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final l10n = context.l10n;
      final statusLabel = switch (activity.status) {
        ContributionPaymentStatus.completed => l10n.statusCompleted,
        ContributionPaymentStatus.pending => l10n.statusPending,
        ContributionPaymentStatus.failed => l10n.statusFailed,
      };
      final statusColor = switch (activity.status) {
        ContributionPaymentStatus.completed => AppPallete.successGreen,
        ContributionPaymentStatus.pending => AppPallete.warningAmber,
        ContributionPaymentStatus.failed => AppPallete.errorRed,
      };

      return Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppPallete.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.contributionDetails,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppPallete.tcBlueBright,
              ),
            ),
            const SizedBox(height: 20),
            _DetailRow(label: l10n.contributionAmount, value: formatKes(activity.amountKes)),
            _DetailRow(label: l10n.contributionDate, value: formatDisplayDate(activity.date)),
            _DetailRow(label: l10n.paymentMethod, value: activity.paymentMethod),
            _DetailRow(label: l10n.contributionReference, value: activity.reference),
            if (activity.providerReference != null &&
                activity.providerReference!.isNotEmpty)
              _DetailRow(
                label: l10n.adminProviderReference,
                value: activity.providerReference!,
              ),
            if (activity.fxRate != null)
              _DetailRow(
                label: l10n.adminFxRate,
                value: activity.fxRate!.toStringAsFixed(4),
              ),
            if (activity.notes != null && activity.notes!.isNotEmpty)
              _DetailRow(label: l10n.contributionNotes, value: activity.notes!),
            _DetailRow(
              label: l10n.contributionStatus,
              value: statusLabel,
              valueColor: statusColor,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppPallete.tcBlueBright,
                  foregroundColor: AppPallete.tcWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.done),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppPallete.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppPallete.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
