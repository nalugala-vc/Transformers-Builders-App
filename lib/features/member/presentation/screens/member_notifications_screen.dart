import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../providers/member_notifications_provider.dart';
import '../utils/notification_time.dart';
import '../widgets/notifications/notification_detail_sheet.dart';
import '../widgets/notifications/notification_filter_bar.dart';
import '../widgets/notifications/notification_tile.dart';

class MemberNotificationsScreen extends ConsumerWidget {
  const MemberNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(notificationInboxFilterProvider);
    final unreadCount = ref.watch(memberUnreadNotificationsCountProvider);
    final notifications = ref.watch(filteredNotificationsProvider);
    final grouped = groupNotificationsBySection(
      notifications,
      (n) => n.createdAt,
    );

    return Scaffold(
      backgroundColor: AppPallete.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppPallete.tcWhite,
        surfaceTintColor: AppPallete.tcWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppPallete.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppPallete.textPrimary,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () =>
                  ref.read(memberNotificationsProvider.notifier).markAllAsRead(),
              child: Text(
                'Mark all read',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppPallete.tcBlueBright,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppPallete.border),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppPallete.tcWhite,
            padding: EdgeInsets.fromLTRB(
              context.responsivePagePadding,
              12,
              context.responsivePagePadding,
              16,
            ),
            child: NotificationFilterBar(
              filter: filter,
              unreadCount: unreadCount,
              onFilterChanged: (value) =>
                  ref.read(notificationInboxFilterProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? _EmptyInbox(filter: filter)
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                      context.responsivePagePadding,
                      16,
                      context.responsivePagePadding,
                      24,
                    ),
                    children: [
                      for (final entry in grouped.entries) ...[
                        _SectionHeader(label: entry.key),
                        const SizedBox(height: 8),
                        for (final notification in entry.value)
                          NotificationTile(
                            notification: notification,
                            onTap: () {
                              ref
                                  .read(memberNotificationsProvider.notifier)
                                  .markAsRead(notification.id);
                              showNotificationDetailSheet(context, notification);
                            },
                          ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppPallete.textMuted,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox({required this.filter});

  final NotificationInboxFilter filter;

  @override
  Widget build(BuildContext context) {
    final isUnreadFilter = filter == NotificationInboxFilter.unread;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppPallete.tcBlueBright.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 36,
                color: AppPallete.tcBlueBright,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isUnreadFilter ? 'No unread notifications' : 'No notifications yet',
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppPallete.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isUnreadFilter
                  ? 'You’re all caught up. Switch to All to see older messages.'
                  : 'Updates about contributions, goals, and church news will appear here.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppPallete.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
