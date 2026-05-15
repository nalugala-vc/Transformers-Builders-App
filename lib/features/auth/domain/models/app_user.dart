import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_role.dart';

/// Firestore-backed user profile (`users/{uid}`).
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneE164,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phoneE164;
  final DateTime? createdAt;

  bool get isAdmin => role == UserRole.admin;
  bool get isMember => role == UserRole.member;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final created = data['createdAt'];
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String?),
      phoneE164: data['phone'] as String?,
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role.name,
      if (phoneE164 != null) 'phone': phoneE164,
    };
  }
}
