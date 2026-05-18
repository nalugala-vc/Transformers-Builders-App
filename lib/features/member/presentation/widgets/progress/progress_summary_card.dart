import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/theme/app_pallete.dart';
import '../../../domain/models/contribution_segment.dart';
import '../../utils/member_formatters.dart';

class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.segments,
  });

  final String title;
  final String subtitle;
  final List<ContributionSegment> segments;

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
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppPallete.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ...segments.map((segment) {
            final target = segment.targetKes ?? segment.amountKes;
            final progress = target <= 0 ? 0.0 : (segment.amountKes / target).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          segment.label,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppPallete.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        formatKes(segment.amountKes),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppPallete.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppPallete.progressTrack,
                      color: segment.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).round()}% of ${formatKes(target)} target',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppPallete.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
