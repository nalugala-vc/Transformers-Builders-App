/// Path strings for [GoRouter]. Use these with [GoRouter.go] / [GoRouter.push] so navigation
/// stays correct across hot reload (unlike [GoRouter.goNamed], which can assert if names desync).
abstract final class AppRoutePaths {
  AppRoutePaths._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp';
  static const String home = '/home';
  static const String sizes = '/sizes';
}
