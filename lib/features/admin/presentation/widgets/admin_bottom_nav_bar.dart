import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../domain/models/admin_tab.dart';

class AdminBottomNavBar extends StatelessWidget {
  const AdminBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final AdminTab currentTab;
  final ValueChanged<AdminTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: AppPallete.tcWhite,
        border: Border(top: BorderSide(color: AppPallete.border, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: AdminTab.values.map((tab) {
              final selected = tab == currentTab;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTabSelected(tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppPallete.tcBlueBright.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            selected ? _filledIconFor(tab) : _iconFor(tab),
                            size: 22,
                            color: selected
                                ? AppPallete.tcBlueBright
                                : AppPallete.textMuted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab.label(l10n),
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected
                                ? AppPallete.tcBlueBright
                                : AppPallete.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(AdminTab tab) => switch (tab) {
        AdminTab.dashboard => Icons.dashboard_outlined,
        AdminTab.management => Icons.groups_outlined,
        AdminTab.updates => Icons.campaign_outlined,
        AdminTab.profile => Icons.person_outline_rounded,
      };

  IconData _filledIconFor(AdminTab tab) => switch (tab) {
        AdminTab.dashboard => Icons.dashboard_rounded,
        AdminTab.management => Icons.groups_rounded,
        AdminTab.updates => Icons.campaign_rounded,
        AdminTab.profile => Icons.person_rounded,
      };
}
