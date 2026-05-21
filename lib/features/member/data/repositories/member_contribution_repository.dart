import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/contribution_activity.dart';
import '../../domain/models/member_contribution_summary.dart';

/// Member contribution goal (`users/{uid}`) and history (`contributions` subcollection).
class MemberContributionRepository {
  MemberContributionRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _users() =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> _contributions(String uid) =>
      _users().doc(uid).collection('contributions');

  Future<MemberContributionSummary> getHomeSummary(String uid) async {
    final userDoc = await _users().doc(uid).get().timeout(const Duration(seconds: 15));
    final userData = userDoc.data() ?? {};

    final targetRaw = userData['contributionTargetKes'];
    final targetKes = targetRaw is int
        ? targetRaw
        : targetRaw is num
            ? targetRaw.toInt()
            : null;

    final goalSetAt = _timestampToDate(userData['contributionTargetSetAt']);
    final goalAdjustedAt = _timestampToDate(userData['contributionTargetUpdatedAt']);
    final fullName = (userData['fullName'] as String?)?.trim();

    final activities = <ContributionActivity>[];
    var raisedKes = 0;

    try {
      final contributionsSnap = await _contributions(uid)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get()
          .timeout(const Duration(seconds: 15));

      for (final doc in contributionsSnap.docs) {
        final activity = _activityFromDoc(doc);
        if (activity == null) continue;
        activities.add(activity);
        if (activity.status == ContributionPaymentStatus.completed) {
          raisedKes += activity.amountKes;
        }
      }
    } on FirebaseException catch (e) {
      if (kDebugMode && e.code != 'permission-denied') {
        debugPrint('[MemberContribution] contributions read failed: ${e.code} ${e.message}');
      }
      // permission-denied: deploy firestore.rules for users/{uid}/contributions.
      // Other errors: treat as empty history so home still loads.
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('[MemberContribution] contributions read failed: $e');
      }
    }

    return MemberContributionSummary(
      targetKes: targetKes,
      goalSetAt: goalSetAt,
      goalAdjustedAt: goalAdjustedAt,
      raisedKes: raisedKes,
      recentActivities: activities.take(10).toList(),
      fullName: fullName?.isNotEmpty == true ? fullName : null,
    );
  }

  Future<void> setContributionTarget({
    required String uid,
    required int targetKes,
  }) async {
    if (targetKes <= 0) {
      throw ArgumentError.value(targetKes, 'targetKes', 'Must be greater than zero');
    }

    final ref = _users().doc(uid);
    final existing = await ref.get();
    final data = existing.data() ?? {};
    final hadTarget = data['contributionTargetKes'] != null;

    final updates = <String, dynamic>{
      'contributionTargetKes': targetKes,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!hadTarget) {
      updates['contributionTargetSetAt'] = FieldValue.serverTimestamp();
    } else {
      updates['contributionTargetUpdatedAt'] = FieldValue.serverTimestamp();
    }

    await ref.set(updates, SetOptions(merge: true));
  }

  ContributionActivity? _activityFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final amountRaw = data['amountKes'];
    final amount = amountRaw is int
        ? amountRaw
        : amountRaw is num
            ? amountRaw.toInt()
            : null;
    final createdAt = _timestampToDate(data['createdAt']);
    if (amount == null || createdAt == null) return null;

    return ContributionActivity(
      id: doc.id,
      date: createdAt,
      amountKes: amount,
      paymentMethod: data['paymentMethod'] as String? ?? '—',
      reference: data['reference'] as String? ?? '—',
      status: _statusFromString(data['status'] as String?),
    );
  }

  ContributionPaymentStatus _statusFromString(String? raw) =>
      switch (raw) {
        'pending' => ContributionPaymentStatus.pending,
        'failed' => ContributionPaymentStatus.failed,
        _ => ContributionPaymentStatus.completed,
      };

  DateTime? _timestampToDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
