import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/theme/app_pallete.dart';
import '../../../domain/models/contribution_activity.dart';
import '../../utils/member_formatters.dart';

Future<void> showActivityDetailSheet(
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
      final statusLabel = switch (activity.status) {
        ContributionPaymentStatus.completed => 'Completed',
        ContributionPaymentStatus.pending => 'Pending',
        ContributionPaymentStatus.failed => 'Failed',
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
              'Contribution details',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppPallete.tcBlueBright,
              ),
            ),
            const SizedBox(height: 20),
            _DetailRow(label: 'Amount', value: formatKes(activity.amountKes)),
            _DetailRow(label: 'Date', value: formatDisplayDate(activity.date)),
            _DetailRow(label: 'Payment method', value: activity.paymentMethod),
            _DetailRow(label: 'Reference', value: activity.reference),
            _DetailRow(
              label: 'Status',
              value: statusLabel,
              valueColor: statusColor,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppPallete.tcBlueBright,
                  foregroundColor: AppPallete.tcWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                ),
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
                fontWeight: FontWeight.w400,
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
