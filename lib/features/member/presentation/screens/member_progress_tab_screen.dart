import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/theme/app_pallete.dart';

class MemberProgressTabScreen extends StatelessWidget {
  const MemberProgressTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppPallete.scaffoldBg,
      child: Center(
        child: Text(
          'Progress',
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppPallete.textSecondary,
          ),
        ),
      ),
    );
  }
}
