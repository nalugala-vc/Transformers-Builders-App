import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../../../../core/utils/theme/app_sizes.dart';
import '../../../church_updates/presentation/providers/church_updates_providers.dart';
import '../../../church_updates/presentation/widgets/church_update_detail_sheet.dart';
import '../../../church_updates/presentation/widgets/church_update_tile.dart';
import '../providers/member_notifications_provider.dart';
import '../utils/notification_time.dart';
import '../widgets/notifications/notification_detail_sheet.dart';
import '../widgets/notifications/notification_filter_bar.dart';
import '../widgets/notifications/notification_tile.dart';

class MemberNotificationsScreen extends ConsumerWidget {
  const MemberNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DefaultTabController(
      length: 2,
      child: _MemberNotificationsView(),
    );
  }
}

class _MemberNotificationsView extends ConsumerWidget {
  const _MemberNotificationsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final unreadCount = ref.watch(memberUnreadNotificationsCountProvider);
    final tabController = DefaultTabController.of(context);

    return ListenableBuilder(
      listenable: tabController,
      builder: (context, _) {
        final onNotificationsTab = tabController.index == 0;

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
              l10n.notifications,
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppPallete.textPrimary,
              ),
            ),
            actions: [
              if (onNotificationsTab && unreadCount > 0)
                TextButton(
                  onPressed: () => ref
                      .read(memberNotificationsProvider.notifier)
                      .markAllAsRead(),
                  child: Text(
                    l10n.markAllRead,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppPallete.tcBlueBright,
                    ),
                  ),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(49),
              child: Column(
                children: [
                  TabBar(
                    labelColor: AppPallete.tcBlueBright,
                    unselectedLabelColor: AppPallete.textMuted,
                    indicatorColor: AppPallete.tcBlueBright,
                    indicatorWeight: 2.5,
                    labelStyle: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(text: l10n.notificationsInboxTab),
                      Tab(text: l10n.updatesTab),
                    ],
                  ),
                  Container(height: 1, color: AppPallete.border),
                ],
              ),
            ),
          ),
          body: const TabBarView(
            children: [
              _NotificationsInboxTab(),
              _UpdatesTab(),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationsInboxTab extends ConsumerWidget {
  const _NotificationsInboxTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(notificationInboxFilterProvider);
    final unreadCount = ref.watch(memberUnreadNotificationsCountProvider);
    final notifications = ref.watch(filteredNotificationsProvider);
    final grouped = groupNotificationsBySection(
      notifications,
      (n) => n.createdAt,
    );

    return Column(
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
              ? _EmptyNotificationsInbox(filter: filter)
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
    );
  }
}

class _UpdatesTab extends ConsumerWidget {
  const _UpdatesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final updatesAsync = ref.watch(publishedChurchUpdatesProvider);

    return updatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: EdgeInsets.all(context.responsivePagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.churchUpdatesLoadError,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(color: AppPallete.textPrimary),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(publishedChurchUpdatesProvider),
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
      ),
      data: (updates) {
        if (updates.isEmpty) {
          return _EmptyUpdatesState(message: l10n.churchUpdatesEmpty);
        }

        return RefreshIndicator(
          color: AppPallete.tcBlueBright,
          onRefresh: () => refreshChurchUpdates(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              context.responsivePagePadding,
              16,
              context.responsivePagePadding,
              24,
            ),
            children: [
              Text(
                l10n.churchUpdatesSubtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppPallete.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              for (final update in updates)
                ChurchUpdateTile(
                  update: update,
                  onTap: () => showChurchUpdateDetailSheet(context, update),
                ),
            ],
          ),
        );
      },
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

class _EmptyNotificationsInbox extends StatelessWidget {
  const _EmptyNotificationsInbox({required this.filter});

  final NotificationInboxFilter filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
              isUnreadFilter
                  ? l10n.notificationsEmptyUnread
                  : l10n.notificationsEmptyAll,
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
                  ? l10n.notificationsEmptyUnreadBody
                  : l10n.notificationsEmptyAllBody,
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

class _EmptyUpdatesState extends StatelessWidget {
  const _EmptyUpdatesState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
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
                color: AppPallete.tcBlueLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.campaign_outlined,
                size: 36,
                color: AppPallete.tcBlueLight,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
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
