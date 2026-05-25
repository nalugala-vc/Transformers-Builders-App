import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/l10n/l10n_extension.dart';
import '../../../../../core/l10n/member_group_l10n.dart';
import '../../../../../core/utils/theme/app_pallete.dart';
import '../../../domain/models/contribution_segment.dart';
import '../../utils/member_formatters.dart';
import 'contribution_donut_chart.dart';

class ProgressOverviewCard extends StatelessWidget {
  const ProgressOverviewCard({
    super.key,
    required this.totalKes,
    required this.monthlyChangeKes,
    required this.monthlyChangePercent,
    required this.segments,
    required this.selectedSegmentId,
    required this.onSegmentSelected,
  });

  final int totalKes;
  final int monthlyChangeKes;
  final double monthlyChangePercent;
  final List<ContributionSegment> segments;
  final String? selectedSegmentId;
  final ValueChanged<String> onSegmentSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Only show the monthly badge once we actually compute monthly deltas
    // (will be populated by a backend aggregator). For now we hide it instead
    // of showing a misleading "+KES 0 (0.0%) this month".
    final hasMonthlyChange = monthlyChangeKes != 0 || monthlyChangePercent != 0;
    final changePositive = monthlyChangeKes >= 0;
    final changeColor = changePositive ? AppPallete.successGreen : AppPallete.errorRed;
    final changePrefix = changePositive ? '+' : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: AppPallete.tcWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPallete.border),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ContributionDonutChart(
                  segments: segments,
                  totalKes: totalKes,
                  size: 220,
                  strokeWidth: 24,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatKes(totalKes),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppPallete.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.totalRaised,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppPallete.textMuted,
                      ),
                    ),
                    if (hasMonthlyChange) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: changeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$changePrefix${formatKes(monthlyChangeKes.abs())} '
                          '(${monthlyChangePercent.toStringAsFixed(1)}%) this month',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: changeColor,
                          ),
                        ),
                      ),
                    ] else if (totalKes == 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.noContributionsYet,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppPallete.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...segments.map((segment) {
            final selected = segment.id == selectedSegmentId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSegmentSelected(segment.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? segment.color.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: selected
                          ? Border.all(color: segment.color.withValues(alpha: 0.35))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: segment.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            segment.localizedLabel(l10n),
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppPallete.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          formatKes(segment.amountKes),
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppPallete.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
