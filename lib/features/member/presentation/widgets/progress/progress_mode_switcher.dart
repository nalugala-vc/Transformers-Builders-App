import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/l10n/l10n_extension.dart';
import '../../../../../core/utils/theme/app_pallete.dart';
import '../../../domain/models/progress_breakdown_mode.dart';

class ProgressModeSwitcher extends StatelessWidget {
  const ProgressModeSwitcher({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  final ProgressBreakdownMode mode;
  final ValueChanged<ProgressBreakdownMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppPallete.tcWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPallete.border),
      ),
      child: Row(
        children: ProgressBreakdownMode.values.map((option) {
          final selected = option == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => onModeChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppPallete.tcBlueBright : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  option.label(l10n),
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppPallete.tcWhite : AppPallete.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
