import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/theme/app_pallete.dart';

class MemberProfileTabScreen extends StatelessWidget {
  const MemberProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppPallete.scaffoldBg,
      child: Center(
        child: Text(
          'Profile',
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
