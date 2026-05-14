import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/theme/app_pallete.dart';
import '../auth_assets.dart';

/// Full-screen splash using [AuthAssets.splash]. Image uses [BoxFit.cover] to fill the viewport.
///
/// Stays on this route until navigation is triggered elsewhere (e.g. auth flow, deep link).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
