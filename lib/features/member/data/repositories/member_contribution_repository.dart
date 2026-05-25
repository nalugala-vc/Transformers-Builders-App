import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/church_progress_data.dart';
import '../../domain/models/contribution_activity.dart';
import '../../domain/models/member_contribution_summary.dart';

/// Debug-only logger for contribution Firestore calls.
void _log(String event, [Object? detail]) {
  if (!kDebugMode) return;
  final msg = detail != null ? '$event | $detail' : event;
  dev.log(msg, name: 'MemberContribution');
  debugPrint('[MemberContribution] $msg');
}

void _logFirebaseError(String operation, Object error, [StackTrace? st]) {
  if (!kDebugMode) return;
  final code = error is FirebaseException ? error.code : 'unknown';
  final message =
      error is FirebaseException ? (error.message ?? '') : error.toString();
  final msg = '$operation → FirebaseException code=$code message=$message';
  dev.log(msg, name: 'MemberContribution', stackTrace: st, error: error);
  debugPrint('[MemberContribution] $msg');
}

/// Member contribution goal (`users/{uid}`), history (`contributions` subcollection),
/// and church-wide aggregates (`churchProgress/current`).
class MemberContributionRepository {
  MemberContributionRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const churchProgressDocId = 'current';

  CollectionReference<Map<String, dynamic>> _users() =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> _contributions(String uid) =>
      _users().doc(uid).collection('contributions');

  DocumentReference<Map<String, dynamic>> _churchProgressRef() =>
      _firestore.collection('churchProgress').doc(churchProgressDocId);

