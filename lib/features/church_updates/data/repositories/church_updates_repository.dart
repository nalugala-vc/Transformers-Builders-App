import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/church_update.dart';
import '../../domain/models/church_update_attachment.dart';

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
  ChurchUpdatesRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const maxAttachments = 5;
  static const maxAttachmentBytes = 10 * 1024 * 1024;

  CollectionReference<Map<String, dynamic>> get _updates =>
      _firestore.collection('churchUpdates');

  /// Published announcements, newest first (member Updates tab).
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

  Future<List<ChurchUpdate>> listForAdmin({int limit = 50}) =>
      listPublished(limit: limit);

  Future<String> publishUpdate({
    required String title,
    required String body,
    required String createdByUid,
    String? createdByName,
    List<PlatformFile> attachments = const [],
  }) async {
    final trimmedTitle = title.trim();
    final trimmedBody = body.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Title is required');
    }
    if (trimmedBody.isEmpty) {
      throw ArgumentError.value(body, 'body', 'Body is required');
    }
    if (attachments.length > maxAttachments) {
      throw ArgumentError.value(
        attachments,
        'attachments',
        'Too many attachments',
      );
    }

    _log('publishUpdate', 'uid=$createdByUid title=$trimmedTitle');
    try {
      final ref = _updates.doc();
      final uploaded = attachments.isEmpty
          ? <ChurchUpdateAttachment>[]
          : await _uploadAttachments(updateId: ref.id, files: attachments);

      await ref.set({
        'title': trimmedTitle,
        'body': trimmedBody,
        'createdAt': FieldValue.serverTimestamp(),
        'createdByUid': createdByUid,
        if (createdByName != null && createdByName.trim().isNotEmpty)
          'createdByName': createdByName.trim(),
        'published': true,
        if (uploaded.isNotEmpty)
          'attachments': uploaded.map((a) => a.toMap()).toList(),
      });
      _log('publishUpdate success', 'id=${ref.id} attachments=${uploaded.length}');
      return ref.id;
    } catch (e, st) {
      _logError('publishUpdate', e, st);
      rethrow;
    }
  }

  Future<List<ChurchUpdateAttachment>> _uploadAttachments({
    required String updateId,
    required List<PlatformFile> files,
  }) async {
    final results = <ChurchUpdateAttachment>[];

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final name = _safeFileName(file.name);
      final size = file.size;

      if (size > maxAttachmentBytes) {
        throw ArgumentError.value(file.name, 'file', 'File too large');
      }

      final contentType = churchUpdateAttachmentContentType(name);
      final kind = ChurchUpdateAttachment.fromMap({
        'name': name,
        'contentType': contentType,
      }).kind;

      final storagePath =
          'churchUpdates/$updateId/${DateTime.now().millisecondsSinceEpoch}_${i}_$name';
      final storageRef = _storage.ref(storagePath);

      _log('uploadAttachment', 'path=$storagePath size=$size');

      if (file.bytes == null) {
        throw StateError('Could not read file: ${file.name}');
      }

      await storageRef.putData(
        file.bytes!,
        SettableMetadata(contentType: contentType),
      );

      final url = await storageRef.getDownloadURL();
      results.add(
        ChurchUpdateAttachment(
          name: name,
          url: url,
          contentType: contentType,
          sizeBytes: size,
          kind: kind,
        ),
      );
    }

    return results;
  }

  String _safeFileName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'attachment';
    return trimmed.replaceAll(RegExp(r'[^\w.\-() ]'), '_');
  }
}
