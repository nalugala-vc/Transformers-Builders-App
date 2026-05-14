import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/theme/app_pallete.dart';

/// Horizontal rule with centered label, e.g. `──── or ────`.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({
    super.key,
    this.label = 'or',
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final lineStyle = GoogleFonts.dmSans(
      fontSize: 13,
      color: AppPallete.textMuted,
      fontWeight: FontWeight.w400,
    );
    return Row(
      children: [
        const Expanded(child: Divider(height: 1, color: AppPallete.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: lineStyle),
        ),
        const Expanded(child: Divider(height: 1, color: AppPallete.border)),
      ],
    );
  }
}
