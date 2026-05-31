import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';

class AdminManagementTabScreen extends StatelessWidget {
  const AdminManagementTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: AppPallete.scaffoldBg,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(context.responsivePagePadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppPallete.tcBlueBright.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: AppPallete.tcBlueBright,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.adminTabManagement,
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppPallete.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.adminManagementComingSoon,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppPallete.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
