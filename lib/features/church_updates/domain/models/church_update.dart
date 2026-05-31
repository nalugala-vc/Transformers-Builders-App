import 'package:cloud_firestore/cloud_firestore.dart';

import 'church_update_attachment.dart';

/// A church-wide announcement published by an admin (`churchUpdates/{id}`).
class ChurchUpdate {
  const ChurchUpdate({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.createdByUid,
    this.createdByName,
    this.attachments = const [],
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String createdByUid;
  final String? createdByName;
  final List<ChurchUpdateAttachment> attachments;

  bool get hasAttachments => attachments.isNotEmpty;

  factory ChurchUpdate.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final created = data['createdAt'];
    final rawAttachments = data['attachments'];

    final attachments = <ChurchUpdateAttachment>[];
    if (rawAttachments is List) {
      for (final item in rawAttachments) {
        if (item is Map) {
          attachments.add(
            ChurchUpdateAttachment.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return ChurchUpdate(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      createdByUid: data['createdByUid'] as String? ?? '',
      createdByName: data['createdByName'] as String?,
      attachments: attachments,
    );
  }
}
