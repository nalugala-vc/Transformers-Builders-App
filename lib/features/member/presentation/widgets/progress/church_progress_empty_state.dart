import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/l10n/l10n_extension.dart';
import '../../../../../core/utils/theme/app_pallete.dart';
import '../../../../../core/utils/theme/app_sizes.dart';
import '../../../domain/models/progress_breakdown_mode.dart';
import '../home/contribution_illustration.dart';

/// Shown on the Progress tab when no church-wide contributions exist yet for the
/// selected breakdown (demographics or ministries).
class ChurchProgressEmptyState extends StatelessWidget {
  const ChurchProgressEmptyState({
    super.key,
    required this.mode,
    required this.onStartContributing,
  });

  final ProgressBreakdownMode mode;
  final VoidCallback onStartContributing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDemographics = mode == ProgressBreakdownMode.demographics;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
      decoration: BoxDecoration(
        color: AppPallete.tcWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPallete.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: ContributionIllustration()),
          SizedBox(height: context.scaled.h8),
          Text(
            isDemographics
                ? l10n.churchProgressEmptyDemographicTitle
                : l10n.churchProgressEmptyMinistryTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isDemographics
                ? l10n.churchProgressEmptyDemographicBody
                : l10n.churchProgressEmptyMinistryBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppPallete.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _ZeroProgressRow(
            label: l10n.totalRaisedLabel,
            value: 'KES 0',
          ),
          const SizedBox(height: 10),
          _ZeroProgressRow(
            label: isDemographics ? l10n.groupsTracked : l10n.ministriesTracked,
            value: isDemographics
                ? l10n.demographicsTrackedValue
                : l10n.ministriesTrackedValue,
          ),
          SizedBox(height: context.scaled.h20),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: onStartContributing,
              icon: const Icon(Icons.volunteer_activism_rounded, size: 20),
              label: Text(
                l10n.startContributing,
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppPallete.tcRed,
                foregroundColor: AppPallete.tcWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZeroProgressRow extends StatelessWidget {
  const _ZeroProgressRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppPallete.scaffoldBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppPallete.textMuted,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
