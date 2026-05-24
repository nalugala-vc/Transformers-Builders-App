import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/l10n/l10n_extension.dart';
import '../../../../../core/utils/theme/app_pallete.dart';
import '../../../../../core/utils/theme/app_sizes.dart';
import '../../utils/member_formatters.dart';
import 'contribution_illustration.dart';

/// Shown after a contribution goal is set and before the first gift is recorded.
class MemberStartContributingCard extends StatelessWidget {
  const MemberStartContributingCard({
    super.key,
    required this.targetKes,
    required this.onStartContributing,
    this.onShare,
  });

  final int targetKes;
  final VoidCallback onStartContributing;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
            l10n.startContributing,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppPallete.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.startContributingBody(formatKes(targetKes)),
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppPallete.textSecondary,
              height: 1.5,
            ),
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
          if (onShare != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_rounded, size: 18),
                label: Text(
                  l10n.shareFundraiser,
                  style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppPallete.tcBlueBright,
                  side: const BorderSide(color: AppPallete.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
