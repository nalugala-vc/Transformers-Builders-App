import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/utils/theme/app_pallete.dart';
import '../../../domain/models/member_notification.dart';
import '../../utils/notification_time.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final MemberNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(notification.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppPallete.tcWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: notification.isRead ? AppPallete.border : style.color.withValues(alpha: 0.35),
              ),
              color: notification.isRead ? AppPallete.tcWhite : style.color.withValues(alpha: 0.04),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: style.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(style.icon, size: 22, color: style.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                                color: AppPallete.textPrimary,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                color: AppPallete.tcBlueBright,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppPallete.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatNotificationTime(notification.createdAt),
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppPallete.textMuted,
                        ),
                      ),
                    ],
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

class _NotificationStyle {
  const _NotificationStyle({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

_NotificationStyle _styleFor(MemberNotificationType type) => switch (type) {
      MemberNotificationType.contribution => const _NotificationStyle(
          icon: Icons.volunteer_activism_rounded,
          color: AppPallete.tcBlueBright,
        ),
      MemberNotificationType.goal => const _NotificationStyle(
          icon: Icons.flag_rounded,
          color: AppPallete.warningAmber,
        ),
      MemberNotificationType.church => const _NotificationStyle(
          icon: Icons.church_rounded,
          color: AppPallete.successGreen,
        ),
      MemberNotificationType.reminder => const _NotificationStyle(
          icon: Icons.schedule_rounded,
          color: AppPallete.infoBlue,
        ),
      MemberNotificationType.admin => const _NotificationStyle(
          icon: Icons.admin_panel_settings_outlined,
          color: Color(0xFF8B5CF6),
        ),
    };
