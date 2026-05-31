import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/registration_flow_providers.dart';
import '../navigation/firebase_auth_action_link.dart';
import '../navigation/firebase_auth_deep_link.dart';
import 'app_route_paths.dart';
import '../../features/auth/presentation/models/otp_route_extra.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/member_group_picker_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/admin/presentation/screens/admin_shell_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../features/member/presentation/screens/member_contribution_history_screen.dart';
import '../../features/member/presentation/screens/member_notifications_screen.dart';
import '../../features/member/presentation/screens/member_shell_screen.dart';
import '../../presentation/screens/responsive_sizes_screen.dart';

/// First route after app start — must match [GoRouter.initialLocation].
const String appInitialLocation = AppRoutePaths.splash;

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Central place for all app routes.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: appInitialLocation,
  onEnter: (context, current, next, router) async {
    if (isFirebaseAuthRecaptchaCallback(next.uri)) {
      final pending = ProviderScope.containerOf(context).read(
        pendingRegistrationOtpProvider,
      );
      if (pending != null) {
        return Block.then(
          () => router.go(AppRoutePaths.otpVerification, extra: pending),
        );
      }
      return const Block.stop();
    }

    final resetCode = passwordResetCodeFromUri(next.uri);
    if (resetCode != null) {
      return Block.then(
        () => router.go(
          '${AppRoutePaths.resetPassword}?code=${Uri.encodeComponent(resetCode)}',
        ),
      );
    }

    return const Allow();
  },
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
      path: AppRoutePaths.resetPassword,
      name: 'resetPassword',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'];
        final code = state.uri.queryParameters['code'];
        return ResetPasswordScreen(
          initialEmail: email,
          initialCode: code,
        );
      },
    ),
    GoRoute(
      path: AppRoutePaths.pickGroup,
      name: 'pickGroup',
      builder: (context, state) => const MemberGroupPickerScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.otpVerification,
      name: 'otpVerification',
      builder: (context, state) {
        final fromExtra = state.extra;
        final ex = fromExtra is OtpRouteExtra
            ? fromExtra
            : ProviderScope.containerOf(context).read(
                pendingRegistrationOtpProvider,
              );
        if (ex != null) {
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
      path: AppRoutePaths.memberHome,
      name: 'memberHome',
      builder: (context, state) => const MemberShellScreen(),
      routes: [
        GoRoute(
          path: 'notifications',
          name: 'memberNotifications',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const MemberNotificationsScreen(),
        ),
        GoRoute(
          path: 'contributions',
          name: 'memberContributions',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) => const MemberContributionHistoryScreen(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutePaths.adminHome,
      name: 'adminHome',
      builder: (context, state) => const AdminShellScreen(),
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

