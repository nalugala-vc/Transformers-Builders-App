import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../auth/domain/models/app_user.dart';
import '../../../auth/domain/models/user_role.dart';
import '../../../member/data/repositories/member_contribution_repository.dart';
import '../../../member/domain/models/contribution_activity.dart';
import '../../domain/models/admin_member_activity_event.dart';
import '../../domain/models/admin_member_detail.dart';
import '../../domain/models/admin_member_list_item.dart';
import '../../domain/models/goal_history_entry.dart';

void _log(String event, [Object? detail]) {
  if (!kDebugMode) return;
  final msg = detail != null ? '$event | $detail' : event;
  dev.log(msg, name: 'AdminMember');
  debugPrint('[AdminMember] $msg');
}

void _logError(String op, Object e, [StackTrace? st]) {
  if (!kDebugMode) return;
  final code = e is FirebaseException ? e.code : 'unknown';
  final message = e is FirebaseException ? (e.message ?? '') : e.toString();
  dev.log('$op → $code $message', name: 'AdminMember', error: e, stackTrace: st);
  debugPrint('[AdminMember] $op → $code $message');
}

/// Admin read/write operations for church member roster management.
class AdminMemberRepository {
  AdminMemberRepository({
    FirebaseFirestore? firestore,
    MemberContributionRepository? contributions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _contributions = contributions ?? MemberContributionRepository(firestore);

  final FirebaseFirestore _firestore;
  final MemberContributionRepository _contributions;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<List<AdminMemberListItem>> listActiveMembers() async {
    _log('listActiveMembers');
    try {
      final snap = await _users
          .where('role', isEqualTo: UserRole.member.name)
          .get()
          .timeout(const Duration(seconds: 20));

      final items = <AdminMemberListItem>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        if (data['isActive'] == false) continue;

        final user = AppUser.fromFirestore(doc);
        items.add(
          AdminMemberListItem(
            user: user,
            raisedKes: _readAmount(data['contributionRaisedKes']),
            targetKes: _readAmount(data['contributionTargetKes']),
          ),
        );
      }

      items.sort(
        (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
      );

      _log('listActiveMembers success', 'count=${items.length}');
      return items;
    } catch (e, st) {
      _logError('listActiveMembers', e, st);
      rethrow;
    }
  }

  Future<AdminMemberDetail> getMemberDetail(String uid) async {
    _log('getMemberDetail', 'uid=$uid');
    try {
      final userDoc = await _users.doc(uid).get().timeout(const Duration(seconds: 15));
      if (!userDoc.exists) {
        throw StateError('Member not found.');
      }

      final data = userDoc.data()!;
      final user = AppUser.fromFirestore(userDoc);
      final goalHistory = _parseGoalHistory(data['contributionGoalHistory']);
      final contributions = await _contributions.listContributions(uid);
      final raisedKes = _readAmount(data['contributionRaisedKes']);
      final targetKes = _readAmount(data['contributionTargetKes']);
      final goalSetAt = _timestampToDate(data['contributionTargetSetAt']);
      final goalAdjustedAt = _timestampToDate(data['contributionTargetUpdatedAt']);

      final paymentMethods = {
        for (final c in contributions) c.paymentMethod,
      }.toList()
        ..sort();

      final activityEvents = _buildActivityTimeline(
        user: user,
        contributions: contributions,
        goalHistory: goalHistory,
        goalSetAt: goalSetAt,
      );

      _log('getMemberDetail success', 'uid=$uid');
      return AdminMemberDetail(
        user: user,
        raisedKes: raisedKes,
        targetKes: targetKes,
        goalHistory: goalHistory,
        contributions: contributions,
        activityEvents: activityEvents,
        paymentMethodsUsed: paymentMethods,
        goalSetAt: goalSetAt,
        goalAdjustedAt: goalAdjustedAt,
      );
    } catch (e, st) {
      _logError('getMemberDetail', e, st);
      rethrow;
    }
  }

  Future<void> deactivateMember(String uid) async {
    _log('deactivateMember', 'uid=$uid');
    try {
      await _users.doc(uid).set(
        {
          'isActive': false,
          'deactivatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      _log('deactivateMember success', 'uid=$uid');
    } catch (e, st) {
      _logError('deactivateMember', e, st);
      rethrow;
    }
  }

  List<GoalHistoryEntry> _parseGoalHistory(Object? raw) {
    if (raw is! List) return [];
    final entries = <GoalHistoryEntry>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final from = _readAmount(item['fromKes']);
      final to = _readAmount(item['toKes']);
      final changedAt = _timestampToDate(item['changedAt']);
      if (changedAt == null) continue;
      entries.add(GoalHistoryEntry(fromKes: from, toKes: to, changedAt: changedAt));
    }
    entries.sort((a, b) => b.changedAt.compareTo(a.changedAt));
    return entries;
  }

  List<AdminMemberActivityEvent> _buildActivityTimeline({
    required AppUser user,
    required List<ContributionActivity> contributions,
    required List<GoalHistoryEntry> goalHistory,
    DateTime? goalSetAt,
  }) {
    final events = <AdminMemberActivityEvent>[];

    if (user.createdAt case final DateTime joined) {
      events.add(
        AdminMemberActivityEvent(kind: AdminMemberActivityKind.joined, date: joined),
      );
    }

    if (goalSetAt case final DateTime setAt) {
      events.add(
        AdminMemberActivityEvent(kind: AdminMemberActivityKind.targetSet, date: setAt),
      );
    }

    for (final entry in goalHistory) {
      events.add(
        AdminMemberActivityEvent(
          kind: AdminMemberActivityKind.goalChanged,
          date: entry.changedAt,
          fromKes: entry.fromKes,
          toKes: entry.toKes,
        ),
      );
    }

    for (final contribution in contributions) {
      events.add(
        AdminMemberActivityEvent(
          kind: AdminMemberActivityKind.contribution,
          date: contribution.date,
          amountKes: contribution.amountKes,
          paymentMethod: contribution.paymentMethod,
          reference: contribution.reference,
        ),
      );
    }

    events.sort((a, b) => b.date.compareTo(a.date));
    return events;
  }

  int _readAmount(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  DateTime? _timestampToDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
