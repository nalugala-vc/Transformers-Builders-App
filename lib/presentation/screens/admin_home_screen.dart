import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/theme/app_pallete.dart';

/// Home for [UserRole.admin] accounts.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.tcBlueDark,
        foregroundColor: AppPallete.tcWhite,
        title: Text(
          'Admin',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Admin dashboard — member management and church settings will live here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: AppPallete.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
