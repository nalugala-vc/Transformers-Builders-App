import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_route_paths.dart';
import '../../features/auth/presentation/models/otp_route_extra.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/responsive_sizes_screen.dart';

/// First route after app start — must match [GoRouter.initialLocation].
const String appInitialLocation = AppRoutePaths.splash;

/// Central place for all app routes.
final GoRouter appRouter = GoRouter(
  initialLocation: appInitialLocation,
  routes: [
    GoRoute(
      path: AppRoutePaths.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.register,
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'];
        return ForgotPasswordScreen(initialEmail: email);
      },
    ),
    GoRoute(
      path: AppRoutePaths.otpVerification,
      name: 'otpVerification',
      builder: (context, state) {
        final ex = state.extra;
        if (ex is OtpRouteExtra) {
          return OtpVerificationScreen(extra: ex);
        }
        final to = state.uri.queryParameters['to'];
        return OtpVerificationScreen(destination: to);
      },
    ),
    GoRoute(
      path: AppRoutePaths.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.sizes,
      name: 'responsiveSizes',
      builder: (context, state) => const ResponsiveSizesScreen(),
    ),
  ],
  errorBuilder: (context, state) => const _NotFoundScreen(),
);

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Page not found'),
      ),
    );
  }
}

