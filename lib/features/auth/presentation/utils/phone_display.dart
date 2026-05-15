/// Human-readable masked phone for UI subtitles (E.164 input).
String maskE164ForDisplay(String e164) {
  final digits = e164.replaceAll(RegExp(r'\D'), '');
  if (digits.length <= 4) return e164;
  final take = digits.length >= 6 ? 3 : 2;
  final start = digits.substring(0, take);
  final end = digits.substring(digits.length - 2);
  return '+$start ••• $end';
}
