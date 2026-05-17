import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/app_user.dart';
import '../../domain/models/user_role.dart';
import '../firebase_auth_logger.dart';

/// Persists user profiles and roles in Firestore (`users` collection).
class UserProfileRepository {
  UserProfileRepository([FirebaseFirestore? firestore]) : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<AppUser?> getUser(String uid) async {
    logAuthFirestore('getUser', 'uid=$uid');
    final doc = await _users.doc(uid).get();
    if (!doc.exists) {
      logAuthFirestore('getUser', 'uid=$uid → not found');
      return null;
    }
    final user = AppUser.fromFirestore(doc);
    logAuthFirestore('getUser', 'uid=$uid → role=${user.role}');
    return user;
  }

  /// Creates a new profile with role **[UserRole.member]** (default for self-service registration).
  /// Admins are assigned in Firestore by an existing admin or the console.
  Future<void> createMemberProfile({
    required String uid,
    required String email,
    required String fullName,
    String? phoneE164,
  }) async {
    final ref = _users.doc(uid);
    await ref
        .set({
          'email': email.trim(),
          'fullName': fullName.trim(),
          'role': UserRole.member.name,
          if (phoneE164 != null && phoneE164.isNotEmpty) 'phone': phoneE164,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException(
            'Could not reach the server. Check your connection and try again.',
          ),
        );
    logAuthFirestore(
      'createMemberProfile',
      'uid=$uid email=$email role=${UserRole.member.name}',
    );
  }

  Future<void> updateFullName(String uid, String fullName) async {
    logAuthFirestore('updateFullName', 'uid=$uid');
    await _users.doc(uid).update({
      'fullName': fullName.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    logAuthFirestore('updateFullName', 'uid=$uid success');
  }

  Future<void> updatePhone(String uid, String phoneE164) async {
    logAuthFirestore('updatePhone', 'uid=$uid');
    await _users.doc(uid).update({
      'phone': phoneE164,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    logAuthFirestore('updatePhone', 'uid=$uid success');
  }

  /// Ensures a profile exists for the signed-in Firebase user (defaults to member).
  Future<AppUser> ensureProfileForCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw StateError('No signed-in user.');
    }

    logAuthFirestore('ensureProfileForCurrentUser', 'uid=${firebaseUser.uid}');
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
    logAuthFirestore('ensureProfileForCurrentUser', 'created uid=${created.uid}');
    return created;
  }

  Future<UserRole> getRoleForCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw StateError('No signed-in user.');
    }
    final profile = await getUser(firebaseUser.uid);
    if (profile != null) {
      logAuthFirestore('getRoleForCurrentUser', 'role=${profile.role}');
      return profile.role;
    }
    final role = (await ensureProfileForCurrentUser()).role;
    logAuthFirestore('getRoleForCurrentUser', 'role=$role (after ensure)');
    return role;
  }
}
