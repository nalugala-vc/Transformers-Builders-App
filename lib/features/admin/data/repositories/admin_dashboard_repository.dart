import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../member/data/repositories/member_contribution_repository.dart';
import '../../../member/domain/models/church_progress_data.dart';
import '../../../member/domain/models/contribution_activity.dart';
import '../../domain/models/admin_attention_item.dart';
import '../../domain/models/admin_dashboard_data.dart';
import '../../domain/models/admin_recent_activity.dart';

void _log(String event, [Object? detail]) {
  if (!kDebugMode) return;
  final msg = detail != null ? '$event | $detail' : event;
  dev.log(msg, name: 'AdminDashboard');
  debugPrint('[AdminDashboard] $msg');
}

void _logError(String op, Object e, [StackTrace? st]) {
  if (!kDebugMode) return;
  final code = e is FirebaseException ? e.code : 'unknown';
  final message = e is FirebaseException ? (e.message ?? '') : e.toString();
  dev.log('$op → $code $message', name: 'AdminDashboard', error: e, stackTrace: st);
  debugPrint('[AdminDashboard] $op → $code $message');
}

/// Aggregates Firestore data into [AdminDashboardData] for the admin dashboard.
///
/// Reads:
/// * `churchProgress/current` — total raised + per-group totals (already kept
///   in sync by [MemberContributionRepository]).
/// * `users` where `role == "member"` — active member count + new-this-week.
/// * `collectionGroup('contributions')` — last-7-days raised delta and the
///   recent-activity feed (relies on the admin Firestore rule allowing this).
class AdminDashboardRepository {
  AdminDashboardRepository({
    FirebaseFirestore? firestore,
    MemberContributionRepository? contributions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _contributions = contributions ?? MemberContributionRepository(firestore);

  final FirebaseFirestore _firestore;
  final MemberContributionRepository _contributions;

  static const _recentFeedLimit = 10;
  static const _weeklyContributionScanLimit = 200;

  Future<AdminDashboardData> loadDashboard() async {
    _log('loadDashboard');
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekAgoTs = Timestamp.fromDate(weekAgo);

    final church = await _safeChurchProgress();
    final memberStats = await _loadMemberStats(weekAgoTs);
    final weeklyAndRecent = await _loadWeeklyAndRecent(weekAgoTs);

    final totalRaised = church.totalKes;
    final deltaKes = weeklyAndRecent.weeklyRaisedKes;
    final deltaPercent = totalRaised <= 0 ? 0.0 : (deltaKes / totalRaised) * 100;

    final attentionItems = <AdminAttentionItem>[
      // Reserved for pending-admin-request flow. Empty until that collection
      // exists; the dashboard renders an "all clear" empty state in that case.
    ];

    final data = AdminDashboardData(
      totalRaisedKes: totalRaised,
      totalRaisedDeltaKes: deltaKes,
      totalRaisedDeltaPercent: deltaPercent,
      activeMembers: memberStats.activeMembers,
      newMembersThisWeek: memberStats.newThisWeek,
      churchProgress: church,
      recentActivity: weeklyAndRecent.recentActivity,
      attentionItems: attentionItems,
    );

    _log(
      'loadDashboard success',
      'totalRaised=$totalRaised deltaKes=$deltaKes '
          'members=${memberStats.activeMembers} new=${memberStats.newThisWeek} '
          'recent=${weeklyAndRecent.recentActivity.length}',
    );
    return data;
  }

  Future<ChurchProgressData> _safeChurchProgress() async {
    try {
      return await _contributions.getChurchProgressData();
    } catch (e, st) {
      _logError('churchProgress', e, st);
      return ChurchProgressData.empty;
    }
  }

  Future<_MemberStats> _loadMemberStats(Timestamp weekAgoTs) async {
    try {
      final snap = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'member')
          .get()
          .timeout(const Duration(seconds: 15));

      var newThisWeek = 0;
      var activeMembers = 0;
      for (final doc in snap.docs) {
        if (doc.data()['isActive'] == false) continue;
        activeMembers += 1;
        final created = doc.data()['createdAt'];
        if (created is Timestamp && !created.toDate().isBefore(weekAgoTs.toDate())) {
          newThisWeek += 1;
        }
      }
      return _MemberStats(activeMembers: activeMembers, newThisWeek: newThisWeek);
    } catch (e, st) {
      _logError('memberStats', e, st);
      return const _MemberStats(activeMembers: 0, newThisWeek: 0);
    }
  }

  Future<_WeeklyAndRecent> _loadWeeklyAndRecent(Timestamp weekAgoTs) async {
    final recent = <AdminRecentActivity>[];
    var weeklyRaisedKes = 0;
    final memberCache = <String, _MemberLite>{};

    try {
      final snap = await _firestore
          .collectionGroup('contributions')
          .orderBy('createdAt', descending: true)
          .limit(_weeklyContributionScanLimit)
          .get()
          .timeout(const Duration(seconds: 15));

      for (final doc in snap.docs) {
        final data = doc.data();
        final amount = _readAmount(data['amountKes']);
        final status = data['status'] as String?;
        final createdAt = data['createdAt'];
        if (createdAt is! Timestamp) continue;
        final occurredAt = createdAt.toDate();
        final isWithinWeek = !occurredAt.isBefore(weekAgoTs.toDate());

        if (amount > 0 && status == 'completed' && isWithinWeek) {
          weeklyRaisedKes += amount;
        }

        if (recent.length < _recentFeedLimit) {
          final memberUid = _parentUidOf(doc.reference);
          final member = memberUid == null
              ? null
              : memberCache[memberUid] ??=
                  await _resolveMember(memberUid) ?? const _MemberLite();

          recent.add(
            AdminRecentActivity(
              id: doc.id,
              type: AdminRecentActivityType.memberContribution,
              title: member?.displayName ?? 'Member',
              subtitle: data['paymentMethod'] as String? ?? 'Manual',
              occurredAt: occurredAt,
              amountKes: amount > 0 ? amount : null,
              memberUid: memberUid,
              contributionId: doc.id,
            ),
          );
        }
      }
    } catch (e, st) {
      _logError('weeklyAndRecent', e, st);
    }

    return _WeeklyAndRecent(
      weeklyRaisedKes: weeklyRaisedKes,
      recentActivity: recent,
    );
  }

  Future<_MemberLite?> _resolveMember(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));
      final data = doc.data();
      if (data == null) return null;
      return _MemberLite(displayName: (data['fullName'] as String?)?.trim());
    } catch (e, st) {
      _logError('resolveMember', e, st);
      return null;
    }
  }

  /// `contributions` lives at `users/{uid}/contributions/{id}` — recover the
  /// member UID from the document path so we can join with the users doc.
  String? _parentUidOf(DocumentReference ref) {
    final parent = ref.parent.parent;
    return parent?.id;
  }

  /// Loads a single member's contribution (used when an admin taps a row in
  /// the recent activity feed and we want to show the existing detail sheet).
  Future<ContributionActivity?> loadContributionDetail({
    required String uid,
    required String contributionId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('contributions')
          .doc(contributionId)
          .get()
          .timeout(const Duration(seconds: 10));
      final data = doc.data();
      if (data == null) return null;
      return _activityFromMap(doc.id, data);
    } catch (e, st) {
      _logError('loadContributionDetail', e, st);
      return null;
    }
  }

  ContributionActivity? _activityFromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final amount = _readAmount(data['amountKes']);
    if (amount <= 0) return null;
    final createdAt = data['createdAt'];
    if (createdAt is! Timestamp) return null;
    return ContributionActivity(
      id: id,
      date: createdAt.toDate(),
      amountKes: amount,
      paymentMethod: data['paymentMethod'] as String? ?? 'Manual',
      reference: data['reference'] as String? ?? '—',
      status: _statusFromString(data['status'] as String?),
      notes: data['notes'] as String?,
    );
  }

  ContributionPaymentStatus _statusFromString(String? raw) => switch (raw) {
        'pending' => ContributionPaymentStatus.pending,
        'failed' => ContributionPaymentStatus.failed,
        _ => ContributionPaymentStatus.completed,
      };

  int _readAmount(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}

class _MemberStats {
  const _MemberStats({required this.activeMembers, required this.newThisWeek});
  final int activeMembers;
  final int newThisWeek;
}

class _WeeklyAndRecent {
  const _WeeklyAndRecent({
    required this.weeklyRaisedKes,
    required this.recentActivity,
  });
  final int weeklyRaisedKes;
  final List<AdminRecentActivity> recentActivity;
}

class _MemberLite {
  const _MemberLite({this.displayName});
  final String? displayName;
}
