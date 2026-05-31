import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';

Future<bool?> showAdminRemoveMemberDialog(
  BuildContext context, {
  required String memberName,
}) {
  final l10n = context.l10n;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppPallete.tcWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        l10n.adminRemoveMemberTitle(memberName),
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.w700,
          color: AppPallete.textPrimary,
        ),
      ),
      content: Text(
        l10n.adminRemoveMemberBody,
        style: GoogleFonts.dmSans(
          color: AppPallete.textSecondary,
          height: 1.45,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppPallete.tcRed),
          child: Text(l10n.adminRemoveMemberConfirm),
        ),
      ],
    ),
  );
}
