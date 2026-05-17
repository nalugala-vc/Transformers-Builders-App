/// Firebase Phone Auth (reCAPTCHA) opens a browser/SFSafariViewController and
/// returns via a custom URL. Flutter deep linking can surface that as `/link`
/// or `…://firebaseauth/link`, which [GoRouter] would otherwise treat as an
/// unknown route.
bool isFirebaseAuthRecaptchaCallback(Uri uri) {
  final path = uri.path;
  if (path == '/link' || path.endsWith('/link')) {
    return true;
  }
  if (uri.host == 'firebaseauth') {
    return true;
  }
  final raw = uri.toString();
  if (raw.contains('firebaseauth') && raw.contains('link')) {
    return true;
  }
  if (uri.scheme.startsWith('com.googleusercontent.apps') && path.contains('link')) {
    return true;
  }
  return false;
}
