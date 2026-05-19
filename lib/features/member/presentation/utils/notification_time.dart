String formatNotificationTime(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24 && now.day == dateTime.day) {
    return '${diff.inHours}h ago';
  }
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[dateTime.month - 1]} ${dateTime.day}';
}

String notificationSectionLabel(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (day == today) return 'Today';
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return 'Earlier';
}

Map<String, List<T>> groupNotificationsBySection<T>(
  List<T> items,
  DateTime Function(T item) createdAt,
) {
  final map = <String, List<T>>{};
  for (final item in items) {
    final key = notificationSectionLabel(createdAt(item));
    map.putIfAbsent(key, () => []).add(item);
  }

  const order = ['Today', 'Yesterday', 'Earlier'];
  return {
    for (final key in order)
      if (map.containsKey(key)) key: map[key]!,
  };
}
