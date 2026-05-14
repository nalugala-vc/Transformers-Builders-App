import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'core/config/app_routes.dart';
import 'core/utils/theme/app_pallete.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

/// First screen shown after startup (see [appInitialLocation] in [appRouter]).
typedef AppLaunchScreen = SplashScreen;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'Transformers Church',
        debugShowCheckedModeBanner: false,
        // Entry: [SplashScreen] at [appInitialLocation], then login (see [SplashScreen.displayDuration]).
        routerConfig: appRouter,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppPallete.tcBlue,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppPallete.scaffoldBg,
          textTheme: GoogleFonts.dmSansTextTheme(),
          useMaterial3: true,
          checkboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppPallete.tcBlue;
              }
              return AppPallete.tcWhite;
            }),
            checkColor: WidgetStateProperty.all(AppPallete.tcWhite),
          ),
        ),
      ),
    );
  }
}