  Future<MemberContributionSummary> getHomeSummary(String uid) async {
    _log('getHomeSummary', 'uid=$uid');
    final userDoc =
        await _users().doc(uid).get().timeout(const Duration(seconds: 15));
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

    final raisedFromProfile = userData['contributionRaisedKes'];
    final hasRaisedField = raisedFromProfile is num;

    final activities = <ContributionActivity>[];
    var raisedKes = hasRaisedField ? raisedFromProfile.toInt() : 0;

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
        if (!hasRaisedField &&
            activity.status == ContributionPaymentStatus.completed) {
          raisedKes += activity.amountKes;
        }
      }
      _log(
        'getHomeSummary success',
        'uid=$uid target=$targetKes raised=$raisedKes history=${activities.length}',
      );
    } on FirebaseException catch (e, st) {
      _logFirebaseError('getHomeSummary.contributions', e, st);
    } catch (e, st) {
      _logFirebaseError('getHomeSummary.contributions', e, st);
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

  Future<List<ContributionActivity>> listContributions(
    String uid, {
    int limit = 100,
  }) async {
    _log('listContributions', 'uid=$uid limit=$limit');
    try {
      final snap = await _contributions(uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get()
          .timeout(const Duration(seconds: 15));

      final results = [
        for (final doc in snap.docs)
          if (_activityFromDoc(doc) case final activity?) activity,
      ];
      _log('listContributions success', 'uid=$uid count=${results.length}');
      return results;
    } catch (e, st) {
      _logFirebaseError('listContributions', e, st);
      rethrow;
    }
  }

  Future<ChurchProgressData> getChurchProgressData() async {
    _log('getChurchProgressData');
    try {
      final doc = await _churchProgressRef()
          .get()
          .timeout(const Duration(seconds: 15));
      final data = _churchProgressFromDoc(doc.data());
      _log('getChurchProgressData success', 'totalKes=${data.totalKes}');
      return data;
    } catch (e, st) {
      _logFirebaseError('getChurchProgressData', e, st);
      return ChurchProgressData.empty;
    }
  }

  Future<void> setContributionTarget({
    required String uid,
    required int targetKes,
  }) async {
    if (targetKes <= 0) {
      throw ArgumentError.value(
          targetKes, 'targetKes', 'Must be greater than zero');
    }

    _log('setContributionTarget', 'uid=$uid targetKes=$targetKes');
    try {
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
      _log('setContributionTarget success', 'uid=$uid targetKes=$targetKes');
    } catch (e, st) {
      _logFirebaseError('setContributionTarget', e, st);
      rethrow;
    }
  }

  Future<String> createContribution({
    required String uid,
    required int amountKes,
    String paymentMethod = 'Manual',
    String? reference,
    String? notes,
    ContributionPaymentStatus status = ContributionPaymentStatus.completed,
  }) async {
    if (amountKes <= 0) {
      throw ArgumentError.value(
          amountKes, 'amountKes', 'Must be greater than zero');
    }

    _log(
      'createContribution',
      'uid=$uid amountKes=$amountKes method=$paymentMethod status=${_statusToString(status)}',
    );

    try {
      final userSnap = await _users().doc(uid).get();
      final userData = userSnap.data() ?? {};
      final demographicGroupId = userData['demographicGroupId'] as String?;
      final ministryGroupId = userData['ministryGroupId'] as String?;
      final refValue = (reference?.trim().isNotEmpty == true)
          ? reference!.trim()
          : 'MAN-${DateTime.now().millisecondsSinceEpoch}';

      final contributionRef = _contributions(uid).doc();

      await _firestore.runTransaction((txn) async {
        txn.set(contributionRef, {
          'amountKes': amountKes,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'paymentMethod': paymentMethod,
          'reference': refValue,
          'status': _statusToString(status),
          if (demographicGroupId != null)
            'demographicGroupId': demographicGroupId,
          if (ministryGroupId != null && ministryGroupId.isNotEmpty)
            'ministryGroupId': ministryGroupId,
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        });

        if (status == ContributionPaymentStatus.completed) {
          _applyContributionDelta(
            txn,
            uid: uid,
            amountDelta: amountKes,
            demographicGroupId: demographicGroupId,
            ministryGroupId: ministryGroupId,
          );
        }
      });

      _log(
        'createContribution success',
        'uid=$uid id=${contributionRef.id} amountKes=$amountKes',
      );
      return contributionRef.id;
    } catch (e, st) {
      _logFirebaseError('createContribution', e, st);
      rethrow;
    }
  }

  Future<void> updateContribution({
    required String uid,
    required String contributionId,
    int? amountKes,
    String? paymentMethod,
    String? reference,
    String? notes,
    ContributionPaymentStatus? status,
  }) async {
    if (amountKes != null && amountKes <= 0) {
      throw ArgumentError.value(
          amountKes, 'amountKes', 'Must be greater than zero');
    }

    _log(
      'updateContribution',
      'uid=$uid id=$contributionId amountKes=$amountKes status=$status',
    );

    try {
      final contributionRef = _contributions(uid).doc(contributionId);

      await _firestore.runTransaction((txn) async {
        final snap = await txn.get(contributionRef);
        if (!snap.exists) {
          throw StateError('Contribution not found');
        }

        final old = snap.data()!;
        final oldAmount = _readAmount(old['amountKes']);
        final oldStatus = _statusFromString(old['status'] as String?);
        final newAmount = amountKes ?? oldAmount;
        final newStatus = status ?? oldStatus;

        final oldEffect =
            oldStatus == ContributionPaymentStatus.completed ? oldAmount : 0;
        final newEffect =
            newStatus == ContributionPaymentStatus.completed ? newAmount : 0;
        final delta = newEffect - oldEffect;

        final updates = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (amountKes != null) updates['amountKes'] = amountKes;
        if (paymentMethod != null) updates['paymentMethod'] = paymentMethod;
        if (reference != null) updates['reference'] = reference.trim();
        if (notes != null) updates['notes'] = notes.trim();
        if (status != null) updates['status'] = _statusToString(status);

        txn.update(contributionRef, updates);

        if (delta != 0) {
          _applyContributionDelta(
            txn,
            uid: uid,
            amountDelta: delta,
            demographicGroupId: old['demographicGroupId'] as String?,
            ministryGroupId: old['ministryGroupId'] as String?,
          );
        }
      });

      _log('updateContribution success', 'uid=$uid id=$contributionId');
    } catch (e, st) {
      _logFirebaseError('updateContribution', e, st);
      rethrow;
    }
  }

  Future<void> deleteContribution({
    required String uid,
    required String contributionId,
  }) async {
    _log('deleteContribution', 'uid=$uid id=$contributionId');

    try {
      final contributionRef = _contributions(uid).doc(contributionId);

      await _firestore.runTransaction((txn) async {
        final snap = await txn.get(contributionRef);
        if (!snap.exists) return;

        final data = snap.data()!;
        final amount = _readAmount(data['amountKes']);
        final status = _statusFromString(data['status'] as String?);

        txn.delete(contributionRef);

        if (status == ContributionPaymentStatus.completed) {
          _applyContributionDelta(
            txn,
            uid: uid,
            amountDelta: -amount,
            demographicGroupId: data['demographicGroupId'] as String?,
            ministryGroupId: data['ministryGroupId'] as String?,
          );
        }
      });

      _log('deleteContribution success', 'uid=$uid id=$contributionId');
    } catch (e, st) {
      _logFirebaseError('deleteContribution', e, st);
      rethrow;
    }
  }

  void _applyContributionDelta(
    Transaction txn, {
    required String uid,
    required int amountDelta,
    String? demographicGroupId,
    String? ministryGroupId,
  }) {
    if (amountDelta == 0) return;

    txn.set(
      _users().doc(uid),
      {
        'contributionRaisedKes': FieldValue.increment(amountDelta),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    final churchUpdates = <String, dynamic>{
      'totalKes': FieldValue.increment(amountDelta),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (demographicGroupId != null && demographicGroupId.isNotEmpty) {
      churchUpdates['demographics.$demographicGroupId'] =
          FieldValue.increment(amountDelta);
    }
    if (ministryGroupId != null && ministryGroupId.isNotEmpty) {
      churchUpdates['ministries.$ministryGroupId'] =
          FieldValue.increment(amountDelta);
    }

    txn.set(_churchProgressRef(), churchUpdates, SetOptions(merge: true));
  }

  ChurchProgressData _churchProgressFromDoc(Map<String, dynamic>? data) {
    if (data == null) return ChurchProgressData.empty;

    final totalKes = _readAmount(data['totalKes']);
    return ChurchProgressData(
      totalKes: totalKes,
      demographics: _readAmountMap(data['demographics']),
      ministries: _readAmountMap(data['ministries']),
    );
  }

  Map<String, int> _readAmountMap(Object? value) {
    if (value is! Map) return {};
    return {
      for (final entry in value.entries)
        if (entry.key is String && entry.value is num)
          entry.key as String: (entry.value as num).toInt(),
    };
  }

  int _readAmount(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  ContributionActivity? _activityFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final amount = _readAmount(data['amountKes']);
    if (amount <= 0) return null;
    final createdAt = _timestampToDate(data['createdAt']);
    if (createdAt == null) return null;

    return ContributionActivity(
      id: doc.id,
      date: createdAt,
      amountKes: amount,
      paymentMethod: data['paymentMethod'] as String? ?? 'Manual',
      reference: data['reference'] as String? ?? '—',
      status: _statusFromString(data['status'] as String?),
      notes: data['notes'] as String?,
    );
  }

  ContributionPaymentStatus _statusFromString(String? raw) =>
      switch (raw) {
        'pending' => ContributionPaymentStatus.pending,
        'failed' => ContributionPaymentStatus.failed,
        _ => ContributionPaymentStatus.completed,
      };

  String _statusToString(ContributionPaymentStatus status) => switch (status) {
        ContributionPaymentStatus.pending => 'pending',
        ContributionPaymentStatus.failed => 'failed',
        ContributionPaymentStatus.completed => 'completed',
      };

  DateTime? _timestampToDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
