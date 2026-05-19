/// Parses Firebase Auth email action links (`mode` + `oobCode` query params).
String? passwordResetCodeFromUri(Uri uri) {
  final params = _mergedQueryParams(uri);
  if (params['mode'] != 'resetPassword') return null;
  final code = params['oobCode']?.trim();
  if (code == null || code.isEmpty) return null;
  return code;
}

bool isPasswordResetActionLink(Uri uri) => passwordResetCodeFromUri(uri) != null;

Map<String, String> _mergedQueryParams(Uri uri) {
  final merged = Map<String, String>.from(uri.queryParameters);
  if (uri.fragment.isEmpty) return merged;

  final fragment = uri.fragment;
  final queryStart = fragment.indexOf('?');
  final fragmentQuery = queryStart >= 0 ? fragment.substring(queryStart + 1) : fragment;
  for (final part in fragmentQuery.split('&')) {
    if (part.isEmpty) continue;
    final eq = part.indexOf('=');
    if (eq <= 0) continue;
    final key = Uri.decodeComponent(part.substring(0, eq));
    final value = Uri.decodeComponent(part.substring(eq + 1));
    merged.putIfAbsent(key, () => value);
  }
  return merged;
}
