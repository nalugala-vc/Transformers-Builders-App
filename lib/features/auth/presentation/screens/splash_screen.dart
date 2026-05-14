import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_route_paths.dart';
import '../../../../core/utils/theme/app_pallete.dart';
import '../auth_assets.dart';

/// Full-screen splash using [AuthAssets.splash]. Image uses [BoxFit.cover] to fill the viewport.
///
/// After [displayDuration], navigates to the login route.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Shown before [GoRouter] navigates to login — keep widget tests in sync.
  static const displayDuration = Duration(seconds: 3);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(SplashScreen.displayDuration, () {
      if (!mounted) return;
      context.go(AppRoutePaths.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppPallete.splashLightBlue,
        body: SizedBox.expand(
          child: Image.asset(
            AuthAssets.splash,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }
}
