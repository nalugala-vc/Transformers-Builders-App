import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../domain/models/goal_history_entry.dart';
import '../../../member/presentation/utils/member_formatters.dart';

Future<void> showAdminGoalHistorySheet(
  BuildContext context,
  List<GoalHistoryEntry> history,
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
              l10n.adminGoalHistoryTitle,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppPallete.tcBlueLight,
              ),
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              Text(
                l10n.adminGoalHistoryEmpty,
                style: GoogleFonts.dmSans(color: AppPallete.textSecondary),
              )
            else
              ...history.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.adminGoalHistoryEntry(
                            formatKes(entry.fromKes),
                            formatKes(entry.toKes),
                          ),
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppPallete.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        formatDisplayDate(entry.changedAt),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppPallete.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppPallete.tcBlueLight,
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
