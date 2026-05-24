import '../../../../core/l10n/member_group_l10n.dart';
import '../../../../l10n/app_localizations.dart';
import 'member_group.dart';

class MemberProfileUiState {
  const MemberProfileUiState({
    required this.fullName,
    required this.email,
    required this.phoneE164,
    required this.demographicGroupId,
    required this.ministryGroupId,
    required this.initials,
    required this.pushNotificationsEnabled,
    required this.appVersionLabel,
    required this.canChangePassword,
    required this.usesGoogleSignIn,
  });

  final String fullName;
  final String email;
  final String? phoneE164;
  final String? demographicGroupId;
  final String? ministryGroupId;
  final String initials;
  final bool pushNotificationsEnabled;
  final String appVersionLabel;
  final bool canChangePassword;
  final bool usesGoogleSignIn;

  String get passwordSubtitleKey => switch ((canChangePassword, usesGoogleSignIn)) {
        (true, _) => 'hidden',
        (false, true) => 'google',
        _ => 'emailLink',
      };

  String phoneSubtitle(AppLocalizations l10n) =>
      phoneE164 != null && phoneE164!.isNotEmpty ? phoneE164! : l10n.notSet;

  String demographicSubtitle(AppLocalizations l10n) {
    final group = MemberGroups.findDemographicById(demographicGroupId);
    return group == null ? l10n.notSet : group.localizedLabel(l10n);
  }

  String ministrySubtitle(AppLocalizations l10n) {
    final group = MemberGroups.findMinistryById(ministryGroupId);
    return group == null ? l10n.none : group.localizedLabel(l10n);
  }

  String passwordSubtitleLocalized(AppLocalizations l10n) =>
      switch (passwordSubtitleKey) {
        'google' => l10n.googleSignIn,
        'emailLink' => l10n.setViaEmailLink,
        _ => l10n.passwordHidden,
      };
}
