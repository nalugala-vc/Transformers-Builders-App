import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/app_user.dart';
import '../../domain/models/user_role.dart';

/// Persists user profiles and roles in Firestore (`users` collection).
class UserProfileRepository {
  UserProfileRepository([FirebaseFirestore? firestore]) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  /// Creates a new profile with [UserRole.member]. Fails if the document already exists.
  Future<void> createMemberProfile({
    required String uid,
    required String email,
    required String fullName,
    String? phoneE164,
  }) async {
    final ref = _users.doc(uid);
    final existing = await ref.get();
    if (existing.exists) return;

    await ref.set({
      'email': email.trim(),
      'fullName': fullName.trim(),
      'role': UserRole.member.name,
      if (phoneE164 != null && phoneE164.isNotEmpty) 'phone': phoneE164,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePhone(String uid, String phoneE164) async {
    await _users.doc(uid).update({
      'phone': phoneE164,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Ensures a profile exists for the signed-in Firebase user (defaults to member).
  Future<AppUser> ensureProfileForCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw StateError('No signed-in user.');
    }

    final existing = await getUser(firebaseUser.uid);
    if (existing != null) return existing;

    await createMemberProfile(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: firebaseUser.displayName ?? '',
    );
    final created = await getUser(firebaseUser.uid);
    if (created == null) {
      throw StateError('Failed to create user profile.');
    }
    return created;
  }

  Future<UserRole> getRoleForCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw StateError('No signed-in user.');
    }
    final profile = await getUser(firebaseUser.uid);
    if (profile != null) return profile.role;
    return (await ensureProfileForCurrentUser()).role;
  }
}
