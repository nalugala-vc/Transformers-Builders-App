import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/models/member_notification.dart';

enum NotificationInboxFilter { all, unread }

final notificationInboxFilterProvider = StateProvider<NotificationInboxFilter>(
  (ref) => NotificationInboxFilter.all,
);

class MemberNotificationsController extends StateNotifier<List<MemberNotification>> {
  MemberNotificationsController() : super(MemberNotification.samples);

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllAsRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }
}

final memberNotificationsProvider =
    StateNotifierProvider<MemberNotificationsController, List<MemberNotification>>(
  (ref) => MemberNotificationsController(),
);

final memberUnreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(memberNotificationsProvider).where((n) => !n.isRead).length;
});

final filteredNotificationsProvider = Provider<List<MemberNotification>>((ref) {
  final items = ref.watch(memberNotificationsProvider);
  final filter = ref.watch(notificationInboxFilterProvider);
  return switch (filter) {
    NotificationInboxFilter.all => items,
    NotificationInboxFilter.unread => items.where((n) => !n.isRead).toList(),
  };
});
