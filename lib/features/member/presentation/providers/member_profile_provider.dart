import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/utils/phone_e164.dart';
import '../../../../core/utils/user_initials.dart';
import '../../domain/models/member_group.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/user_profile_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/member_profile_ui_state.dart';
import 'contribution_refresh.dart';
import 'member_contribution_providers.dart';
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

  final canChangePassword = AuthRepository.hasEmailPasswordProvider(firebaseUser);
  final usesGoogleSignIn = firebaseUser.providerData.any(
    (info) => info.providerId == 'google.com',
  );

  return MemberProfileUiState(
    fullName: fullName,
    email: email,
    phoneE164: profile?.phoneE164,
    demographicGroupId: profile?.demographicGroupId,
    ministryGroupId: profile?.ministryGroupId,
    initials: initialsForName(fullName),
    pushNotificationsEnabled: ref.watch(memberPushNotificationsProvider),
    appVersionLabel: AppVersion.label,
    canChangePassword: canChangePassword,
    usesGoogleSignIn: usesGoogleSignIn,
  );
});

/// Updates display name in Firebase Auth + Firestore, then refreshes profile UI.
Future<String?> updateMemberFullName(
  WidgetRef ref,
  AppLocalizations l10n,
  String fullName,
) async {
  final trimmed = fullName.trim();
  if (trimmed.length < 2) {
    return l10n.errorEnterName;
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return l10n.errorSomethingWrong;

  try {
    await ref.read(authRepositoryProvider).updateDisplayName(user, trimmed);
    await ref.read(userProfileRepositoryProvider).updateFullName(user.uid, trimmed);
    ref.invalidate(memberProfileUiProvider);
    return null;
  } on FirebaseAuthException catch (e) {
    return e.message ?? l10n.errorCouldNotUpdateName;
  } catch (_) {
    return l10n.errorCouldNotUpdateName;
  }
}

/// Re-authenticates with the current password, then sets a new one.
Future<String?> updateMemberPassword(
  WidgetRef ref,
  AppLocalizations l10n, {
  required String email,
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  if (currentPassword.isEmpty) {
    return l10n.errorEnterPassword;
  }
  if (newPassword.isEmpty) {
    return l10n.errorEnterPassword;
  }
  if (newPassword.length < 8) {
    return l10n.errorUseEightCharacters;
  }
  if (newPassword != confirmPassword) {
    return l10n.errorPasswordsMismatch;
  }
  if (currentPassword == newPassword) {
    return l10n.errorChooseDifferentPassword;
  }

  try {
    final auth = ref.read(authRepositoryProvider);
    await auth.reauthenticateWithEmailPassword(
      email: email,
      password: currentPassword,
    );
    await auth.updatePassword(newPassword);
    return null;
  } on FirebaseAuthException catch (e) {
    return switch (e.code) {
      'wrong-password' || 'invalid-credential' => l10n.errorCurrentPasswordIncorrect,
      'weak-password' => l10n.errorWeakPassword,
      'requires-recent-login' => l10n.errorRecentLoginRequired,
      _ => e.message ?? l10n.errorCouldNotUpdatePassword,
    };
  } catch (_) {
    return l10n.errorCouldNotUpdatePassword;
  }
}

/// Verifies new email (Firebase) and updates Firestore; may require current password.
Future<String?> updateMemberEmail(
  WidgetRef ref,
  AppLocalizations l10n, {
  required String currentEmail,
  required String newEmail,
  required bool requiresPasswordReauth,
  String? currentPassword,
}) async {
  final trimmed = newEmail.trim();
  if (!isValidEmail(trimmed)) {
    return l10n.errorValidEmail;
  }
  if (trimmed.toLowerCase() == currentEmail.trim().toLowerCase()) {
    return l10n.errorAlreadyYourEmail;
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return l10n.errorSomethingWrong;

  try {
    final auth = ref.read(authRepositoryProvider);
    if (requiresPasswordReauth) {
      if (currentPassword == null || currentPassword.isEmpty) {
        return l10n.errorEnterPassword;
      }
      await auth.reauthenticateWithEmailPassword(
        email: currentEmail,
        password: currentPassword,
      );
    }
    await auth.verifyBeforeUpdateEmail(trimmed);
    await ref.read(userProfileRepositoryProvider).updateEmail(user.uid, trimmed);
    ref.invalidate(memberProfileUiProvider);
    return null;
  } on FirebaseAuthException catch (e) {
    return switch (e.code) {
      'email-already-in-use' => l10n.errorEmailInUse,
      'invalid-email' => l10n.errorValidEmail,
      'requires-recent-login' => l10n.errorRecentLoginRequired,
      'wrong-password' || 'invalid-credential' => l10n.errorCurrentPasswordIncorrect,
      _ => e.message ?? l10n.errorCouldNotUpdateEmail,
    };
  } catch (_) {
    return l10n.errorCouldNotUpdateEmail;
  }
}

Future<String?> updateMemberPhone(
  WidgetRef ref,
  AppLocalizations l10n, {
  required String phoneE164,
}) async {
  final trimmed = phoneE164.trim();
  if (trimmed.length < 10) {
    return l10n.errorValidPhone;
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return l10n.errorSomethingWrong;

  try {
    await ref.read(userProfileRepositoryProvider).updatePhone(user.uid, trimmed);
    ref.invalidate(memberProfileUiProvider);
    return null;
  } catch (_) {
    return l10n.errorCouldNotUpdatePhone;
  }
}

Future<String?> updateMemberGroups(
  WidgetRef ref,
  AppLocalizations l10n, {
  required String? demographicGroupId,
  required String? ministryGroupId,
}) async {
  final demographic = MemberGroups.findDemographicById(demographicGroupId);
  if (demographic == null) {
    return l10n.errorSelectDemographic;
  }

  final ministryId = ministryGroupId?.trim();
  final ministry = ministryId == null || ministryId.isEmpty
      ? null
      : MemberGroups.findMinistryById(ministryId);
  if (ministryId != null && ministryId.isNotEmpty && ministry == null) {
    return l10n.errorValidMinistry;
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return l10n.errorSomethingWrong;

  try {
    final profileRepo = ref.read(userProfileRepositoryProvider);
    final previous = await profileRepo.getUser(user.uid);
    final oldDemographic = previous?.demographicGroupId;
    final oldMinistry = previous?.ministryGroupId;

    await profileRepo.setMemberGroups(
      uid: user.uid,
      demographicGroupId: demographic.id,
      ministryGroupId: ministry?.id,
    );

    // Move this member's personal target between groups so per-group church
    // targets stay accurate. No-op if the member has no target yet.
    await ref.read(memberContributionRepositoryProvider).rebalanceTargetsForGroupChange(
          uid: user.uid,
          oldDemographic: oldDemographic,
          newDemographic: demographic.id,
          oldMinistry: oldMinistry,
          newMinistry: ministry?.id,
        );

    ref.invalidate(memberProfileUiProvider);
    invalidateContributionData(ref);
    return null;
  } catch (_) {
    return l10n.errorCouldNotUpdateGroups;
  }
}

/// Sends a password-reset email so Google-only users can set a password.
Future<String?> sendPasswordSetupEmail(WidgetRef ref, String email) async {
  final trimmed = email.trim();
  if (trimmed.isEmpty) {
    return 'No email on this account';
  }
  try {
    await ref.read(authRepositoryProvider).sendPasswordResetEmail(trimmed);
    return null;
  } on FirebaseAuthException catch (e) {
    return e.message ?? 'Could not send email';
  } catch (_) {
    return 'Could not send email. Try again.';
  }
}
