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

  static const english = MemberLanguageOption(code: 'en', label: 'English');
  static const swahili = MemberLanguageOption(code: 'sw', label: 'Kiswahili');

  static const List<MemberLanguageOption> all = [english, swahili];

  static MemberLanguageOption fromCode(String code) {
    return all.firstWhere(
      (o) => o.code == code,
      orElse: () => english,
    );
  }
}
