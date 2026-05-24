import '../../../../core/l10n/l10n_extension.dart';
import '../../../../l10n/app_localizations.dart';

class MemberLanguageOption {
  const MemberLanguageOption({
    required this.code,
    required this.label,
  });

  final String code;
  final String label;
}

abstract final class MemberLanguageOptions {
  MemberLanguageOptions._();

  static const codes = ['en', 'fr', 'sw'];

  static List<MemberLanguageOption> all(AppLocalizations l10n) => [
        MemberLanguageOption(code: 'en', label: l10n.languageEnglish),
        MemberLanguageOption(code: 'fr', label: l10n.languageFrench),
        MemberLanguageOption(code: 'sw', label: l10n.languageSwahili),
      ];

  static MemberLanguageOption fromCode(String code, AppLocalizations l10n) {
    return all(l10n).firstWhere(
      (o) => o.code == code,
      orElse: () => MemberLanguageOption(code: 'en', label: l10n.languageEnglish),
    );
  }
}
