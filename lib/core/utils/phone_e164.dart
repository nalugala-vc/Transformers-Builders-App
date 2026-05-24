import 'package:country_code_picker/country_code_picker.dart';

/// Builds E.164 from [CountryCode.dialCode] and national digits (registration/profile).
String buildE164Phone({
  required CountryCode countryCode,
  required String nationalDigits,
}) {
  var d = nationalDigits.replaceAll(RegExp(r'\D'), '');
  if (d.startsWith('0')) d = d.substring(1);
  final dial = (countryCode.dialCode ?? '').replaceAll(RegExp(r'\D'), '');
  return '+$dial$d';
}

/// Best-effort parse of stored E.164 for editing (defaults to Kenya).
({CountryCode countryCode, String nationalDigits}) parseE164Phone(String? phoneE164) {
  const favorites = ['+254', '+255', '+256', '+250', '+1'];
  if (phoneE164 != null && phoneE164.isNotEmpty) {
    for (final dial in favorites) {
      if (phoneE164.startsWith(dial)) {
        var national = phoneE164.substring(dial.length);
        if (national.startsWith('0')) national = national.substring(1);
        final code = CountryCode.fromDialCode(dial);
        return (countryCode: code, nationalDigits: national);
      }
    }
    final digits = phoneE164.replaceAll(RegExp(r'\D'), '');
    return (
      countryCode: CountryCode.tryFromCountryCode('KE') ?? CountryCode.fromCountryCode('US'),
      nationalDigits: digits,
    );
  }
  return (
    countryCode: CountryCode.tryFromCountryCode('KE') ?? CountryCode.fromCountryCode('US'),
    nationalDigits: '',
  );
}

bool isValidEmail(String email) {
  final trimmed = email.trim();
  return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(trimmed);
}
