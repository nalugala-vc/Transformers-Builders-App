import 'package:cloud_firestore/cloud_firestore.dart';

/// A church-wide announcement published by an admin (`churchUpdates/{id}`).
class ChurchUpdate {
  const ChurchUpdate({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.createdByUid,
    this.createdByName,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String createdByUid;
  final String? createdByName;

  factory ChurchUpdate.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final created = data['createdAt'];
    return ChurchUpdate(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      createdByUid: data['createdByUid'] as String? ?? '',
      createdByName: data['createdByName'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title.trim(),
      'body': body.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'createdByUid': createdByUid,
      if (createdByName != null && createdByName!.trim().isNotEmpty)
        'createdByName': createdByName!.trim(),
      'published': true,
    };
  }
}
