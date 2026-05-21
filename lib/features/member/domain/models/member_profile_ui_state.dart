class MemberProfileUiState {
  const MemberProfileUiState({
    required this.fullName,
    required this.email,
    required this.phoneE164,
    required this.initials,
    required this.languageCode,
    required this.pushNotificationsEnabled,
    required this.appVersionLabel,
    required this.canChangePassword,
    required this.usesGoogleSignIn,
  });

  final String fullName;
  final String email;
  final String? phoneE164;
  final String initials;
  final String languageCode;
  final bool pushNotificationsEnabled;
  final String appVersionLabel;
  final bool canChangePassword;
  final bool usesGoogleSignIn;

  String get passwordSubtitle => switch ((canChangePassword, usesGoogleSignIn)) {
        (true, _) => '••••••••',
        (false, true) => 'Google sign-in',
        _ => 'Set via email link',
      };

  String get languageLabel =>
      MemberProfileUiState._languageLabelFor(languageCode);

  static String _languageLabelFor(String code) => switch (code) {
        'sw' => 'Kiswahili',
        _ => 'English',
      };
}
