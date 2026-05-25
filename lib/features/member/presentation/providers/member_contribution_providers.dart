import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/member_contribution_repository.dart';
import '../../domain/models/contribution_activity.dart';
import 'contribution_refresh.dart';

final memberContributionRepositoryProvider = Provider<MemberContributionRepository>(
  (ref) => MemberContributionRepository(),
);

/// All contributions for the signed-in member (history screen).
final memberContributionsListProvider =
    FutureProvider<List<ContributionActivity>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) throw StateError('No signed-in user.');
  return ref.read(memberContributionRepositoryProvider).listContributions(uid);
});

String _userMessageForError(Object error, String fallback) {
  if (error is FirebaseException) {
    if (error.code == 'permission-denied') {
      return 'Permission denied. Deploy Firestore rules and try again.';
    }
    final detail = error.message ?? error.code;
    return '$fallback ($detail)';
  }
  if (error is TimeoutException) {
    return 'Request timed out. Check your connection and try again.';
  }
  return fallback;
}

void _logProviderError(String op, Object error, StackTrace st) {
  if (!kDebugMode) return;
  debugPrint('[MemberContribution] $op → $error');
  debugPrint(st.toString());
}

Future<String?> createMemberContribution(
  WidgetRef ref, {
  required int amountKes,
  required String paymentMethod,
  String? reference,
  String? notes,
  ContributionPaymentStatus status = ContributionPaymentStatus.completed,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return 'You are signed out. Please sign in again.';

  try {
    await ref.read(memberContributionRepositoryProvider).createContribution(
          uid: uid,
          amountKes: amountKes,
          paymentMethod: paymentMethod,
          reference: reference,
          notes: notes,
          status: status,
        );
    invalidateContributionData(ref);
    return null;
  } catch (e, st) {
    _logProviderError('createMemberContribution', e, st);
    return _userMessageForError(e, 'Could not save contribution. Please try again.');
  }
}

Future<String?> updateMemberContribution(
  WidgetRef ref, {
  required String contributionId,
  int? amountKes,
  String? paymentMethod,
  String? reference,
  String? notes,
  ContributionPaymentStatus? status,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return 'You are signed out. Please sign in again.';

  try {
    await ref.read(memberContributionRepositoryProvider).updateContribution(
          uid: uid,
          contributionId: contributionId,
          amountKes: amountKes,
          paymentMethod: paymentMethod,
          reference: reference,
          notes: notes,
          status: status,
        );
    invalidateContributionData(ref);
    return null;
  } catch (e, st) {
    _logProviderError('updateMemberContribution', e, st);
    return _userMessageForError(e, 'Could not update contribution. Please try again.');
  }
}

Future<String?> deleteMemberContribution(
  WidgetRef ref, {
  required String contributionId,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return 'You are signed out. Please sign in again.';

  try {
    await ref.read(memberContributionRepositoryProvider).deleteContribution(
          uid: uid,
          contributionId: contributionId,
        );
    invalidateContributionData(ref);
    return null;
  } catch (e, st) {
    _logProviderError('deleteMemberContribution', e, st);
    return _userMessageForError(e, 'Could not delete contribution. Please try again.');
  }
}
