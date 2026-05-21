import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/theme/app_pallete.dart';
import '../../../domain/models/contribution_segment.dart';
import '../../utils/member_formatters.dart';

class ProgressSegmentDetailCard extends StatelessWidget {
  const ProgressSegmentDetailCard({
    super.key,
    required this.segment,
    required this.monthlyChangePercent,
  });

  final ContributionSegment segment;
  final double monthlyChangePercent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPallete.tcWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPallete.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppPallete.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatKes(segment.amountKes),
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppPallete.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (segment.amountKes > 0 && monthlyChangePercent != 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppPallete.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${monthlyChangePercent.toStringAsFixed(1)}% this month',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppPallete.successGreen,
                    ),
                  ),
                ),
            ],
          ),
          if (segment.recentTitle != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: AppPallete.border),
            ),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: segment.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.volunteer_activism_rounded,
                    color: segment.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        segment.recentTitle!,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppPallete.textPrimary,
                        ),
                      ),
                      if (segment.recentSubtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          segment.recentSubtitle!,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppPallete.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (segment.recentAmountKes != null)
                  Text(
                    formatKes(segment.recentAmountKes!),
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppPallete.textPrimary,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
