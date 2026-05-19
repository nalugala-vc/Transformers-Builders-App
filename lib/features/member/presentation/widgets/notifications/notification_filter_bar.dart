import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/theme/app_pallete.dart';
import '../../providers/member_notifications_provider.dart';

class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({
    super.key,
    required this.filter,
    required this.unreadCount,
    required this.onFilterChanged,
  });

  final NotificationInboxFilter filter;
  final int unreadCount;
  final ValueChanged<NotificationInboxFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: NotificationInboxFilter.values.map((option) {
        final selected = filter == option;
        final label = option == NotificationInboxFilter.unread && unreadCount > 0
            ? 'Unread ($unreadCount)'
            : option.name[0].toUpperCase() + option.name.substring(1);

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => onFilterChanged(option),
            showCheckmark: false,
            labelStyle: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? AppPallete.tcWhite : AppPallete.textSecondary,
            ),
            selectedColor: AppPallete.tcBlueBright,
            backgroundColor: AppPallete.tcWhite,
            side: BorderSide(color: selected ? AppPallete.tcBlueBright : AppPallete.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        );
      }).toList(),
    );
  }
}
