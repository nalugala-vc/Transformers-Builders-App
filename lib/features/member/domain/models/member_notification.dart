enum MemberNotificationType {
  contribution,
  goal,
  church,
  reminder,
  admin,
}

class MemberNotification {
  const MemberNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final MemberNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  MemberNotification copyWith({bool? isRead}) {
    return MemberNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  static List<MemberNotification> get samples {
    final now = DateTime.now();
    return [
      MemberNotification(
        id: '1',
        type: MemberNotificationType.contribution,
        title: 'Contribution received',
        body: 'Your KES 2,500 contribution was recorded successfully. Thank you for giving!',
        createdAt: now.subtract(const Duration(minutes: 25)),
      ),
      MemberNotification(
        id: '2',
        type: MemberNotificationType.goal,
        title: 'You’re halfway to your goal',
        body: 'You’ve raised KES 2,500 of your KES 5,000 target. Keep going — every gift counts.',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      MemberNotification(
        id: '3',
        type: MemberNotificationType.church,
        title: 'Church-wide update',
        body: 'Transformers Chapel has reached 68% of this season’s building fund. Praise God!',
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      MemberNotification(
        id: '4',
        type: MemberNotificationType.reminder,
        title: 'Weekly giving reminder',
        body: 'Don’t forget your planned contribution this week. Tap Contribute on Home to give.',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
      ),
      MemberNotification(
        id: '5',
        type: MemberNotificationType.admin,
        title: 'Admin request update',
        body: 'Your request for admin access is still awaiting approval from church leadership.',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      MemberNotification(
        id: '6',
        type: MemberNotificationType.church,
        title: 'Youth ministry milestone',
        body: 'The youth group hit their monthly target. Celebrate with them this Sunday!',
        createdAt: now.subtract(const Duration(days: 4)),
        isRead: true,
      ),
    ];
  }
}
