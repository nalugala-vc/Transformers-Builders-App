import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_version.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/user_profile_providers.dart';
import '../../domain/models/member_profile_ui_state.dart';
import 'member_profile_settings_provider.dart';

final memberProfileUiProvider = FutureProvider<MemberProfileUiState>((ref) async {
  ref.keepAlive();

  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser == null) {
    throw StateError('No signed-in user.');
  }

  final profile = await ref.read(userProfileRepositoryProvider).getUser(firebaseUser.uid);
  final fullName = profile?.fullName.trim().isNotEmpty == true
      ? profile!.fullName.trim()
      : (firebaseUser.displayName?.trim().isNotEmpty == true
          ? firebaseUser.displayName!.trim()
          : 'Member');
  final email = profile?.email ?? firebaseUser.email ?? '';

  return MemberProfileUiState(
    fullName: fullName,
    email: email,
    phoneE164: profile?.phoneE164,
    initials: _initialsFor(fullName),
    languageCode: ref.watch(memberLanguageCodeProvider),
    pushNotificationsEnabled: ref.watch(memberPushNotificationsProvider),
    appVersionLabel: AppVersion.label,
  );
});

String _initialsFor(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  final list = parts.toList();
  if (list.isEmpty) return 'M';
  if (list.length == 1) {
    return list.first.substring(0, 1).toUpperCase();
  }
  return '${list.first[0]}${list.last[0]}'.toUpperCase();
}

/// Updates display name in Firebase Auth + Firestore, then refreshes profile UI.
Future<String?> updateMemberFullName(WidgetRef ref, String fullName) async {
  final trimmed = fullName.trim();
  if (trimmed.length < 2) {
    return 'Enter at least 2 characters';
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 'You are not signed in';

  try {
    await ref.read(authRepositoryProvider).updateDisplayName(user, trimmed);
    await ref.read(userProfileRepositoryProvider).updateFullName(user.uid, trimmed);
    ref.invalidate(memberProfileUiProvider);
    return null;
  } on FirebaseAuthException catch (e) {
    return e.message ?? 'Could not update name';
  } catch (_) {
    return 'Could not update name. Try again.';
  }
}
