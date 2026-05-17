import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/theme/app_pallete.dart';

class PendingAdminBanner extends StatelessWidget {
  const PendingAdminBanner({
    super.key,
    required this.onDismiss,
  });

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F4FF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppPallete.tcBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.schedule_rounded, color: AppPallete.tcBlue, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your admin access is awaiting approval.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppPallete.tcBlue,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: AppPallete.tcBlue.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
