import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../domain/models/church_update.dart';
import '../../../member/presentation/utils/notification_time.dart';

Future<void> showChurchUpdateDetailSheet(
  BuildContext context,
  ChurchUpdate update,
) {
  final l10n = context.l10n;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPallete.tcWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final author = update.createdByName?.trim();

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
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppPallete.tcBlueLight.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: AppPallete.tcBlueLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.churchUpdateLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppPallete.tcBlueLight,
                        ),
                      ),
                      Text(
                        formatNotificationTime(update.createdAt),
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppPallete.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              update.title,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppPallete.textPrimary,
              ),
            ),
            if (author != null && author.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                l10n.churchUpdateFrom(author),
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppPallete.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              update.body,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppPallete.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
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
                child: Text(
                  l10n.done,
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
