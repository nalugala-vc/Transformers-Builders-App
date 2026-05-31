/// Builds one- or two-letter initials from a display name.
String initialsForName(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  final list = parts.toList();
  if (list.isEmpty) return 'M';
  if (list.length == 1) {
    return list.first.substring(0, 1).toUpperCase();
  }
  return '${list.first[0]}${list.last[0]}'.toUpperCase();
}
