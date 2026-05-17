const _monthLabels = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatKes(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer('KES ');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String formatActivityDate(DateTime date) {
  return '${_monthLabels[date.month - 1]} ${date.day}';
}

String formatDisplayDate(DateTime date) {
  return '${_monthLabels[date.month - 1]} ${date.day}, ${date.year}';
}

String firstNameFromFullName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return 'Member';
  return trimmed.split(RegExp(r'\s+')).first;
}
