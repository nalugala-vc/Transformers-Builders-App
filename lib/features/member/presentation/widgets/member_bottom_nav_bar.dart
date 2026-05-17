import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/theme/app_pallete.dart';
import '../../domain/models/member_tab.dart';

class MemberBottomNavBar extends StatelessWidget {
  const MemberBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final MemberTab currentTab;
  final ValueChanged<MemberTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppPallete.tcWhite,
        border: Border(top: BorderSide(color: AppPallete.border, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: MemberTab.values.map((tab) {
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
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppPallete.tcBlue.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            selected ? _filledIconFor(tab) : _iconFor(tab),
                            size: 22,
                            color: selected ? AppPallete.tcBlue : AppPallete.textMuted,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab.label,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected ? AppPallete.tcBlue : AppPallete.textMuted,
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

  IconData _iconFor(MemberTab tab) => switch (tab) {
        MemberTab.home => Icons.home_outlined,
        MemberTab.progress => Icons.trending_up_outlined,
        MemberTab.profile => Icons.person_outline_rounded,
      };

  IconData _filledIconFor(MemberTab tab) => switch (tab) {
        MemberTab.home => Icons.home_rounded,
        MemberTab.progress => Icons.trending_up_rounded,
        MemberTab.profile => Icons.person_rounded,
      };
}
