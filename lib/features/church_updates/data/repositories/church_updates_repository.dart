import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/church_update.dart';

void _log(String event, [Object? detail]) {
  if (!kDebugMode) return;
  final msg = detail != null ? '$event | $detail' : event;
  dev.log(msg, name: 'ChurchUpdates');
  debugPrint('[ChurchUpdates] $msg');
}

void _logError(String op, Object e, [StackTrace? st]) {
  if (!kDebugMode) return;
  final code = e is FirebaseException ? e.code : 'unknown';
  final message = e is FirebaseException ? (e.message ?? '') : e.toString();
  dev.log('$op → $code $message', name: 'ChurchUpdates', error: e, stackTrace: st);
  debugPrint('[ChurchUpdates] $op → $code $message');
}

class ChurchUpdatesRepository {
  ChurchUpdatesRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _updates =>
      _firestore.collection('churchUpdates');

  /// Published announcements, newest first (member Updates tab).
  ///
  /// Uses `orderBy('createdAt')` only so this works without waiting for a
  /// composite `published + createdAt` index. Unpublished docs (if any) are
  /// filtered out client-side.
  Future<List<ChurchUpdate>> listPublished({int limit = 50}) async {
    _log('listPublished', 'limit=$limit');
    try {
      final snap = await _updates
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get()
          .timeout(const Duration(seconds: 15));

      final results = <ChurchUpdate>[];
      for (final doc in snap.docs) {
        final published = doc.data()['published'];
        if (published == false) continue;
        results.add(ChurchUpdate.fromFirestore(doc));
      }

      _log('listPublished success', 'count=${results.length}');
      return results;
    } catch (e, st) {
      _logError('listPublished', e, st);
      rethrow;
    }
  }

  /// All updates for the admin Updates tab (same query for now).
  Future<List<ChurchUpdate>> listForAdmin({int limit = 50}) =>
      listPublished(limit: limit);

  Future<String> publishUpdate({
    required String title,
    required String body,
    required String createdByUid,
    String? createdByName,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedBody = body.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Title is required');
    }
    if (trimmedBody.isEmpty) {
      throw ArgumentError.value(body, 'body', 'Body is required');
    }

    _log('publishUpdate', 'uid=$createdByUid title=$trimmedTitle');
    try {
      final ref = _updates.doc();
      await ref.set({
        'title': trimmedTitle,
        'body': trimmedBody,
        'createdAt': FieldValue.serverTimestamp(),
        'createdByUid': createdByUid,
        if (createdByName != null && createdByName.trim().isNotEmpty)
          'createdByName': createdByName.trim(),
        'published': true,
      });
      _log('publishUpdate success', 'id=${ref.id}');
      return ref.id;
    } catch (e, st) {
      _logError('publishUpdate', e, st);
      rethrow;
    }
  }
}
