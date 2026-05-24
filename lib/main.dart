import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/config/app_routes.dart';
import 'core/l10n/l10n_extension.dart';
import 'core/l10n/locale_provider.dart';
import 'core/utils/theme/app_pallete.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

/// First screen shown after startup (see [appInitialLocation] in [appRouter]).
typedef AppLaunchScreen = SplashScreen;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  bootstrapLocale = await loadBootstrapLocale();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return ToastificationWrapper(
      child: MaterialApp.router(
        key: ValueKey(locale.languageCode),
        title: 'Transformers Church',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppPallete.tcBlueBright,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppPallete.scaffoldBg,
          textTheme: GoogleFonts.dmSansTextTheme(),
          useMaterial3: true,
          checkboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppPallete.tcBlueBright;
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
