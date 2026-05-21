import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../member/domain/models/member_group.dart';
import 'user_role.dart';

/// Firestore-backed user profile (`users/{uid}`).
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneE164,
    this.demographicGroupId,
    this.ministryGroupId,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phoneE164;
  final String? demographicGroupId;
  final String? ministryGroupId;
  final DateTime? createdAt;

  MemberGroup? get demographicGroup => MemberGroups.findDemographicById(demographicGroupId);

  MemberGroup? get ministryGroup => MemberGroups.findMinistryById(ministryGroupId);

  /// True when the required demographic group is saved (ministry is optional).
  bool get hasCompleteMemberGroups =>
      demographicGroupId != null && demographicGroupId!.isNotEmpty;

  bool get isAdmin => role == UserRole.admin;
  bool get isMember => role == UserRole.member;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final created = data['createdAt'];

    var demographicId = data['demographicGroupId'] as String?;
    var ministryId = data['ministryGroupId'] as String?;

    // Legacy single-group fields.
    final legacyId = data['memberGroupId'] as String?;
    final legacyCategory = data['memberGroupCategory'] as String?;
    if (legacyId != null && legacyId.isNotEmpty) {
      if (legacyCategory == 'demographics' && (demographicId == null || demographicId.isEmpty)) {
        demographicId = legacyId;
      }
      if (legacyCategory == 'ministry' && (ministryId == null || ministryId.isEmpty)) {
        ministryId = legacyId;
      }
    }

    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String?),
      phoneE164: data['phone'] as String?,
      demographicGroupId: demographicId,
      ministryGroupId: ministryId,
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role.name,
      if (phoneE164 != null) 'phone': phoneE164,
      if (demographicGroupId case final String id) 'demographicGroupId': id,
      if (ministryGroupId case final String id) 'ministryGroupId': id,
    };
  }
}
